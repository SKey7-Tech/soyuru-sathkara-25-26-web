import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/video.dart';
import '../../repositories/video_repository.dart';

/// DEV A. YouTube embed plus the up-next queue, and the one place in the app
/// that writes watch_progress.
///
/// ## How progress is saved
///
/// Four triggers, because no single one is reliable on its own:
///   * every 15s while playing — survives the app being killed by Android's
///     low-memory killer, which is common on the phones this targets
///   * on pause — the most likely moment a student leaves
///   * on ended — marks the video complete
///   * on dispose — catches a back-press between ticks
///
/// Writes are deduplicated ([_lastSavedSeconds]) so a paused video sitting on
/// screen does not send the same row every 15 seconds.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
    required this.unitId,
    required this.videoId,
  });

  final String unitId;
  final String videoId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  static const _saveInterval = Duration(seconds: 15);

  /// Fraction of the video that counts as "watched". Not 1.0 — students stop
  /// before the outro, and a video that never auto-completes makes the progress
  /// ring feel broken.
  static const _completeThreshold = 0.92;

  /// Below this, a resume would be pointless and slightly annoying.
  static const _minResumeSeconds = 10;

  late final YoutubePlayerController _controller;

  /// Captured in initState. dispose() must not touch `ref`, but it does need to
  /// write the final progress row, so the repository is held directly.
  late final VideoRepository _repository;

  StreamSubscription<YoutubeVideoState>? _positionSub;
  StreamSubscription<YoutubePlayerValue>? _valueSub;
  Timer? _saveTimer;

  List<Video> _videos = const [];
  int _index = 0;
  Duration _position = Duration.zero;
  double? _durationSec;
  bool _completed = false;
  bool _loading = true;
  Object? _error;

  int? _lastSavedSeconds;
  bool? _lastSavedCompleted;

  Video? get _current => _index < _videos.length ? _videos[_index] : null;

  @override
  void initState() {
    super.initState();

    _repository = ref.read(videoRepositoryProvider);

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        enableCaption: true,
        // Keeps YouTube's end-screen suggestions within the same channel.
        // Without it the player advertises arbitrary videos to school students
        // the moment a lesson ends.
        strictRelatedVideos: true,
      ),
    );

    _positionSub = _controller.videoStateStream.listen(_onPositionChanged);
    _valueSub = _controller.stream.listen(_onPlayerValueChanged);
    _saveTimer = Timer.periodic(_saveInterval, (_) => _saveProgress());

    _bootstrap();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _positionSub?.cancel();
    _valueSub?.cancel();

    // Last write, deliberately not awaited — dispose cannot be async. The
    // repository is a plain object with no tie to this widget's lifecycle, so
    // the request completes even though the screen is gone.
    final video = _current;
    if (video != null && _position.inSeconds > 0) {
      unawaited(
        _repository
            .saveProgress(video.id, _position.inSeconds, _completed)
            // Nothing can be shown to the user from here; swallow rather than
            // letting it surface as an unhandled async error.
            .catchError((_) => false),
      );
    }

    _controller.close();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Loading
  // ------------------------------------------------------------------

  Future<void> _bootstrap() async {
    try {
      final videos = await ref.read(videosProvider(widget.unitId).future);

      if (videos.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = StateError('This unit has no videos.');
        });
        return;
      }

      // A videoId that is not in this unit (a stale deep link, or content that
      // moved) falls back to the first video rather than showing an error.
      final requested = videos.indexWhere((v) => v.id == widget.videoId);
      final index = requested < 0 ? 0 : requested;

      if (!mounted) return;
      setState(() {
        _videos = videos;
        _index = index;
        _loading = false;
      });

      await _loadCurrent();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  /// Loads [_current] into the player, resuming where the student left off.
  Future<void> _loadCurrent() async {
    final video = _current;
    if (video == null) return;

    // Progress is per-user and may be unavailable (no session). A failure here
    // must not stop playback, so it degrades to "start from the beginning".
    var resumeFrom = 0;
    var alreadyCompleted = false;
    try {
      final progress = await _repository.getProgress(video.id);
      alreadyCompleted = progress?.completed ?? false;
      if (progress != null &&
          !progress.completed &&
          progress.secondsWatched >= _minResumeSeconds) {
        resumeFrom = progress.secondsWatched;
      }
    } catch (_) {
      /* start from 0 */
    }

    if (!mounted) return;
    setState(() {
      _completed = alreadyCompleted;
      _position = Duration(seconds: resumeFrom);
      _durationSec = null;
      _lastSavedSeconds = null;
      _lastSavedCompleted = null;
    });

    await _controller.loadVideoById(
      videoId: video.youtubeVideoId,
      startSeconds: resumeFrom == 0 ? null : resumeFrom.toDouble(),
    );
  }

  Future<void> _playAt(int index) async {
    if (index < 0 || index >= _videos.length || index == _index) return;

    // Persist the video being left before switching away from it.
    await _saveProgress();

    if (!mounted) return;
    setState(() => _index = index);
    await _loadCurrent();
  }

  // ------------------------------------------------------------------
  // Player events
  // ------------------------------------------------------------------

  void _onPositionChanged(YoutubeVideoState state) {
    _position = state.position;

    final duration = _durationSec;
    if (!_completed &&
        duration != null &&
        duration > 0 &&
        state.position.inSeconds / duration >= _completeThreshold) {
      _markCompleted();
    }
  }

  void _onPlayerValueChanged(YoutubePlayerValue value) {
    switch (value.playerState) {
      case PlayerState.ended:
        _markCompleted();
      case PlayerState.paused:
        _saveProgress(invalidate: true);
      case PlayerState.playing:
        // Duration is only known once YouTube has the metadata, which is after
        // playback starts — not when loadVideoById returns.
        if (_durationSec == null) _fetchDuration();
      case PlayerState.unknown:
      case PlayerState.unStarted:
      case PlayerState.buffering:
      case PlayerState.cued:
        break;
    }
  }

  Future<void> _fetchDuration() async {
    try {
      final duration = await _controller.duration;
      if (!mounted || duration <= 0) return;
      setState(() => _durationSec = duration);
    } catch (_) {
      /* leave null; completion then depends on the ended event or the button */
    }
  }

  // ------------------------------------------------------------------
  // Progress
  // ------------------------------------------------------------------

  Future<void> _saveProgress({bool invalidate = false}) async {
    final video = _current;
    if (video == null) return;

    final seconds = _position.inSeconds;
    if (seconds <= 0 && !_completed) return;

    // Skip an identical repeat write.
    if (_lastSavedSeconds == seconds && _lastSavedCompleted == _completed) {
      return;
    }

    final written =
        await _repository.saveProgress(video.id, seconds, _completed);
    if (!written) return;

    _lastSavedSeconds = seconds;
    _lastSavedCompleted = _completed;

    // Only on meaningful moments, never on the 15s tick: invalidating those
    // providers refetches the unit list and home row, and doing that four
    // times a minute during playback would be pointless traffic on a
    // connection that cannot spare it.
    if (invalidate && mounted) _invalidateProgressViews();
  }

  void _invalidateProgressViews() {
    ref.invalidate(unitProgressProvider(widget.unitId));
    ref.invalidate(continueWatchingProvider);
    final subjectId = ref.read(unitProvider(widget.unitId)).valueOrNull?.subjectId;
    if (subjectId != null) ref.invalidate(unitsProvider(subjectId));
  }

  Future<void> _markCompleted() async {
    if (_completed) return;
    setState(() => _completed = true);
    await _saveProgress(invalidate: true);
  }

  Future<void> _toggleCompleted() async {
    final next = !_completed;
    setState(() => _completed = next);

    // Un-marking also clears the stored position, so the video leaves the
    // continue-watching row instead of reappearing there as "in progress".
    final video = _current;
    if (video == null) return;

    await _repository.saveProgress(
      video.id,
      next ? _position.inSeconds : 0,
      next,
    );
    _lastSavedSeconds = next ? _position.inSeconds : 0;
    _lastSavedCompleted = next;

    if (mounted) _invalidateProgressViews();
  }

  Future<void> _openInYouTube() async {
    final video = _current;
    if (video == null) return;
    final uri = Uri.parse(video.watchUrl);
    // externalApplication so it lands in the YouTube app when installed, which
    // is both faster and cheaper on data than an in-app webview.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingView(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          error: _error!,
          onRetry: () {
            setState(() {
              _error = null;
              _loading = true;
            });
            _bootstrap();
          },
        ),
      );
    }

    // YoutubePlayerScaffold was deprecated in 6.0: YoutubePlayer now drives
    // fullscreen itself through an OverlayPortal, so no scaffold wrapper is
    // needed. The provider stays so descendants can reach context.ytController.
    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.playerVideoOf(_index + 1, _videos.length),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: l10n.playerOpenInYouTube,
              onPressed: _openInYouTube,
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _current?.title ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _completed
                        ? FilledButton.tonalIcon(
                            onPressed: _toggleCompleted,
                            icon: const Icon(Icons.check_circle_rounded,
                                size: 18),
                            label: Text(l10n.playerMarkedComplete),
                          )
                        : FilledButton.icon(
                            onPressed: _toggleCompleted,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(l10n.playerMarkComplete),
                          ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.outlined(
                    onPressed: _index > 0 ? () => _playAt(_index - 1) : null,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: l10n.playerPrevious,
                  ),
                  const SizedBox(width: 6),
                  IconButton.outlined(
                    onPressed: _index < _videos.length - 1
                        ? () => _playAt(_index + 1)
                        : null,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: l10n.playerNext,
                  ),
                ],
              ),
            ),
            if (_index < _videos.length - 1) ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.playerUpNext,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              for (var i = _index + 1; i < _videos.length; i++)
                ListTile(
                  dense: true,
                  leading: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    _videos[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.play_arrow_rounded, size: 20),
                  onTap: () => _playAt(i),
                ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

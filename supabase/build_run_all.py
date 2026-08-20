"""Regenerates supabase/RUN_ALL.sql from the individual migration files.

Run from the repo root:  python supabase/build_run_all.py

RUN_ALL.sql is a convenience bundle for pasting into the Supabase SQL Editor.
The files in migrations/ and seed/ remain the source of truth — edit those,
then re-run this.
"""
import io
import os

FILES = [
    ('supabase/migrations/001_init_schema.sql', 'SCHEMA — tables, constraints, indexes'),
    ('supabase/migrations/002_rls_policies.sql', 'ROW LEVEL SECURITY'),
    ('supabase/migrations/003_profile_trigger.sql', 'PROFILE AUTO-CREATION TRIGGER'),
    ('supabase/migrations/004_storage.sql', 'STORAGE BUCKET'),
    ('supabase/seed/001_seed_content.sql', 'SEED — real content from the website'),
]

HEADER = io.open('supabase/RUN_ALL.sql', encoding='utf-8').read().split('

-- =', 1)[0] + '
'


def main():
    if not os.path.isdir('supabase'):
        raise SystemExit('Run this from the repository root.')

    parts = [HEADER]
    for path, label in FILES:
        body = io.open(path, encoding='utf-8').read().strip()
        bar = '=' * 69
        parts.append(
            f"
-- {bar}
-- {label}
-- source: {path}
-- {bar}

{body}
"
        )

    io.open('supabase/RUN_ALL.sql', 'w', encoding='utf-8').write('
'.join(parts))
    print('Wrote supabase/RUN_ALL.sql')


if __name__ == '__main__':
    main()

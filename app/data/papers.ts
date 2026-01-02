export type Paper = {
  id: string;
  titleKey: string;
  descriptionKey: string;
  filePath: string;
  coverImage: string;
  videos: {label: string; url: string}[];
};

export const papers: Paper[] = [
  {
    id: "Easy-Level",
    titleKey: "Easy-Level",
    descriptionKey: "Easy-Level",
    filePath: "/files/papers/Easy-Level.pdf",
    coverImage: "/gallery/paper-cover.jpeg",
    videos: [
      { label: "discussion_1", url: "https://www.youtube.com/watch?v=Dj7ku0IeZN8" },
      { label: "discussion_2", url: "https://www.youtube.com/watch?v=Q4lV1t5VuGE" },
      { label: "discussion_3", url: "https://www.youtube.com/watch?v=WmTqfD6F-OA" },
      { label: "discussion_4", url: "https://www.youtube.com/watch?v=ertLNjFgIUk" },
      { label: "discussion_5", url: "https://www.youtube.com/watch?v=YDlKm7Yi6No" },
      { label: "discussion_6", url: "https://www.youtube.com/watch?v=6wmsE4asEJI" },
      { label: "discussion_7", url: "https://www.youtube.com/watch?v=anDQta3nTSY" },
    ],
  },
  {
    id: "Medium-Level",
    titleKey: "Medium-Level",
    descriptionKey: "Medium-Level",
    filePath: "/files/papers/Medium-Level.pdf",
    coverImage: "/gallery/paper-cover.jpeg",
    videos: [
      // {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "Hard-Level",
    titleKey: "Hard-Level",
    descriptionKey: "Hard-Level",
    filePath: "/files/papers/Hard-Level.pdf",
    coverImage: "/gallery/paper-cover.jpeg",
    videos: [
      // {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      // {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
];

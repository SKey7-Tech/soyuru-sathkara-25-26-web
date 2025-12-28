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
    id: "paper-2024-biology",
    titleKey: "paper-2024-biology",
    descriptionKey: "paper-2024-biology",
    filePath: "/files/papers/biology-2024.pdf",
    coverImage: "/gallery/paper-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "paper-2024-physics",
    titleKey: "paper-2024-physics",
    descriptionKey: "paper-2024-physics",
    filePath: "/files/papers/physics-2024.pdf",
    coverImage: "/gallery/paper-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "paper-2024-chemistry",
    titleKey: "paper-2024-chemistry",
    descriptionKey: "paper-2024-chemistry",
    filePath: "/files/papers/chemistry-2024.pdf",
    coverImage: "/gallery/paper-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
];

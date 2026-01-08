export type Theory = {
  id: string;
  titleKey: string;
  descriptionKey: string;
  filePath: string;
  coverImage: string;
  videos: {label: string; url: string}[];
};

export const theory: Theory[] = [
  {
    id: "theory-biology-cell",
    titleKey: "theory-biology-cell",
    descriptionKey: "theory-biology-cell",
    filePath: "/files/theory/biology-cell-structure.pdf",
    coverImage: "/gallery/theory-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_3",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "theory-physics-mechanics",
    titleKey: "theory-physics-mechanics",
    descriptionKey: "theory-physics-mechanics",
    filePath: "/files/theory/physics-mechanics.pdf",
    coverImage: "/gallery/theory-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "theory-chemistry-organic",
    titleKey: "theory-chemistry-organic",
    descriptionKey: "theory-chemistry-organic",
    filePath: "/files/theory/chemistry-organic.pdf",
    coverImage: "/gallery/theory-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
];

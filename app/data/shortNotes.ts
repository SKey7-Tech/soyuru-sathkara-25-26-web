export type ShortNote = {
  id: string;
  titleKey: string;
  descriptionKey: string;
  filePath: string;
  coverImage: string;
  videos: {label: string; url: string}[];
};

export const shortNotes: ShortNote[] = [
  {
    id: "short-biology-quick",
    titleKey: "short-biology-quick",
    descriptionKey: "short-biology-quick",
    filePath: "/files/short-notes/biology-quick-revision.pdf",
    coverImage: "/gallery/notes-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "short-physics-formulas",
    titleKey: "short-physics-formulas",
    descriptionKey: "short-physics-formulas",
    filePath: "/files/short-notes/physics-formulas.pdf",
    coverImage: "/gallery/notes-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "short-chemistry-equations",
    titleKey: "short-chemistry-equations",
    descriptionKey: "short-chemistry-equations",
    filePath: "/files/short-notes/chemistry-equations.pdf",
    coverImage: "/gallery/notes-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
];

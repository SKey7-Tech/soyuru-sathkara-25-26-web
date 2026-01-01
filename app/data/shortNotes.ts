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
    id: "short-note",
    titleKey: "short-note",
    descriptionKey: "short-note",
    filePath: "/files/short-notes/Short-Note.pdf",
    coverImage: "/gallery/notes-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  // add components for the below short notes when ready, use the given structure
  // {
  //   id: "short-physics-formulas",
  //   titleKey: "short-physics-formulas",
  //   descriptionKey: "short-physics-formulas",
  //   filePath: "/files/short-notes/physics-formulas.pdf",
  //   coverImage: "/gallery/notes-cover.jpg",
  //   videos: [
  //     {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
  //     {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
  //   ],
  // },
  // {
  //   id: "short-chemistry-equations",
  //   titleKey: "short-chemistry-equations",
  //   descriptionKey: "short-chemistry-equations",
  //   filePath: "/files/short-notes/chemistry-equations.pdf",
  //   coverImage: "/gallery/notes-cover.jpg",
  //   videos: [
  //     {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
  //   ],
  // },
];

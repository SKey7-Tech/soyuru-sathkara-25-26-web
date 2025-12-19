export type PDF = {
  id: string;
  titleKey: string;
  descriptionKey: string;
  filePath: string;
  coverImage: string;
  videos: {label: string; url: string}[];
};

export const pdfs: PDF[] = [
  {
    id: "handbook-2025",
    titleKey: "handbook-2025",
    descriptionKey: "handbook-2025",
    filePath: "/files/student-handbook-2025.pdf",
    coverImage: "/gallery/handbook-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_3",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
  {
    id: "annual-report",
    titleKey: "annual-report",
    descriptionKey: "annual-report",
    filePath: "/files/annual-report-2024.pdf",
    coverImage: "/gallery/report-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
      {label:"discussion_2",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],

  },
  {
    id: "prospectus",
    titleKey: "prospectus",
    descriptionKey: "prospectus",
    filePath: "/files/prospectus.pdf",
    coverImage: "/gallery/prospectus-cover.jpg",
    videos: [
      {label:"discussion_1",url:"https://www.youtube.com/watch?v=xNQjYPs6uJU&t=1s"},
    ],
  },
];

export type PDF = {
  id: string;
  titleKey: string;
  descriptionKey: string;
  filePath: string;
  coverImage: string;
};

export const pdfs: PDF[] = [
  {
    id: "handbook-2025",
    titleKey: "handbook-2025",
    descriptionKey: "handbook-2025",
    filePath: "/files/student-handbook-2025.pdf",
    coverImage: "/gallery/handbook-cover.jpg",
  },
  {
    id: "annual-report",
    titleKey: "annual-report",
    descriptionKey: "annual-report",
    filePath: "/files/annual-report-2024.pdf",
    coverImage: "/gallery/report-cover.jpg",
  },
  {
    id: "prospectus",
    titleKey: "prospectus",
    descriptionKey: "prospectus",
    filePath: "/files/prospectus.pdf",
    coverImage: "/gallery/prospectus-cover.jpg",
  },
];

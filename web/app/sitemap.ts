import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://ss.efsu-uom.lk';

    return [
        {
            url: baseUrl,
            lastModified: new Date(),
        },
        {
            url: `${baseUrl}/resources/papers`,
            lastModified: new Date(),
        },
        {
            url: `${baseUrl}/resources/short-notes`,
            lastModified: new Date(),
        },
        {
            url: `${baseUrl}/resources/theory`,
            lastModified: new Date(),
        },
        // add the rest of the routes here - SEO important pages
    ]
}


import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://ss.efsu-uom.lk';

    return [
        {
            url: baseUrl,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 1.0,
        },
        {
            url: `${baseUrl}/en`,
            lastModified: new Date(),
            changeFrequency: 'monthly',

        },
        {
            url: `${baseUrl}/si`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
        },
        {
            url: `${baseUrl}/ta`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
        },
        // add the rest of the routes here - SEO important pages
    ]
}


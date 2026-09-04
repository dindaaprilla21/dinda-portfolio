import { useEffect } from 'react';

/**
 * Custom hook to handle smooth scrolling for anchor links
 * This ensures all hash links (#layanan, #berita, etc.) scroll smoothly
 */
export default function useSmoothScroll() {
    useEffect(() => {
        // Handle smooth scroll for all anchor links
        const handleAnchorClick = (e) => {
            const href = e.target.getAttribute('href');

            // Check if it's a hash link
            if (href && href.startsWith('#')) {
                e.preventDefault();

                const targetId = href.substring(1);
                const targetElement = document.getElementById(targetId);

                if (targetElement) {
                    // Smooth scroll to the element
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start',
                        inline: 'nearest'
                    });

                    // Update URL without jumping
                    window.history.pushState(null, '', href);
                }
            }
        };

        // Add click listener to all anchor links
        const links = document.querySelectorAll('a[href^="#"]');
        links.forEach(link => {
            link.addEventListener('click', handleAnchorClick);
        });

        // Cleanup
        return () => {
            links.forEach(link => {
                link.removeEventListener('click', handleAnchorClick);
            });
        };
    }, []);
}

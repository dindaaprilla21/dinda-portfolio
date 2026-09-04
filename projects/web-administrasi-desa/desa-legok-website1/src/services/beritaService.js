import { supabase } from '../config/supabaseClient'

/**
 * Service for managing berita (news articles)
 */

/**
 * Get all published berita for public view
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @param {string} kategori - Optional category filter
 * @returns {Promise<{data: Array, count: number, error: any}>}
 */
export async function getPublishedBerita(page = 1, limit = 10, kategori = null) {
    try {
        let query = supabase
            .from('berita')
            .select('*', { count: 'exact' })
            .eq('status', 'published')
            .order('tanggal_publikasi', { ascending: false })

        if (kategori) {
            query = query.eq('kategori', kategori)
        }

        // Apply pagination
        const from = (page - 1) * limit
        const to = from + limit - 1
        query = query.range(from, to)

        const { data, error, count } = await query

        if (error) throw error

        return { data, count, error: null }
    } catch (error) {
        console.error('Error fetching published berita:', error)
        return { data: null, count: 0, error }
    }
}

/**
 * Get all berita (including drafts) for admin
 * @param {Object} filters - Filter options { status, kategori, search }
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {Promise<{data: Array, count: number, error: any}>}
 */
export async function getAllBerita(filters = {}, page = 1, limit = 10) {
    try {
        let query = supabase
            .from('berita')
            .select('*', { count: 'exact' })
            .order('created_at', { ascending: false })

        // Apply status filter
        if (filters.status && filters.status !== 'all') {
            query = query.eq('status', filters.status)
        }

        // Apply kategori filter
        if (filters.kategori && filters.kategori !== 'all') {
            query = query.eq('kategori', filters.kategori)
        }

        // Apply search filter
        if (filters.search) {
            query = query.or(`judul.ilike.%${filters.search}%,konten.ilike.%${filters.search}%`)
        }

        // Apply pagination
        const from = (page - 1) * limit
        const to = from + limit - 1
        query = query.range(from, to)

        const { data, error, count } = await query

        if (error) throw error

        return { data, count, error: null }
    } catch (error) {
        console.error('Error fetching all berita:', error)
        return { data: null, count: 0, error }
    }
}

/**
 * Get single berita by slug
 * @param {string} slug - Berita slug
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getBeritaBySlug(slug) {
    try {
        const { data, error } = await supabase
            .from('berita')
            .select('*')
            .eq('slug', slug)
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching berita by slug:', error)
        return { data: null, error }
    }
}

/**
 * Get single berita by ID
 * @param {string} id - Berita ID
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getBeritaById(id) {
    try {
        const { data, error } = await supabase
            .from('berita')
            .select('*')
            .eq('id', id)
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching berita by ID:', error)
        return { data: null, error }
    }
}

/**
 * Create new berita
 * @param {Object} beritaData - Berita data
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function createBerita(beritaData) {
    try {
        // Generate slug from judul if not provided
        if (!beritaData.slug) {
            beritaData.slug = generateSlug(beritaData.judul)
        }

        // Set tanggal_publikasi if publishing
        if (beritaData.status === 'published' && !beritaData.tanggal_publikasi) {
            beritaData.tanggal_publikasi = new Date().toISOString()
        }

        const { data, error } = await supabase
            .from('berita')
            .insert([beritaData])
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error creating berita:', error)
        return { data: null, error }
    }
}

/**
 * Update berita
 * @param {string} id - Berita ID
 * @param {Object} updates - Fields to update
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updateBerita(id, updates) {
    try {
        // Update slug if judul changed
        if (updates.judul && !updates.slug) {
            updates.slug = generateSlug(updates.judul)
        }

        const { data, error } = await supabase
            .from('berita')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating berita:', error)
        return { data: null, error }
    }
}

/**
 * Publish or unpublish berita
 * @param {string} id - Berita ID
 * @param {boolean} publish - true to publish, false to unpublish
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function togglePublishBerita(id, publish = true) {
    try {
        const updates = {
            status: publish ? 'published' : 'draft'
        }

        if (publish) {
            updates.tanggal_publikasi = new Date().toISOString()
        }

        const { data, error } = await supabase
            .from('berita')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error toggling publish berita:', error)
        return { data: null, error }
    }
}

/**
 * Delete berita
 * @param {string} id - Berita ID
 * @returns {Promise<{success: boolean, error: any}>}
 */
export async function deleteBerita(id) {
    try {
        const { error } = await supabase
            .from('berita')
            .delete()
            .eq('id', id)

        if (error) throw error

        return { success: true, error: null }
    } catch (error) {
        console.error('Error deleting berita:', error)
        return { success: false, error }
    }
}

/**
 * Increment view count for berita
 * @param {string} id - Berita ID
 * @returns {Promise<{success: boolean, error: any}>}
 */
export async function incrementViews(id) {
    try {
        // Get current views
        const { data: berita, error: fetchError } = await supabase
            .from('berita')
            .select('views')
            .eq('id', id)
            .single()

        if (fetchError) throw fetchError

        // Increment views
        const { error: updateError } = await supabase
            .from('berita')
            .update({ views: (berita.views || 0) + 1 })
            .eq('id', id)

        if (updateError) throw updateError

        return { success: true, error: null }
    } catch (error) {
        console.error('Error incrementing views:', error)
        return { success: false, error }
    }
}

/**
 * Get latest published berita
 * @param {number} limit - Number of items to fetch
 * @returns {Promise<{data: Array, error: any}>}
 */
export async function getLatestBerita(limit = 5) {
    try {
        const { data, error } = await supabase
            .from('berita')
            .select('*')
            .eq('status', 'published')
            .order('tanggal_publikasi', { ascending: false })
            .limit(limit)

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching latest berita:', error)
        return { data: null, error }
    }
}

/**
 * Helper function to generate slug from title
 * @param {string} title - Article title
 * @returns {string} - URL-friendly slug
 */
function generateSlug(title) {
    return title
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '') // Remove special characters
        .replace(/\s+/g, '-') // Replace spaces with hyphens
        .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
        .trim()
}

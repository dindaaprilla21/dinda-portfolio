import { supabase } from '../config/supabaseClient'

/**
 * Service for managing pengajuan surat (letter submissions)
 */

/**
 * Get all pengajuan surat with optional filters and pagination
 * @param {Object} filters - Filter options { status, search }
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {Promise<{data: Array, count: number, error: any}>}
 */
export async function getAllSurat(filters = {}, page = 1, limit = 10) {
    try {
        let query = supabase
            .from('pengajuan_surat')
            .select('*', { count: 'exact' })
            .order('tanggal_pengajuan', { ascending: false })

        // Apply status filter
        if (filters.status && filters.status !== 'all') {
            query = query.eq('status', filters.status)
        }

        // Apply search filter
        if (filters.search) {
            query = query.or(`nama.ilike.%${filters.search}%,jenis_surat.ilike.%${filters.search}%`)
        }

        // Apply pagination
        const from = (page - 1) * limit
        const to = from + limit - 1
        query = query.range(from, to)

        const { data, error, count } = await query

        if (error) throw error

        return { data, count, error: null }
    } catch (error) {
        console.error('Error fetching pengajuan surat:', error)
        return { data: null, count: 0, error }
    }
}

/**
 * Get single pengajuan surat by ID
 * @param {string} id - Surat ID
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getSuratById(id) {
    try {
        const { data, error } = await supabase
            .from('pengajuan_surat')
            .select('*')
            .eq('id', id)
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching surat by ID:', error)
        return { data: null, error }
    }
}

/**
 * Create new pengajuan surat
 * @param {Object} suratData - Surat data
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function createSurat(suratData) {
    try {
        const { data, error } = await supabase
            .from('pengajuan_surat')
            .insert([suratData])
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error creating pengajuan surat:', error)
        return { data: null, error }
    }
}

/**
 * Update pengajuan surat
 * @param {string} id - Surat ID
 * @param {Object} updates - Fields to update
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updateSurat(id, updates) {
    try {
        const { data, error } = await supabase
            .from('pengajuan_surat')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating pengajuan surat:', error)
        return { data: null, error }
    }
}

/**
 * Update status of pengajuan surat
 * @param {string} id - Surat ID
 * @param {string} status - New status
 * @param {string} catatan - Admin notes (optional)
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updateSuratStatus(id, status, catatan = null) {
    try {
        const updates = { status }

        if (catatan) {
            updates.catatan_admin = catatan
        }

        if (status === 'selesai') {
            updates.tanggal_selesai = new Date().toISOString()
        }

        const { data, error } = await supabase
            .from('pengajuan_surat')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating surat status:', error)
        return { data: null, error }
    }
}

/**
 * Delete pengajuan surat
 * @param {string} id - Surat ID
 * @returns {Promise<{success: boolean, error: any}>}
 */
export async function deleteSurat(id) {
    try {
        const { error } = await supabase
            .from('pengajuan_surat')
            .delete()
            .eq('id', id)

        if (error) throw error

        return { success: true, error: null }
    } catch (error) {
        console.error('Error deleting pengajuan surat:', error)
        return { success: false, error }
    }
}

/**
 * Get statistics for dashboard
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getSuratStats() {
    try {
        const { data, error } = await supabase
            .from('pengajuan_surat')
            .select('status')

        if (error) throw error

        const stats = {
            total: data.length,
            pending: data.filter(s => s.status === 'pending').length,
            diproses: data.filter(s => s.status === 'diproses').length,
            selesai: data.filter(s => s.status === 'selesai').length,
            ditolak: data.filter(s => s.status === 'ditolak').length,
        }

        return { data: stats, error: null }
    } catch (error) {
        console.error('Error fetching surat stats:', error)
        return { data: null, error }
    }
}

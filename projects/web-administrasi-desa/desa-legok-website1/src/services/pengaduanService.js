import { supabase } from '../config/supabaseClient'

/**
 * Service for managing laporan pengaduan (complaint reports)
 */

/**
 * Get all laporan pengaduan with optional filters and pagination
 * @param {Object} filters - Filter options { status, kategori, prioritas, search }
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {Promise<{data: Array, count: number, error: any}>}
 */
export async function getAllPengaduan(filters = {}, page = 1, limit = 10) {
    try {
        let query = supabase
            .from('laporan_pengaduan')
            .select('*', { count: 'exact' })
            .order('tanggal_laporan', { ascending: false })

        // Apply status filter
        if (filters.status && filters.status !== 'all') {
            query = query.eq('status', filters.status)
        }

        // Apply kategori filter
        if (filters.kategori && filters.kategori !== 'all') {
            query = query.eq('kategori', filters.kategori)
        }

        // Apply prioritas filter
        if (filters.prioritas && filters.prioritas !== 'all') {
            query = query.eq('prioritas', filters.prioritas)
        }

        // Apply search filter
        if (filters.search) {
            query = query.or(`nama.ilike.%${filters.search}%,judul.ilike.%${filters.search}%,deskripsi.ilike.%${filters.search}%`)
        }

        // Apply pagination
        const from = (page - 1) * limit
        const to = from + limit - 1
        query = query.range(from, to)

        const { data, error, count } = await query

        if (error) throw error

        return { data, count, error: null }
    } catch (error) {
        console.error('Error fetching laporan pengaduan:', error)
        return { data: null, count: 0, error }
    }
}

/**
 * Get single laporan pengaduan by ID
 * @param {string} id - Pengaduan ID
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getPengaduanById(id) {
    try {
        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .select('*')
            .eq('id', id)
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching pengaduan by ID:', error)
        return { data: null, error }
    }
}

/**
 * Create new laporan pengaduan
 * @param {Object} pengaduanData - Pengaduan data
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function createPengaduan(pengaduanData) {
    try {
        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .insert([pengaduanData])
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error creating laporan pengaduan:', error)
        return { data: null, error }
    }
}

/**
 * Update laporan pengaduan
 * @param {string} id - Pengaduan ID
 * @param {Object} updates - Fields to update
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updatePengaduan(id, updates) {
    try {
        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating laporan pengaduan:', error)
        return { data: null, error }
    }
}

/**
 * Update status of laporan pengaduan
 * @param {string} id - Pengaduan ID
 * @param {string} status - New status
 * @param {string} tanggapan - Admin response (optional)
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updatePengaduanStatus(id, status, tanggapan = null) {
    try {
        const updates = { status }

        if (tanggapan) {
            updates.tanggapan_admin = tanggapan
        }

        if (status === 'selesai') {
            updates.tanggal_selesai = new Date().toISOString()
        }

        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .update(updates)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating pengaduan status:', error)
        return { data: null, error }
    }
}

/**
 * Update prioritas of laporan pengaduan
 * @param {string} id - Pengaduan ID
 * @param {string} prioritas - New priority level
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function updatePengaduanPrioritas(id, prioritas) {
    try {
        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .update({ prioritas })
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error updating pengaduan prioritas:', error)
        return { data: null, error }
    }
}

/**
 * Delete laporan pengaduan
 * @param {string} id - Pengaduan ID
 * @returns {Promise<{success: boolean, error: any}>}
 */
export async function deletePengaduan(id) {
    try {
        const { error } = await supabase
            .from('laporan_pengaduan')
            .delete()
            .eq('id', id)

        if (error) throw error

        return { success: true, error: null }
    } catch (error) {
        console.error('Error deleting laporan pengaduan:', error)
        return { success: false, error }
    }
}

/**
 * Get statistics for dashboard
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function getPengaduanStats() {
    try {
        const { data, error } = await supabase
            .from('laporan_pengaduan')
            .select('status, prioritas, kategori')

        if (error) throw error

        const stats = {
            total: data.length,
            byStatus: {
                pending: data.filter(p => p.status === 'pending').length,
                ditinjau: data.filter(p => p.status === 'ditinjau').length,
                diproses: data.filter(p => p.status === 'diproses').length,
                selesai: data.filter(p => p.status === 'selesai').length,
                ditolak: data.filter(p => p.status === 'ditolak').length,
            },
            byPrioritas: {
                rendah: data.filter(p => p.prioritas === 'rendah').length,
                sedang: data.filter(p => p.prioritas === 'sedang').length,
                tinggi: data.filter(p => p.prioritas === 'tinggi').length,
            },
            byKategori: {
                infrastruktur: data.filter(p => p.kategori === 'infrastruktur').length,
                pelayanan: data.filter(p => p.kategori === 'pelayanan').length,
                lingkungan: data.filter(p => p.kategori === 'lingkungan').length,
                keamanan: data.filter(p => p.kategori === 'keamanan').length,
                lainnya: data.filter(p => p.kategori === 'lainnya').length,
            }
        }

        return { data: stats, error: null }
    } catch (error) {
        console.error('Error fetching pengaduan stats:', error)
        return { data: null, error }
    }
}

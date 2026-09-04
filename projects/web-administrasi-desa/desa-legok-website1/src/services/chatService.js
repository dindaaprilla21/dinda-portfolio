import { supabase } from '../config/supabaseClient'

/**
 * Service for managing chat messages
 */

/**
 * Save chat message to database
 * @param {Object} messageData - Message data { nama, email, telepon, pesan, n8n_response }
 * @returns {Promise<{data: Object, error: any}>}
 */
export async function saveChatMessage(messageData) {
    try {
        const { data, error } = await supabase
            .from('chat_messages')
            .insert([messageData])
            .select()
            .single()

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error saving chat message:', error)
        return { data: null, error }
    }
}

/**
 * Get all chat messages (admin only)
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {Promise<{data: Array, count: number, error: any}>}
 */
export async function getAllChatMessages(page = 1, limit = 50) {
    try {
        const from = (page - 1) * limit
        const to = from + limit - 1

        const { data, error, count } = await supabase
            .from('chat_messages')
            .select('*', { count: 'exact' })
            .order('created_at', { ascending: false })
            .range(from, to)

        if (error) throw error

        return { data, count, error: null }
    } catch (error) {
        console.error('Error fetching chat messages:', error)
        return { data: null, count: 0, error }
    }
}

/**
 * Get recent chat messages
 * @param {number} limit - Number of messages to fetch
 * @returns {Promise<{data: Array, error: any}>}
 */
export async function getRecentChatMessages(limit = 10) {
    try {
        const { data, error } = await supabase
            .from('chat_messages')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(limit)

        if (error) throw error

        return { data, error: null }
    } catch (error) {
        console.error('Error fetching recent chat messages:', error)
        return { data: null, error }
    }
}

/**
 * Delete chat message
 * @param {string} id - Message ID
 * @returns {Promise<{success: boolean, error: any}>}
 */
export async function deleteChatMessage(id) {
    try {
        const { error } = await supabase
            .from('chat_messages')
            .delete()
            .eq('id', id)

        if (error) throw error

        return { success: true, error: null }
    } catch (error) {
        console.error('Error deleting chat message:', error)
        return { success: false, error }
    }
}

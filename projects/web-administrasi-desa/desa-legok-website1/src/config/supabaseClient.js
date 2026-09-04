import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Check if Supabase is configured
const isSupabaseConfigured = supabaseUrl &&
    supabaseAnonKey &&
    !supabaseUrl.includes('placeholder') &&
    !supabaseAnonKey.includes('placeholder')

if (!isSupabaseConfigured) {
    console.warn(
        '⚠️ Supabase belum dikonfigurasi. Website akan berjalan dengan fitur terbatas.\n' +
        'Untuk mengaktifkan database, ikuti panduan di SUPABASE_SETUP_GUIDE.md'
    )
}

// Create client with placeholder values if not configured
// This allows the website to run without errors
export const supabase = createClient(
    supabaseUrl || 'https://placeholder.supabase.co',
    supabaseAnonKey || 'placeholder-key'
)

// Export flag to check if Supabase is ready
export const isSupabaseReady = isSupabaseConfigured

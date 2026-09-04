import React, { createContext, useContext, useState, useEffect } from 'react'
import { supabase } from '../config/supabaseClient'

const AuthContext = createContext({})

export const useAuth = () => {
    const context = useContext(AuthContext)
    if (!context) {
        throw new Error('useAuth must be used within AuthProvider')
    }
    return context
}

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null)
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState(null)

    useEffect(() => {
        // Check active session
        checkUser()

        // Listen for auth changes
        const { data: authListener } = supabase.auth.onAuthStateChange(
            async (event, session) => {
                setUser(session?.user ?? null)
                setLoading(false)
            }
        )

        return () => {
            authListener?.subscription?.unsubscribe()
        }
    }, [])

    const checkUser = async () => {
        try {
            const { data: { session }, error } = await supabase.auth.getSession()

            if (error) throw error

            setUser(session?.user ?? null)
        } catch (error) {
            console.error('Error checking user:', error)
            setError(error.message)
        } finally {
            setLoading(false)
        }
    }

    const login = async (email, password) => {
        try {
            setLoading(true)
            setError(null)

            const { data, error } = await supabase.auth.signInWithPassword({
                email,
                password,
            })

            if (error) throw error

            setUser(data.user)
            return { user: data.user, error: null }
        } catch (error) {
            console.error('Login error:', error)
            setError(error.message)
            return { user: null, error: error.message }
        } finally {
            setLoading(false)
        }
    }

    const logout = async () => {
        try {
            setLoading(true)
            setError(null)

            const { error } = await supabase.auth.signOut()

            if (error) throw error

            setUser(null)
            return { error: null }
        } catch (error) {
            console.error('Logout error:', error)
            setError(error.message)
            return { error: error.message }
        } finally {
            setLoading(false)
        }
    }

    const value = {
        user,
        loading,
        error,
        login,
        logout,
        isAuthenticated: !!user,
    }

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

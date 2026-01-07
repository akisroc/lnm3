export interface User {
  id: string
  username: string
  email: string
  profilePicture: string
  slug: string
}

export interface AuthState {
  user: User | null
  isAuthenticated: boolean
}

export const useAuth = () => {
  const user = useState<User | null>('auth:user', () => null)

  const isAuthenticated = computed(() => !!user.value)

  const login = async (email: string, password: string) => {
    const config = useRuntimeConfig()
    // Todo
    // const apiUrl = config.public.apiUrl || "http://platform.localhost"
    const apiUrl = "http://platform.localhost"

    const response = await $fetch<{
      id: string
      username: string
      email: string
      profile_picture: string
      slug: string
    }>(`${apiUrl}/login`, {
      method: 'POST',
      body: {
        email,
        password
      },
      credentials: 'include'
    })

    // Store user data in state only
    user.value = {
      id: response.id,
      username: response.username,
      email: response.email,
      profilePicture: response.profile_picture,
      slug: response.slug
    }

    return response
  }

  const logout = async () => {
    const config = useRuntimeConfig()
    // Todo
    const apiUrl = config.public.apiUrl || "http://platform.localhost"

    // Call backend to clear cookie
    await $fetch(`${apiUrl}/logout`, {
      method: 'POST',
      credentials: 'include'
    })

    user.value = null
  }

  const checkSession = async () => {
    const config = useRuntimeConfig()
    // Todo
    const apiUrl = config.public.apiUrl || "http://platform.localhost"

    try {
      const response = await $fetch<{
        id: string
        username: string
        email: string
        profile_picture: string
        slug: string
      }>(`${config.public.apiUrl}/me`, {
        method: 'GET',
        credentials: 'include'
      })

      user.value = {
        id: response.id,
        username: response.username,
        email: response.email,
        profilePicture: response.profile_picture,
        slug: response.slug
      }

      return true
    } catch (error) {
      // Session invalide ou expirée
      user.value = null
      return false
    }
  }

  return {
    user: readonly(user),
    isAuthenticated,
    login,
    logout,
    checkSession
  }
}

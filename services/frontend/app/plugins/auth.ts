export default defineNuxtPlugin(async () => {
  const { checkSession } = useAuth()

  if (import.meta.client) {
    await checkSession()
  }
})

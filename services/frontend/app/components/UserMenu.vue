<script setup lang="ts">
const { user, isAuthenticated, logout } = useAuth()

const handleLogout = () => {
  logout()
  navigateTo('/login')
}
</script>

<template>
  <div v-if="isAuthenticated" class="flex items-center gap-4">
    <span class="text-sm">{{ user?.email }}</span>
    <UButton
      color="neutral"
      variant="ghost"
      icon="i-lucide-log-out"
      @click="handleLogout"
    >
      Déconnexion
    </UButton>
  </div>
  <div v-else>
    <UButton
      to="/login"
      color="neutral"
      variant="outline"
      icon="i-lucide-log-in"
    >
      Connexion
    </UButton>
  </div>
</template>

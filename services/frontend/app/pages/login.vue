<script setup lang="ts">
import { z } from "zod"
import type { FormSubmitEvent } from "#ui/types"

definePageMeta({
  middleware: 'guest'
})

const schema = z.object({
  email: z.email("Adresse email invalide"),
  password: z.string().min(8, "Le mot de passe doit contenir au moins 8 caractères")
})

type Schema = z.output<typeof schema>

const state = reactive({
  email: undefined,
  password: undefined
})

const loading = ref(false)
const error = ref<string | null>(null)
const { login } = useAuth()

async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true
  error.value = null

  try {
    await login(event.data.email, event.data.password)

    // Redirect to home page
    await navigateTo("/")
  } catch (err: any) {
    console.error("Login failed", err)
    error.value = err.data?.error || "Échec de la connexion. Veuillez vérifier vos identifiants."
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="text-center">
          <h1 class="text-2xl font-bold">Connexion</h1>
          <p class="text-gray-500 dark:text-gray-400 mt-2">
            Connectez-vous à votre compte
          </p>
        </div>
      </template>

      <UForm
        :schema="schema"
        :state="state"
        @submit="onSubmit"
        class="space-y-4"
      >
        <UFormField label="Email" name="email" required>
          <UInput
            v-model="state.email"
            class="flex"
            type="email"
            placeholder="votre@email.com"
            icon="i-lucide-mail"
            size="lg"
            :disabled="loading"
          />
        </UFormField>

        <UFormField label="Mot de passe" name="password" required>
          <UInput
            v-model="state.password"
            class="flex"
            type="password"
            placeholder="••••••••••••••••"
            icon="i-lucide-lock"
            size="lg"
            :disabled="loading"
          />
        </UFormField>

        <UAlert
          color="error"
          v-if="error"
          variant="soft"
          :title="error"
          icon="i-lucide-alert-circle"
        />

        <div class="flex flex-col gap-2">
          <UButton
            type="submit"
            size="lg"
            block
            :loading="loading"
            :disabled="loading"
          >
            Se connecter
          </UButton>

          <UButton
            to="/"
            color="neutral"
            variant="ghost"
            size="lg"
            block
            :disabled="loading"
          >
            Retour
          </UButton>
        </div>
      </UForm>
    </UCard>
  </div>
</template>

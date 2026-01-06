<script lang="ts">
  import { enhance } from "$app/forms"
  import type { PageProps } from "./$types"

  let { data, form }: PageProps = $props()
</script>

<h1>Connexion</h1>

<div class="w-full max-w-xs">
  <form class="dark:bg-gray-900 rounded px-8 pt-6 pb-8 mb-4" method="POST" use:enhance>
    <div class="mb-4">
      <label class="block dark:text-white text-sm font-bold mb-2" for="email">
        Adresse e-mail
      </label>
      <input
        class="shadow appearance-none border rounded w-full py-2 px-3 dark:text-black leading-tight focus:shadow-outline"
        placeholder="Adresse e-mail"
        id="email" type="email" name="email" required
      />

      <label class="block dark:text-white text-sm font-bold mb-2" for="password">
        Mot de passe
      </label>
      <!-- Todo: correct error handling -->
      <input
        class="shadow appearance-none border rounded w-full py-2 px-3
        dark:text-black leading-tight focus:shadow-outline
        {form?.error ? 'border-red-500' : ''}"
        placeholder="************"
        id="password" type="password" name="password" required
      />

      <div class="flex items-center justify-between">
        <button onclick={() => console.log(form)} class="bg-blue-950 hover:bg-blue-900 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline cursor-pointer" type="submit">
          Connexion
        </button>
<!--        <a class="inline-block align-baseline font-bold text-sm text-blue-500 hover:text-blue-800" href="#">-->
<!--          Mot de passe oublié ?-->
<!--        </a>-->
      </div>
    </div>
  </form>
</div>

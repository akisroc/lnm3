// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    '@nuxt/ui'
  ],

  devtools: {
    enabled: true
  },

  vite: {
    server: {
      hmr: {
        protocol: "ws",
        host: "localhost",
        port: 80
      },
      watch: {
        usePolling: true
      }
    }
  },

  css: ['~/assets/css/main.css'],

  routeRules: {
    '/': { prerender: true }
  },

  compatibilityDate: '2025-01-15',

  eslint: {
    config: {
      stylistic: {
        commaDangle: 'never',
        braceStyle: '1tbs'
      }
    }
  },

  runtimeConfig: {
    platformUrlInternal: "",
    archiveUrlInternal: "",
    public: {
      platformUrl: "",
      archiveUrl: ""
    }
  }
})

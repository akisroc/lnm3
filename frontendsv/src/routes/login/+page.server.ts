import { fail, redirect } from "@sveltejs/kit"
import type { Actions } from "./$types"

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData()
    const email = data.get("email")
    const password = data.get("password")

    console.log("Salut")
    if (!email) { return fail(400, { email, missing: true }) }
    if (!password) { return fail(400, { password, missing: true }) }

    const response = await fetch("http://localhost:4000/api/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    })

    const result = await response.json()

    if (!response.ok) {
      return fail(401, { error: result.error || "Identifiants invalides" })
    }

    cookies.set("session_token", result.token, {
      path: "/",
      httpOnly: true,
      sameSite: "strict",
      secure: process.env.NODE_ENV === "production",
      maxAge: 60 * 60 * 24 * 120  // Todo: get expires_at from server
    })

    throw redirect(303, "/")
  }
}

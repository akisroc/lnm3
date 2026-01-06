// import type { Handle } from "@sveltejs/kit"
//
// export const handle: Handle = async ({ event, resolve }) => {
//   const token = event.cookies.get("session_token")
//
//   if (token) {
//     const userResponse = await fetch('http://localhost:4000/api/me', {
//       headers: { 'Authorization': `Bearer ${token}` }
//     });
//
//     if (userResponse.ok) {
//       event.locals.user = await userResponse.json();
//     }
//   }
// }

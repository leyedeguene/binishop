import { defineMiddlewares } from "@medusajs/framework/http"
import { authenticate } from "@medusajs/framework"

/**
 * BINISHOP - Middlewares globaux (Sécurité backend-first, règle #94).
 *
 * - Toutes les routes /admin/* exigent un utilisateur authentifié
 *   (session cookie OU bearer JWT). Le backend refuse lui-même les
 *   requêtes non autorisees, Flutter ne fait que masquer l'UI.
 * - Les routes /store/* restent publiques (catalogue, panier guest)
 *   ; les fonctionnalites utilisateur-specificques verifient
 *   individuellement l'identite (ex: wishlist).
 */
export default defineMiddlewares({
  routes: [
    {
      matcher: "/admin/*",
      middlewares: [authenticate("user", ["session", "bearer"])],
    },
    {
      matcher: "/store/*",
      middlewares: [],
    },
    {
      matcher: "/auth/*",
      middlewares: [],
    },
  ],
})

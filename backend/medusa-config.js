/**
 * ==========================================
 * BINISHOP - Configuration Medusa.js v2
 * ==========================================
 * Format officiel v2 avec defineConfig.
 */

require("dotenv").config()

const { defineConfig } = require("@medusajs/framework/utils")

const CORS_ORIGINS =
  process.env.STORE_CORS ||
  "http://localhost:8000,http://localhost:3000,http://localhost:5173"

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    http: {
      storeCors: CORS_ORIGINS,
      adminCors: CORS_ORIGINS,
      authCors: CORS_ORIGINS,
      jwtSecret:
        process.env.JWT_SECRET || "binishop_jwt_secret_dev_2026_super_secret",
      cookieSecret:
        process.env.COOKIE_SECRET ||
        "binishop_cookie_secret_dev_2026",
    },
  },

  /**
   * Modules.
   * Les modules core (product, cart, order, customer...) sont
   * charges automatiquement. On declare ici le module file
   * (provider S3 -> MinIO) et le module payment avec notre
   * provider de paiement TEST local.
   */
  modules: [
    {
      resolve: "@medusajs/file",
      options: {
        providers: [
          {
            resolve: "@medusajs/file-s3",
            id: "minio",
            options: {
              // forcePathStyle = true → URL format: http://host/bucket/key (pas bucket.host)
              // Cela évite le bug DNS "binishop-media.localhost"
              bucket: process.env.MINIO_BUCKET || "binishop-media",
              region: process.env.MINIO_REGION || "eu-west-1",
              access_key_id:
                process.env.MINIO_ACCESS_KEY || "binishop_admin",
              secret_access_key:
                process.env.MINIO_SECRET_KEY ||
                "binishop_minio_secret_key_2026",
              file_url:
                process.env.MINIO_PUBLIC_URL ||
                "http://localhost:9000",
              prefix: "uploads/",
              // Endpoint complet AVEC schéma, passé au S3Client via
              // additional_client_config (voie documentée du module
              // @medusajs/file-s3). Le SDK AWS exige une URL absolue :
              // "localhost" seul => ERR_INVALID_URL.
              additional_client_config: {
                forcePathStyle: true,
                endpoint:
                  process.env.MINIO_ENDPOINT || "http://localhost:9000",
              },
            },
          },
        ],
      },
    },
    {
      resolve: "@medusajs/medusa/fulfillment",
      options: {
        providers: [
          {
            resolve: "@medusajs/medusa/fulfillment-manual",
            id: "manual",
          },
        ],
      },
    },
    {
      resolve: "@medusajs/payment",
      options: {
        providers: [
          {
            resolve: "./src/modules/payment-test",
            id: "payment-test",
            options: {
              testMode: true,
            },
          },
          /**
           * Provider Stripe (official @medusajs/payment-stripe v2).
           * Charge uniquement si STRIPE_API_KEY est defini dans .env.
           * En local sans cle Stripe, le provider payment-test reste
           * le seul actif (aucune transaction reelle).
           */
          ...(process.env.STRIPE_API_KEY
            ? [
                {
                  resolve: "@medusajs/payment-stripe",
                  id: "stripe",
                  options: {
                    api_key: process.env.STRIPE_API_KEY,
                  },
                },
              ]
            : []),
        ],
      },
    },
    /**
     * Module custom BINISHOP : blocs de homepage dynamiques.
     * Le contenu commercial est cree par l'administrateur (zero seed).
     */
    {
      resolve: "./src/modules/homepage",
    },
  ],

  plugins: [],
})
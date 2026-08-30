/**
 * ==========================================
 * BINISHOP — Route API: Health Check
 * ==========================================
 * GET /custom/health — vérification de disponibilité.
 */

import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"

export async function GET(
  req: MedusaRequest,
  res: MedusaResponse
) {
  try {
    // Verifier la connexion base de donnees via le module product
    const productModuleService = req.scope.resolve("product")
    await productModuleService.listProducts({}, { take: 1 })

    res.status(200).json({
      status: "ok",
      service: "binishop-backend",
      database: "connected",
      timestamp: new Date().toISOString(),
    })
  } catch (_error) {
    res.status(503).json({
      status: "degraded",
      service: "binishop-backend",
      database: "unavailable",
      timestamp: new Date().toISOString(),
    })
  }
}
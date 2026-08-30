/**
 * ==========================================
 * BINISHOP — Seed technique (Medusa v2)
 * ==========================================
 * STRICTEMENT limite aux donnees techniques :
 *
 *  1. Region "Europe" avec devise EUR et pays UE
 *
 * AUCUNE donnee commerciale :
 *   pas de produits, pas de clients, pas de commandes,
 *   pas de promotions, pas d'images, pas de collections.
 *
 * Execution : npx medusa exec ./src/scripts/seed.ts
 */

import {
  ContainerRegistrationKeys,
} from "@medusajs/framework/utils"
import {
  createRegionsWorkflow,
} from "@medusajs/medusa/core-flows"

// Type local (meme forme que ExecArgs de la CLI v2)
type ExecArgs = {
  container: any
  args: string[]
}

export default async function seedTechnicalData({
  container,
}: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)

  logger.info("BINISHOP: Debut du seed technique...")
  logger.info("BINISHOP: Aucune donnee commerciale ne sera creee.")

  const regionModuleService = container.resolve("region")

  // -------------------------------------------------
  // Verifier si une region existe deja
  // -------------------------------------------------
  const existingRegions = await regionModuleService.listRegions({}, {})

  if (existingRegions.length > 0) {
    logger.info(
      `BINISHOP: ${existingRegions.length} region(s) deja presente(s) — aucune creation.`
    )
    logger.info("BINISHOP: Seed termine.")
    return
  }

  // -------------------------------------------------
  // Creer la region Europe par defaut (devise EUR)
  // -------------------------------------------------
  try {
    await createRegionsWorkflow(container).run({
      input: {
        regions: [
          {
            name: "Europe",
            currency_code: "eur",
            countries: ["fr", "be", "de", "es", "it", "pt", "nl", "lu"],
          },
        ],
      },
    })
    logger.info("BINISHOP: Region 'Europe' creee (devise EUR).")
  } catch (error) {
    logger.error(`BINISHOP: Erreur creation region: ${error.message}`)
    throw error
  }

  logger.info("=========================================")
  logger.info("BINISHOP: Seed technique termine.")
  logger.info("BINISHOP: La boutique est vide cote commercial.")
  logger.info(
    "BINISHOP: Creez le compte admin via: npx medusa user --email <email> --password <password>"
  )
  logger.info("=========================================")
}
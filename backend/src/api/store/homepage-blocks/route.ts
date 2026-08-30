import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import HomepageModuleService from "../../../modules/homepage/service"

/**
 * GET /store/homepage-blocks
 * Lecture publique des blocs actifs de la homepage (triés par rank croissant).
 * Aucune donnée fictive : renvoie [] tant que l'administrateur n'a rien créé.
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")
  const blocks = await homepageService.listHomepageBlocks(
    { isActive: true },
    { order: { rank: "ASC" }, take: 50 }
  )
  res.json({ homepage_blocks: blocks })
}

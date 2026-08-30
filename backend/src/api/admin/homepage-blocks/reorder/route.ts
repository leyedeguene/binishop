import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import HomepageModuleService from "../../../../modules/homepage/service"

/** POST /admin/homepage-blocks/reorder — réordonne les blocs */
export async function POST(req: AuthenticatedMedusaRequest, res: MedusaResponse) {
  const body = (req.body ?? {}) as { items?: { id: string; rank: number }[] }
  const items = body.items ?? []
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: "items array required" })
  }
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")
  for (const item of items) {
    await homepageService.updateHomepageBlocks({
      id: item.id,
      rank: Number(item.rank) || 0,
    } as never)
  }
  const blocks = await homepageService.listHomepageBlocks(
    {},
    { order: { rank: "ASC" }, take: 100 }
  )
  res.json({ homepage_blocks: blocks })
}

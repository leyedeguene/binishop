import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import HomepageModuleService from "../../../modules/homepage/service"

/**
 * GET /admin/homepage-blocks — liste tous les blocs (actifs et inactifs).
 * POST /admin/homepage-blocks — crée un bloc.
 */
const ALLOWED_TYPES = [
  "hero",
  "banner",
  "collection",
  "category",
  "featured_products",
  "new_arrivals",
  "bestsellers",
  "promotion",
  "text_block",
  "image_block",
  "cta_block",
]

export async function GET(req: AuthenticatedMedusaRequest, res: MedusaResponse) {
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")
  const blocks = await homepageService.listHomepageBlocks(
    {},
    { order: { rank: "ASC" }, take: 100 }
  )
  res.json({ homepage_blocks: blocks })
}

export async function POST(req: AuthenticatedMedusaRequest, res: MedusaResponse) {
  const body = (req.body ?? {}) as Record<string, unknown>
  const type = String(body.type ?? "")
  if (!ALLOWED_TYPES.includes(type)) {
    return res.status(400).json({ message: `Invalid block type "${type}"` })
  }
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")
  // rank par défaut = dernier rang pour apparaître en fin de page
  const existing = await homepageService.listHomepageBlocks({}, { take: 100 })
  const maxRank = existing.reduce((max, b) => Math.max(max, Number(b.rank) || 0), 0)

  const created = await homepageService.createHomepageBlocks({
    type,
    title: (body.title as string) ?? null,
    subtitle: (body.subtitle as string) ?? null,
    description: (body.description as string) ?? null,
    imageUrl: (body.image_url as string) ?? null,
    linkUrl: (body.link_url as string) ?? null,
    ctaLabel: (body.cta_label as string) ?? null,
    referenceId: (body.reference_id as string) ?? null,
    productIds: (body.product_ids as string[]) ?? null,
    rank: typeof body.rank === "number" ? body.rank : maxRank + 10,
    isActive: body.is_active !== false,
    metadata: (body.metadata as Record<string, unknown>) ?? null,
  } as never)

  return res.status(201).json({ homepage_block: Array.isArray(created) ? created[0] : created })
}

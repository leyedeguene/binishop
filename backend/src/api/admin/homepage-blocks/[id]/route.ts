import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import HomepageModuleService from "../../../../modules/homepage/service"

/** PUT /admin/homepage-blocks/:id — met à jour partielle d'un bloc */
export async function PUT(req: AuthenticatedMedusaRequest, res: MedusaResponse) {
  const { id } = req.params
  const body = (req.body ?? {}) as Record<string, unknown>
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")

  const patch: Record<string, unknown> = {}
  const stringFields = ["title", "subtitle", "description", "image_url", "link_url", "cta_label", "reference_id"]
  const patchKeys: Record<string, string> = {
    title: "title",
    subtitle: "subtitle",
    description: "description",
    image_url: "imageUrl",
    link_url: "linkUrl",
    cta_label: "ctaLabel",
    reference_id: "referenceId",
  }
  for (const f of stringFields) {
    if (f in body) patch[patchKeys[f]] = body[f]
  }
  if ("product_ids" in body) patch.productIds = body.product_ids
  if ("rank" in body) patch.rank = Number(body.rank) || 0
  if ("is_active" in body) patch.isActive = Boolean(body.is_active)
  if ("type" in body) patch.type = String(body.type)
  if ("metadata" in body) patch.metadata = body.metadata

  const updated = await homepageService.updateHomepageBlocks({ id, ...patch } as never)
  res.json({ homepage_block: Array.isArray(updated) ? updated[0] : updated })
}

/** DELETE /admin/homepage-blocks/:id */
export async function DELETE(req: AuthenticatedMedusaRequest, res: MedusaResponse) {
  const { id } = req.params
  const homepageService: HomepageModuleService = req.scope.resolve("homepage")
  await homepageService.deleteHomepageBlocks([id])
  res.status(200).json({ id, deleted: true })
}

import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import type {
  ICustomerModuleService,
  IOrderModuleService,
  IProductModuleService,
} from "@medusajs/framework/types"
import {
  ContainerRegistrationKeys,
  MedusaError,
} from "@medusajs/framework/utils"

/**
 * GET /admin/analytics?period=today|7d|30d|3m|12m
 *
 * Statistiques du dashboard admin calculees UNIQUEMENT a partir des
 * donnees reelles persistees dans PostgreSQL (regle ZERO FAUSSE DONNEE).
 *
 * - revenue        : somme des totaux des commandes non annulees sur la periode
 * - orders         : nombre de commandes sur la periode (+ repartition statuts)
 * - customers      : nombre total de clients reels
 * - products       : nombre de produits publies reels
 * - top_products   : classement reel calcule depuis les line items des commandes
 * - recent_orders  : dernieres commandes reelles
 *
 * NOTE (#97 transparence) : l'alerte "stock faible" n'est PAS exposee ici
 * car elle depend des liens cross-modules inventory <-> variants dont les
 * contrats exacts doivent etre valides par sonde avant implementation.
 * Elle sera ajoutee dans une iteration suivante, jamais simulee.
 */

type AnalyticsQuery = { period?: string }

const PERIOD_DAYS: Record<string, number | null> = {
  today: 0,
  "7d": 7,
  "30d": 30,
  "3m": 90,
  "12m": 365,
}

function resolvePeriod(raw?: string): Date | null {
  if (!raw || raw === "all") return null
  const days = PERIOD_DAYS[raw]
  if (days === undefined) return null
  if (days === 0) {
    const start = new Date()
    start.setHours(0, 0, 0, 0)
    return start
  }
  const start = new Date()
  start.setDate(start.getDate() - days)
  start.setHours(0, 0, 0, 0)
  return start
}

export const GET = async (
  req: AuthenticatedMedusaRequest<AnalyticsQuery>,
  res: MedusaResponse
) => {
    const logger = req.scope.resolve(ContainerRegistrationKeys.LOGGER)

  // Normalisation du parametre query (ParsedQs-safe).
  // Regle ZERO FAUSSE DONNEE : typage strict cote backend, jamais de valeur
  // commerciale fictive ici, les stats proviennent uniquement de PostgreSQL.
  const rawPeriod = req.query.period
  const period: string | undefined =
      typeof rawPeriod === "string"
        ? rawPeriod
        : Array.isArray(rawPeriod) && typeof rawPeriod[0] === "string"
        ? rawPeriod[0]
        : undefined

  if (period && !PERIOD_DAYS[period]) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Periode invalide. Valeurs acceptees: ${Object.keys(PERIOD_DAYS).join(", ")}`
    )
  }

  const sinceDate = resolvePeriod(period)

  logger.info(`[admin/analytics] period=${period ?? "all"}`)

  const orderService = req.scope.resolve<IOrderModuleService>("order")
  const customerService =
    req.scope.resolve<ICustomerModuleService>("customer")
  const productService = req.scope.resolve<IProductModuleService>("product")

  // ---- Commandes sur la periode (donnees reelles) ----
  const [ordersInPeriod, ordersInPeriodCount] =
    await orderService.listAndCountOrders(
      sinceDate
        ? { created_at: { $gte: sinceDate.toISOString() } }
        : {},
      {
        select: [
          "id",
          "display_id",
          "email",
          "total",
          "subtotal",
          "discount_total",
          "shipping_total",
          "tax_total",
          "currency_code",
          "status",
          "payment_status",
          "fulfillment_status",
          "created_at",
        ],
        relations: ["items"],
        take: 10000,
        order: { created_at: "DESC" },
      }
    )

  // CA reel = somme des totaux des commandes non annulees
  let revenue = 0
  for (const o of ordersInPeriod) {
    if (o.status !== "canceled") {
      revenue += Number(o.total ?? 0)
    }
  }

  // Repartition par statut (reelle)
  const statusBreakdown: Record<string, number> = {}
  for (const o of ordersInPeriod) {
    statusBreakdown[o.status] = (statusBreakdown[o.status] ?? 0) + 1
  }

  // ---- Top produits calcule depuis les line items reels ----
  const unitsByProduct = new Map<
    string,
    { product_id: string | null; title: string; units: number; revenue: number }
  >()
  for (const o of ordersInPeriod) {
    if (o.status === "canceled") continue
    for (const item of o.items ?? []) {
      const key = item.product_id ?? item.title
      const entry = unitsByProduct.get(key) ?? {
        product_id: item.product_id ?? null,
        title: item.product_title ?? item.title,
        units: 0,
        revenue: 0,
      }
      entry.units += item.quantity
      entry.revenue += Number(item.unit_price ?? 0) * item.quantity
      unitsByProduct.set(key, entry)
    }
  }
  const topProducts = Array.from(unitsByProduct.values())
    .sort((a, b) => b.units - a.units)
    .slice(0, 20)

  // ---- Clients et produits publies (reels) ----
  const [, customersTotal] = await customerService.listAndCountCustomers({})
  const [, productsPublished] = await productService.listAndCountProducts({
    status: "published",
  })
  const [, productsTotal] = await productService.listAndCountProducts({})

  res.json({
    period: period ?? "all",
    generated_at: new Date().toISOString(),
    overview: {
      revenue,
      orders_count: ordersInPeriodCount,
      orders_status_breakdown: statusBreakdown,
      customers_total: customersTotal,
      products_published: productsPublished,
      products_total: productsTotal,
    },
    top_products: topProducts,
    recent_orders: ordersInPeriod.slice(0, 10),
  })

  void logger
}

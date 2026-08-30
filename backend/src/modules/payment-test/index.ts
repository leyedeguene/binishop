/**
 * ==========================================
 * BINISHOP — Module Provider: Payment Test
 * ==========================================
 * Enregistre le provider de paiement TEST auprès
 * du module Payment de Medusa v2.
 */

import { ModuleProvider, Modules } from "@medusajs/framework/utils"
import PaymentTestProviderService from "./service"

export default ModuleProvider(Modules.PAYMENT, {
  services: [PaymentTestProviderService],
})
/**
 * ==========================================
 * BINISHOP — Payment Provider TEST (v2)
 * ==========================================
 * Provider de paiement pour environnement LOCAL uniquement.
 *
 * - Aucune transaction financiere reelle.
 * - Autorise automatiquement les paiements de test.
 * - Signatures conformes a @medusajs/types v2.19.0.
 */

import { AbstractPaymentProvider } from "@medusajs/framework/utils"
import {
  CapturePaymentInput,
  CapturePaymentOutput,
  CancelPaymentInput,
  CancelPaymentOutput,
  DeletePaymentInput,
  DeletePaymentOutput,
  InitiatePaymentInput,
  InitiatePaymentOutput,
  AuthorizePaymentInput,
  AuthorizePaymentOutput,
  RefundPaymentInput,
  RefundPaymentOutput,
  RetrievePaymentInput,
  RetrievePaymentOutput,
  GetPaymentStatusInput,
  GetPaymentStatusOutput,
  UpdatePaymentInput,
  UpdatePaymentOutput,
  ProviderWebhookPayload,
  WebhookActionResult,
} from "@medusajs/framework/types"

type Options = {
  testMode?: boolean
}

class PaymentTestProviderService extends AbstractPaymentProvider<Options> {
  protected logger_: any
  static identifier = "payment-test"

  constructor(container: Record<string, unknown>, options: Options) {
    super(container as any, options)
    this.logger_ = (container as any).logger
  }

  /**
   * Identifiant du provider — requis par l'interface abstraite.
   */
  getIdentifier(): string {
    return "payment-test"
  }

  async initiatePayment(
    input: InitiatePaymentInput
  ): Promise<InitiatePaymentOutput> {
    const sessionId = `test_${Date.now()}_${Math.random()
      .toString(36)
      .slice(2, 10)}`

    return {
      id: sessionId,
      data: {
        test_mode: true,
        provider: "payment-test",
        initiated_at: new Date().toISOString(),
      },
    }
  }

  async updatePayment(data: UpdatePaymentInput): Promise<UpdatePaymentOutput> {
    return { data: data.data ?? {} }
  }

  async authorizePayment(
    data: AuthorizePaymentInput
  ): Promise<AuthorizePaymentOutput> {
    // Mode test : autorisation automatique, aucun appel externe.
    return { status: "authorized", data: data.data ?? {} }
  }

  async capturePayment(data: CapturePaymentInput): Promise<CapturePaymentOutput> {
    return { data: { ...(data.data ?? {}), captured: true } }
  }

  async refundPayment(data: RefundPaymentInput): Promise<RefundPaymentOutput> {
    return { data: { ...(data.data ?? {}), refunded: true } }
  }

  async retrievePayment(
    data: RetrievePaymentInput
  ): Promise<RetrievePaymentOutput> {
    return { data: data.data ?? {} }
  }

  async cancelPayment(data: CancelPaymentInput): Promise<CancelPaymentOutput> {
    return { data: { ...(data.data ?? {}), canceled: true } }
  }

  async deletePayment(data: DeletePaymentInput): Promise<DeletePaymentOutput> {
    return { data: {} }
  }

  async getPaymentStatus(
    data: GetPaymentStatusInput
  ): Promise<GetPaymentStatusOutput> {
    return { status: "pending" }
  }

  async getWebhookActionAndData(
    data: ProviderWebhookPayload["payload"]
  ): Promise<WebhookActionResult> {
    return { action: "not_supported" }
  }
}

export default PaymentTestProviderService
/**
 * BINISHOP - Creation de la Publishable API Key (store front)
 * Execution : npx medusa exec ./src/scripts/create-pubkey.ts
 */

import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import {
  createApiKeysWorkflow,
} from "@medusajs/medusa/core-flows"

type ExecArgs = {
  container: any
  args: string[]
}

export default async function createPublishableKey({
  container,
}: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)

  const { result } = await createApiKeysWorkflow(container).run({
    input: {
      title: "binishop-store-front-" + Date.now(),
      type: "publishable",
      created_by: "setup-script",
    },
  })

  logger.info("=========================================")
  logger.info(`BINISHOP: Publishable API Key creee:`)
  logger.info(`${result.token}`)
  logger.info("=========================================")
}
import { MedusaService } from "@medusajs/framework/utils"
import { HomepageBlock } from "./models/homepage-block"

class HomepageModuleService extends MedusaService({ HomepageBlock }) {}

export default HomepageModuleService

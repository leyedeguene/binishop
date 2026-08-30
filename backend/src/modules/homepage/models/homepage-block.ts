import { model } from "@medusajs/framework/utils"

/**
 * Bloc de page d'accueil dynamique.
 * Le contenu commercial est entièrement créé par l'administrateur depuis l'app Flutter Admin.
 * Aucun bloc n'est seedé automatiquement (règle ZÉRO FAUSSE DONNÉE).
 */
export const HomepageBlock = model
  .define("homepage_block", {
    id: model.id().primaryKey(),
    /** hero | banner | collection | category | featured_products | new_arrivals | bestsellers | promotion | text_block | image_block | cta_block */
    type: model.text(),
    title: model.text().nullable(),
    subtitle: model.text().nullable(),
    description: model.text().nullable(),
    imageUrl: model.text().nullable(),
    linkUrl: model.text().nullable(),
    ctaLabel: model.text().nullable(),
    /** Id de référence quand le bloc pointe vers une entité Medusa (collection, catégorie, promotion...) */
    referenceId: model.text().nullable(),
    /** Liste d'ids produits pour le bloc "featured_products" (jsonb) */
    productIds: model.json().nullable(),
    /** Ordre d'affichage sur la homepage */
    rank: model.number().default(0),
        isActive: model.boolean().default(true),
    metadata: model.json().nullable(),
  })

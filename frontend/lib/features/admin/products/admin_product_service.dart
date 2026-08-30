/// BINISHOP — Admin Product Service
/// Endpoints produits de l'API Admin Medusa v2 :
///   GET    /admin/products            — liste paginée
///   POST   /admin/products            — création (options+variantes+images en 1 appel)
///   POST   /admin/products/:id        — mise à jour (v2 utilise POST, pas PUT)
///   DELETE /admin/products/:id        — suppression
///   POST   /admin/file                — upload multipart (stream MinIO backend)
///
/// Les widgets ne font JAMAIS d'appels HTTP directement (règle #56).
library features.admin.products.admin_product_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class AdminProductService {
  final ApiClient _api;

  AdminProductService(this._api);

  // --- Products — Lecture ---

  /// Liste paginée des produits. `page` commence à 1 (converti en offset).
  /// Ne charge JAMAIS tout le catalogue en une requête (règle #95).
  Future<ApiResult<Map<String, dynamic>>> getProducts({
    int page = 1,
    int limit = ApiConstants.defaultPageSize,
    String? q,
    String? status,
    String order = '-created_at',
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminProducts,
      queryParameters: {
        'offset': (page - 1) * limit,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
        if (status != null && status.isNotEmpty) 'status': status,
        'order': order,
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getProduct(String id) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.adminProducts}/$id',
      queryParameters: const {
        'fields': '*variants.calculated_price,*images,*options,*options.values',
      },
    );
  }

  // --- Products — Écriture ---

  /// Création complète d'un produit : options, variantes, prix et images
  /// peuvent être envoyés en un seul appel (format Medusa v2).
  Future<ApiResult<Map<String, dynamic>>> createProduct(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.adminProducts, data: data);
  }

  /// Mise à jour d'un produit — Medusa v2 utilise POST pour les updates.
  /// Sert aussi pour publier (status: "published") / dépublier ("draft").
  Future<ApiResult<Map<String, dynamic>>> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminProducts}/$id',
      data: data,
    );
  }

  /// Publication / dépublication du produit (brouillon ↔ publié).
  Future<ApiResult<Map<String, dynamic>>> updateProductStatus(
    String id, {
    required bool published,
  }) {
    return updateProduct(id, {'status': published ? 'published' : 'draft'});
  }

  /// Duplication : lit le produit source et crée une copie en brouillon.
  /// Aucune donnée inventée — uniquement les champs réels du produit source.
  Future<ApiResult<Map<String, dynamic>>> duplicateProduct(
    String id, {
    String? newTitle,
  }) async {
    final source = await getProduct(id);
    final product = source.data?['product'];
    if (product is! Map<String, dynamic>) {
      return (
        data: null,
        error: source.error ?? 'Produit introuvable',
        statusCode: source.statusCode,
      );
    }
    final payload = <String, dynamic>{
      'title': newTitle ?? '${product['title']} (copie)',
      'status': 'draft',
      if (product['subtitle'] != null) 'subtitle': product['subtitle'],
      if (product['description'] != null) 'description': product['description'],
      if (product['collection_id'] != null)
        'collection_id': product['collection_id'],
      if (product['category_ids'] != null)
        'category_ids': product['category_ids'],
      if (product['images'] != null)
        'images': (product['images'] as List)
            .whereType<Map>()
            .map((e) => {'url': e['url']})
            .toList(),
    };
    return createProduct(payload);
  }

  Future<ApiResult<Map<String, dynamic>>> deleteProduct(String id) async {
    return _api.delete<Map<String, dynamic>>('${ApiConstants.adminProducts}/$id');
  }

  // --- Variantes ---

  Future<ApiResult<Map<String, dynamic>>> createVariant(
    String productId,
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminProducts}/$productId/variants',
      data: data,
    );
  }

  /// Mise à jour variante (SKU, prix, stock…) — POST en v2.
  /// `inventory_quantity` met à jour réellement le stock via l'Inventory Module.
  Future<ApiResult<Map<String, dynamic>>> updateVariant(
    String productId,
    String variantId,
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminProducts}/$productId/variants/$variantId',
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteVariant(
    String productId,
    String variantId,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.adminProducts}/$productId/variants/$variantId',
    );
  }

  // --- Media ---

  /// Upload multipart des fichiers vers Medusa (POST /admin/file).
  /// Le backend stream vers MinIO via le provider file-s3 — les credentials
  /// MinIO ne quittent JAMAIS le backend (règle sécurité #15).
  /// Retourne la liste `{ id, url, filename, mime_type, size }` des fichiers.
  Future<ApiResult<Map<String, dynamic>>> uploadFiles(List<UploadFile> files) {
    return _api.uploadFiles<Map<String, dynamic>>(
      ApiConstants.adminFile,
      files: files,
    );
  }

  /// Associe des images (URLs MinIO retournées par uploadFiles) au produit.
  /// Utilise l'update produit v2 : POST /admin/products/:id { images: [...] }.
  Future<ApiResult<Map<String, dynamic>>> attachImagesToProduct(
    String productId,
    List<String> urls, {
    String? thumbnailUrl,
  }) {
    return updateProduct(productId, {
      'images': urls.map((url) => {'url': url}).toList(),
      if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
    });
  }
}
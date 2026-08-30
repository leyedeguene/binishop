/// BINISHOP — API Endpoints Constants
library core.constants.api_constants;

abstract final class ApiConstants {
  // --- Store API ---
  static const String storeProducts = '/store/products';
  static const String storeProductDetail = '/store/products/';  // + id
  static const String storeCategories = '/store/categories';
  static const String storeCollections = '/store/collections';
  static const String storeCarts = '/store/carts';
  static const String storeCart = '/store/carts/';  // + id
  static const String storeOrders = '/store/orders';
  static const String storeOrder = '/store/orders/';  // + id
  static const String storeAuth = '/store/auth';
  static const String storeCustomers = '/store/customers';
  static const String storeWishlist = '/store/wishlist';
  static const String storeBestsellers = '/store/bestsellers';
  static const String storeHomepage = '/store/homepage-blocks';

  // --- Admin API ---
  static const String adminProducts = '/admin/products';
  static const String adminProduct = '/admin/products/';  // + id
  static const String adminCategories = '/admin/categories';
  static const String adminCategory = '/admin/categories/';  // + id
  static const String adminCollections = '/admin/collections';
  static const String adminCollection = '/admin/collections/';  // + id
  static const String adminOrders = '/admin/orders';
  static const String adminOrder = '/admin/orders/';  // + id
  static const String adminCustomers = '/admin/customers';
  static const String adminCustomer = '/admin/customers/';  // + id
  static const String adminUsers = '/admin/users';
  /// Upload de fichiers — endpoint Medusa v2 (multipart "files").
  /// Les fichiers sont streamés vers MinIO par le backend (file-s3).
  static const String adminFile = '/admin/file';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminHomepage = '/admin/homepage-blocks';
  static const String adminPromotions = '/admin/discounts';
  static const String adminInventory = '/admin/inventory';
  static const String adminBestsellers = '/admin/bestsellers';

  // --- Pagination ---
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
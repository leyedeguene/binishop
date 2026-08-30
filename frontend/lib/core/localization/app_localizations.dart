/// BINISHOP — Localization
/// Gère les traductions français/anglais.
library core.localization.app_localizations;

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }

  String get languageCode => locale.languageCode;

  // --- Common ---
  String get appName => _t('BINISHOP', 'BINISHOP');
  String get loading => _t('Chargement...', 'Loading...');
  String get error => _t('Erreur', 'Error');
  String get retry => _t('Réessayer', 'Retry');
  String get cancel => _t('Annuler', 'Cancel');
  String get confirm => _t('Confirmer', 'Confirm');
  String get save => _t('Enregistrer', 'Save');
  String get delete => _t('Supprimer', 'Delete');
  String get edit => _t('Modifier', 'Edit');
  String get create => _t('Créer', 'Create');
  String get search => _t('Rechercher', 'Search');
  String get filter => _t('Filtrer', 'Filter');
  String get sort => _t('Trier', 'Sort');
  String get noResults => _t('Aucun résultat', 'No results');
  String get all => _t('Tout', 'All');
  String get back => _t('Retour', 'Back');
  String get next => _t('Suivant', 'Next');

  // --- Auth ---
  String get login => _t('Connexion', 'Login');
  String get register => _t('Inscription', 'Register');
  String get logout => _t('Déconnexion', 'Logout');
  String get email => _t('Email', 'Email');
  String get password => _t('Mot de passe', 'Password');
  String get forgotPassword => _t('Mot de passe oublié ?', 'Forgot password?');
  String get noAccount => _t('Pas de compte ?', 'No account?');
  String get haveAccount => _t('Déjà un compte ?', 'Already have an account?');

  // --- Cart ---
  String get cart => _t('Panier', 'Cart');
  String get addToCart => _t('Ajouter au panier', 'Add to cart');
  String get removeFromCart => _t('Retirer du panier', 'Remove from cart');
  String get emptyCart => _t('Votre panier est vide', 'Your cart is empty');
  String get checkout => _t('Commander', 'Checkout');
  String get total => _t('Total', 'Total');
  String get subtotal => _t('Sous-total', 'Subtotal');
  String get shipping => _t('Livraison', 'Shipping');

  // --- Product ---
  String get products => _t('Produits', 'Products');
  String get outOfStock => _t('Rupture de stock', 'Out of stock');
  String get addToWishlist => _t('Ajouter aux favoris', 'Add to wishlist');
  String get removeFromWishlist => _t('Retirer des favoris', 'Remove from wishlist');
  String get size => _t('Taille', 'Size');
  String get color => _t('Couleur', 'Color');
  String get quantity => _t('Quantité', 'Quantity');
  String get description => _t('Description', 'Description');

  // --- Admin ---
  String get adminDashboard => _t('Dashboard', 'Dashboard');
  String get adminProducts => _t('Produits', 'Products');
  String get adminCategories => _t('Catégories', 'Categories');
  String get adminOrders => _t('Commandes', 'Orders');
  String get adminCustomers => _t('Clients', 'Customers');
  String get adminPromotions => _t('Promotions', 'Promotions');
  String get adminHomepage => _t('Homepage', 'Homepage');
  String get adminSettings => _t('Paramètres', 'Settings');

  // --- Orders ---
  String get orderConfirmed => _t('Confirmée', 'Confirmed');
  String get orderPreparing => _t('En préparation', 'Preparing');
  String get orderShipped => _t('Expédiée', 'Shipped');
  String get orderDelivered => _t('Livrée', 'Delivered');
  String get orderCancelled => _t('Annulée', 'Cancelled');

  // --- Empty States ---
  String get emptyProducts => _t('Aucun produit disponible.', 'No products available.');
  String get emptyProductsAction => _t('Ajoutez votre premier produit.', 'Add your first product.');
  String get emptyOrders => _t('Aucune commande.', 'No orders.');
  String get emptyOrdersDesc => _t('Les commandes apparaîtront ici.', 'Orders will appear here.');
  String get emptyCustomers => _t('Aucun client.', 'No customers.');
  String get emptyMedia => _t('Aucune image.', 'No media.');
  String get emptySales => _t('Aucune donnée de vente.', 'No sales data.');

  String _t(String fr, String en) {
    return languageCode == 'fr' ? fr : en;
  }
}
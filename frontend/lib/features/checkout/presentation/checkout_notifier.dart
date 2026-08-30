/// BINISHOP — Checkout Notifier
/// Orchestration du checkout en 4 etapes :
/// 1. Adresses -> 2. Livraison -> 3. Paiement TEST -> 4. Confirmation.
library features.checkout.presentation.checkout_notifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../../cart/presentation/cart_notifier.dart';

/// Etapes du checkout
enum CheckoutStep { addresses, shipping, payment, confirmation }

/// Adresse saisie par le client
class CheckoutAddress {
  final String email;
  final String firstName;
  final String lastName;
  final String address1;
  final String? address2;
  final String city;
  final String postalCode;
  final String countryCode; // ex: fr
  final String phone;

  const CheckoutAddress({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.address1,
    this.address2,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    this.phone = '',
  });

  Map<String, dynamic> toMedusa() => {
        'first_name': firstName,
        'last_name': lastName,
        'address_1': address1,
        if (address2 != null && address2!.isNotEmpty)
          'address_2': address2,
        'city': city,
        'postal_code': postalCode,
        'country_code': countryCode.toLowerCase(),
        'phone': phone,
      };
}

/// Etat global du checkout
class CheckoutState {
  final CheckoutStep step;
  final bool isLoading;
  final String? error;

  // Etape livraison
  final List<Map<String, dynamic>> shippingOptions;
  final String? selectedShippingOptionId;

  // Etape paiement
  final String? paymentCollectionId;
  final String? paymentSessionId;
  final String paymentProviderId; // pp_payment-test_payment-test

  // Resultat
  final String? orderId;

  const CheckoutState({
    this.step = CheckoutStep.addresses,
    this.isLoading = false,
    this.error,
    this.shippingOptions = const [],
    this.selectedShippingOptionId,
    this.paymentCollectionId,
    this.paymentSessionId,
    this.paymentProviderId = 'pp_payment-test_payment-test',
    this.orderId,
  });

  CheckoutState copyWith({
    CheckoutStep? step,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? shippingOptions,
    String? selectedShippingOptionId,
    String? paymentCollectionId,
    String? paymentSessionId,
    String? orderId,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shippingOptions: shippingOptions ?? this.shippingOptions,
      selectedShippingOptionId:
          selectedShippingOptionId ?? this.selectedShippingOptionId,
      paymentCollectionId: paymentCollectionId ?? this.paymentCollectionId,
      paymentSessionId: paymentSessionId ?? this.paymentSessionId,
      orderId: orderId ?? this.orderId,
    );
  }
}

final checkoutNotifierProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    ref.watch(checkoutServiceProvider),
    () => ref.read(cartNotifierProvider),
  );
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final dynamic _checkoutService;
  final CartState Function() _readCart;

  CheckoutNotifier(this._checkoutService, this._readCart)
      : super(const CheckoutState());

    /// ETAPE 1 : enregistrer email + adresse de livraison
  Future<bool> submitAddresses(CheckoutAddress address) async {
    final cart = _readCart().cart;
    if (cart.id.isEmpty) {
      state = state.copyWith(error: 'Panier introuvable.');
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      final result = await _checkoutService.updateCartAddresses(
        cartId: cart.id,
        email: address.email,
        shippingAddress: address.toMedusa(),
      );

      if (result.data != null) {
        // Charger les options de livraison disponibles
        final options = await _loadShippingOptions(cart.id);
        state = state.copyWith(
          step: CheckoutStep.shipping,
          shippingOptions: options,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(
          isLoading: false, error: result.error ?? 'Adresse refusee.');
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Erreur reseau lors de l\'enregistrement.');
      return false;
    }
  }

  /// Charge les options de livraison pour le panier courant
  Future<List<Map<String, dynamic>>> _loadShippingOptions(String cartId) async {
    final result = await _checkoutService.getShippingOptions(cartId: cartId);
    if (result.data != null && result.data is Map) {
      final data = result.data as Map<String, dynamic>;
      final options = data['shipping_options'];
      if (options != null && options is List) {
        return options.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }

  /// ETAPE 2 : choisir la methode de livraison
  Future<bool> selectShipping(String optionId) async {
    final cart = _readCart().cart;
    if (cart.id.isEmpty) return false;

    state = state.copyWith(isLoading: true);
    try {
      final result = await _checkoutService.addShippingMethod(
        cartId: cart.id,
        optionId: optionId,
      );

      if (result.data != null) {
        // Initialiser la payment collection + session TEST
        await _initPayment();
        state = state.copyWith(selectedShippingOptionId: optionId);
        return true;
      }
      state = state.copyWith(
          isLoading: false, error: result.error ?? 'Erreur livraison.');
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Erreur reseau.');
      return false;
    }
  }

  /// Initialise la collection de paiement + session pour le provider TEST
  Future<void> _initPayment() async {
    final cart = _readCart().cart;
    if (cart.id.isEmpty) return;

        // region_id provient du panier Medusa (cart.regionId)
    final regionId = cart.regionId ?? '';
    if (regionId.isEmpty) {
      state = state.copyWith(step: CheckoutStep.payment, isLoading: false);
      return;
    }

    // Creer la collection de paiement
    final pcResult = await _checkoutService.createPaymentCollection(
      cartId: cart.id,
      regionId: regionId,
    );
    if (pcResult.data == null) {
      state = state.copyWith(
          isLoading: false, error: pcResult.error ?? 'Erreur paiement.');
      return;
    }

    final pcData = pcResult.data as Map<String, dynamic>;
    final collectionId = pcData['id']?.toString() ?? '';

    // Creer la session de paiement via provider TEST
    final psResult = await _checkoutService.createPaymentSession(
      collectionId: collectionId,
      providerId: 'pp_payment-test_payment-test',
    );
    if (psResult.data == null) {
      state = state.copyWith(
          isLoading: false,
          error: psResult.error ?? 'Erreur session paiement.');
      return;
    }

    final psData = psResult.data as Map<String, dynamic>;
    final sessionId = psData['id']?.toString() ?? '';

    state = state.copyWith(
      step: CheckoutStep.payment,
      paymentCollectionId: collectionId,
      paymentSessionId: sessionId,
      isLoading: false,
    );
  }

  /// ETAPE 3 : autoriser le paiement TEST + finaliser
  Future<bool> completePayment() async {
    final cart = _readCart().cart;
    if (cart.id.isEmpty) return false;
    if (state.paymentCollectionId == null || state.paymentSessionId == null) {
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      // Autoriser (provider TEST accepte automatiquement)
      final authResult = await _checkoutService.authorizePaymentSession(
        collectionId: state.paymentCollectionId!,
        sessionId: state.paymentSessionId!,
      );
      if (authResult.data == null) {
        state = state.copyWith(
            isLoading: false,
            error: authResult.error ?? 'Echec autorisation paiement.');
        return false;
      }

      // Finaliser la commande → obtient l'orderId
      final completeResult = await _checkoutService.completeCart(cart.id);
      if (completeResult.data != null && completeResult.data is Map) {
        final data = completeResult.data as Map<String, dynamic>;
        final orderId =
            data['id']?.toString() ?? data['order_id']?.toString();
        state = state.copyWith(
          step: CheckoutStep.confirmation,
          orderId: orderId,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(
          isLoading: false,
          error: completeResult.error ?? 'Erreur finalisation.');
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Erreur reseau.');
      return false;
    }
  }

  void goToStep(CheckoutStep step) {
    state = state.copyWith(step: step);
  }

  void clearError() {
    state = state.copyWith();
  }
}

// Extension utilitaire : accesseur ref dans StateNotifier
// (Riverpod fournit deja ref sur StateNotifier v2)
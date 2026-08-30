/// BINISHOP — Wishlist Screen client
/// Favoris persistés localement via SecureStorage.
library features.wishlist.presentation.screens.wishlist_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/states/empty_state.dart';
import '../wishlist_notifier.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Vider la liste',
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline,
              title: 'Aucun favori',
              message:
                  'Ajoutez des produits à vos favoris en touchant le cœur.',
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.read(wishlistNotifierProvider.notifier).load(),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _WishlistCard(item: items[index]),
              ),
            ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider les favoris ?'),
        content:
            const Text('Tous vos favoris seront supprimés de façon définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(wishlistNotifierProvider.notifier).clear();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends ConsumerWidget {
  final WishlistItem item;
  const _WishlistCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = item.formattedPrice;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: item.thumbnail != null
                ? Image.network(
                    item.thumbnail!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_outlined, size: 48),
                  )
                : const Center(child: Icon(Icons.image_outlined, size: 48)),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    Text(
                      price ?? '',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Retirer des favoris',
                      onPressed: () => ref
                          .read(wishlistNotifierProvider.notifier)
                          .remove(item.variantId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

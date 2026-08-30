/// BINISHOP — Home Screen (client)
/// Page d'accueil construite à partir des blocs
/// dynamiques administrés depuis le dashboard.
library features.home.presentation.screens.home_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/states/empty_state.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../data/homepage_service.dart';
import '../../domain/homepage_block.dart';
import 'client_shell.dart';

/// Provider des blocs homepage actifs (données réelles Medusa)
final homepageBlocksProvider = FutureProvider<HomepageResult>((ref) async {
  final service = ref.watch(homepageServiceProvider);
  final result = await service.getActiveBlocks();
  if (result.error != null) {
    throw Exception(result.error);
  }
  return service.parseBlocks(result.data);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(homepageBlocksProvider);

    return ClientShell(
      child: blocksAsync.when(
        loading: () => const LoadingState(useSkeleton: true),
        error: (error, stack) => ErrorState(
          message: 'Impossible de charger la page d\'accueil.',
          onRetry: () => ref.invalidate(homepageBlocksProvider),
        ),
        data: (result) => _HomeContent(result: result),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomepageResult result;

  const _HomeContent({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.blocks.isEmpty) {
      // Boutique vide : état vide professionnel (aucun contenu fictif)
      return const EmptyState(
        icon: Icons.storefront_outlined,
        title: 'Bienvenue sur BINISHOP',
        message:
            'La boutique est prête. Le contenu sera disponible dès que '
            'l\'administrateur aura configuré la page d\'accueil.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: result.blocks.length,
        itemBuilder: (context, index) =>
            _BlockRenderer(block: result.blocks[index]),
      ),
    );
  }
}

/// Rendu d'un bloc selon son type
class _BlockRenderer extends StatelessWidget {
  final HomepageBlock block;

  const _BlockRenderer({required this.block});

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case HomepageBlockType.hero:
        return _HeroBlock(block: block);
      case HomepageBlockType.text:
        return _TextBlock(block: block);
      case HomepageBlockType.banner:
        return _BannerBlock(block: block);
      case HomepageBlockType.cta:
        return _CtaBlock(block: block);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Bloc HERO — grande image/titre/CTA administré
class _HeroBlock extends StatelessWidget {
  final HomepageBlock block;

  const _HeroBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              block.title,
              style: AppTypography.displayMedium.copyWith(color: Colors.white),
            ),
            if (block.subtitle != null) ...[
              const SizedBox(height: 16),
              Text(
                block.subtitle!,
                style: AppTypography.bodyLarge.copyWith(color: Colors.white70),
              ),
            ],
            if ((block.link ?? '').isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(block.link!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child: Text(block.linkLabel ?? 'Découvrir'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bloc TEXTE — titre + description administrés
class _TextBlock extends StatelessWidget {
  final HomepageBlock block;

  const _TextBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(block.title, style: AppTypography.headlineLarge),
          if (block.description != null) ...[
            const SizedBox(height: 8),
            Text(
              block.description!,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bloc BANNIÈRE — image cliquable administrée
class _BannerBlock extends StatelessWidget {
  final HomepageBlock block;

  const _BannerBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final hasLink = (block.link ?? '').isNotEmpty;
    return GestureDetector(
      onTap: hasLink ? () => context.go(block.link!) : null,
      child: AspectRatio(
        aspectRatio: 16 / 6,
        child: Container(
          color: AppColors.surfaceDark,
          child: block.image != null && block.image!.isNotEmpty
              ? Image.network(block.image!, fit: BoxFit.cover)
              : Center(child: Icon(Icons.image_outlined, size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5))),
        ),
      ),
    );
  }
}

/// Bloc CTA — appel à l'action administré
class _CtaBlock extends StatelessWidget {
  final HomepageBlock block;

  const _CtaBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(block.title, style: AppTypography.headlineMedium),
          if (block.description != null) ...[
            const SizedBox(height: 8),
            Text(block.description!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
          if ((block.link ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(block.link!),
              child: Text(block.linkLabel ?? 'En savoir plus'),
            ),
          ],
        ],
      ),
    );
  }
}
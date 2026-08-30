/// BINISHOP — Loading State Widget
/// Affiche un état de chargement avec skeleton ou spinner.
library shared.states.loading_state;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final bool useSkeleton;

  const LoadingState({
    super.key,
    this.message,
    this.useSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useSkeleton) {
      return _buildSkeleton(context);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.secondary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.shimmerHighlight,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 14,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
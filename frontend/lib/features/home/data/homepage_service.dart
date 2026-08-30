/// BINISHOP — Homepage Service
/// Récupère les blocs homepage administrés.
library features.home.data.homepage_service;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/service_providers.dart';
import '../domain/homepage_block.dart';

class HomepageService {
  final ApiClient _api;

  HomepageService(this._api);

  /// Récupère les blocs actifs (store)
  Future<ApiResult<Map<String, dynamic>>> getActiveBlocks() async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.storeHomepage,
      authenticate: false,
    );
  }

  /// Admin : liste tous les blocs
  Future<ApiResult<Map<String, dynamic>>> adminGetBlocks() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.adminHomepage);
  }

  /// Admin : créer un bloc
  Future<ApiResult<Map<String, dynamic>>> createBlock(Map<String, dynamic> data) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.adminHomepage, data: data);
  }

  /// Admin : modifier un bloc
  Future<ApiResult<Map<String, dynamic>>> updateBlock(
    String id, Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>('${ApiConstants.adminHomepage}/$id', data: data);
  }

  /// Admin : supprimer un bloc
  Future<ApiResult<Map<String, dynamic>>> deleteBlock(String id) async {
    return _api.delete<Map<String, dynamic>>('${ApiConstants.adminHomepage}/$id');
  }

  /// Parse la réponse Medusa → blocs
  HomepageResult parseBlocks(Map<String, dynamic>? data) {
    if (data == null) return const HomepageResult();
    final items = data['homepage_blocks'] ?? data['blocks'] ?? data['data'] ?? const <dynamic>[];
    final blocks = (items as List<dynamic>).map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      return HomepageBlock(
        id: item['id']?.toString() ?? '',
        type: HomepageBlockType.fromValue(item['type']?.toString() ?? 'text'),
        title: item['title']?.toString() ?? '',
        subtitle: item['subtitle']?.toString(),
        description: item['description']?.toString(),
        image: item['image']?.toString(),
        link: item['link']?.toString(),
        linkLabel: item['link_label']?.toString(),
        rank: (item['rank'] as num?)?.toInt() ?? 0,
        isActive: item['is_active'] ?? true,
      );
    }).toList();
    return HomepageResult(blocks: blocks);
  }
}

/// Provider registré pour le service homepage
final homepageServiceProvider = Provider<HomepageService>((ref) {
  return HomepageService(ref.watch(apiClientProvider));
});
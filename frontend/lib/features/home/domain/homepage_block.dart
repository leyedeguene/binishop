/// BINISHOP — Homepage Block Entity
library features.home.domain.homepage_block;

import 'package:equatable/equatable.dart';

/// Type de bloc homepage administrable.
/// [value] = valeur filaire envoyée/reçue de l'API Medusa (snake_case).
enum HomepageBlockType {
  hero('hero'),
  banner('banner'),
  collection('collection'),
  category('category'),
  featuredProducts('featured_products'),
  newArrivals('new_arrivals'),
  bestsellers('bestsellers'),
  promotion('promotion'),
  text('text'),
  image('image'),
  cta('cta'),
  products('products'),
  categories('categories');

  /// Valeur filaire utilisée par l'API.
  final String wireValue;

  const HomepageBlockType(this.wireValue);

  /// Parse une valeur venant du backend, fallback sur [text].
  static HomepageBlockType fromValue(String value) {
    for (final type in HomepageBlockType.values) {
      if (type.wireValue == value) return type;
    }
    return HomepageBlockType.text;
  }
}

/// Bloc de contenu pour la homepage
class HomepageBlock extends Equatable {
  final String id;
  final HomepageBlockType type;
  final String title;
  final String? subtitle;
  final String? description;
  final String? image;
  final String? link;
  final String? linkLabel;
  final Map<String, dynamic>? settings;
  final int rank;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HomepageBlock({
    required this.id,
    required this.type,
    this.title = '',
    this.subtitle,
    this.description,
    this.image,
    this.link,
    this.linkLabel,
    this.settings,
    this.rank = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, type.wireValue, rank];
}

/// Résultat de la récupération des blocs homepage
class HomepageResult {
  final List<HomepageBlock> blocks;
  const HomepageResult({this.blocks = const []});

  static HomepageResult empty() => const HomepageResult();
}
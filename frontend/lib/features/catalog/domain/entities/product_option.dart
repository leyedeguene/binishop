/// BINISHOP — Product Option Entity
/// Options configurables (Taille, Couleur).
library features.catalog.domain.entities.product_option;

import 'package:equatable/equatable.dart';

class ProductOption extends Equatable {
  final String id;
  final String title;
  final List<String> values;

  const ProductOption({
    required this.id,
    required this.title,
    this.values = const [],
  });

  @override
  List<Object?> get props => [id, title];
}
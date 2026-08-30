/// BINISHOP — Product Collection Entity
library features.catalog.domain.entities.collection;

import 'package:equatable/equatable.dart';

class ProductCollection extends Equatable {
  final String id;
  final String title;
  final String handle;
  final String? description;
  final String? image;
  final bool isActive;
  final int rank;

  const ProductCollection({
    required this.id,
    required this.title,
    required this.handle,
    this.description,
    this.image,
    this.isActive = true,
    this.rank = 0,
  });

  @override
  List<Object?> get props => [id, title, handle];
}
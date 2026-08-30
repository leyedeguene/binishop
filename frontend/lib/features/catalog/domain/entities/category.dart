/// BINISHOP — Product Category Entity
library features.catalog.domain.entities.category;

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String? description;
  final String? image;
  final String? parentId;
  final List<Category>? children;
  final bool isActive;
  final int rank;

  const Category({
    required this.id,
    required this.name,
    required this.handle,
    this.description,
    this.image,
    this.parentId,
    this.children,
    this.isActive = true,
    this.rank = 0,
  });

  bool get hasChildren => (children?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [id, name, handle, parentId, rank];
}
class CategoryModel {
  final int? id;
  final String name;
  final String? colorHex;

  CategoryModel({
    this.id,
    required this.name,
    this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String?,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? colorHex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

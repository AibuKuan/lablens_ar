class Equipment {
  String name;
  String modelPath;
  String? category;
  String? specifications;
  String? function;
  String? usage;
  String? maintenance;
  String? warning;
  Object? animations;

  Equipment(
    this.name, 
    this.modelPath,
    this.category, 
    this.function, 
    this.specifications, 
    this.usage, 
    this.maintenance, 
    this.warning,
    this.animations,
  );

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      json['name'],
      json['modelPath'],
      json['category'],
      json['function'],
      json['specifications'],
      json['usage'],
      json['maintenance'],
      json['warning'],
      json['animations'] ?? {},
    );
  }
}
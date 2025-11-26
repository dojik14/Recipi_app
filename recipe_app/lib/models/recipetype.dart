class RecipeType {
  final String id;
  final String name;
  RecipeType({required this.id, required this.name});
  factory RecipeType.fromJson(Map<String, dynamic> j) => RecipeType(id: j['id'], name: j['name']);
}

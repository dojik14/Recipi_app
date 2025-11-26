import 'package:hive/hive.dart';

part 'recipe.g.dart'; 

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String typeId;

  @HiveField(3) 
  String description;


  @HiveField(4)
  String imagePath; 

  @HiveField(5)
  List<String> ingredients;

  @HiveField(6)
  List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.typeId,
    required this.description,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
  });
}
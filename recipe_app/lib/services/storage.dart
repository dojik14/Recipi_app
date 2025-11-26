import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../models/recipetype.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String recipeBoxName = 'recipes_box';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RecipeAdapter());
    await Hive.openBox<Recipe>(recipeBoxName);
  }

  static Future<List<RecipeType>> loadRecipeTypesFromAsset() async {
    final jsonStr = await rootBundle.loadString('assets/recipetypes.json');
    final data = json.decode(jsonStr) as Map<String,dynamic>;
    final types = (data['types'] as List).map((e) => RecipeType.fromJson(e)).toList();
    return types;
  }

  static Box<Recipe> get recipeBox => Hive.box<Recipe>(recipeBoxName);

  static Future<void> addSampleDataIfEmpty() async {
    final box = recipeBox;
    if (box.isEmpty) {
      var uuid = Uuid();
      final sample = Recipe(
        id: uuid.v4(),
        title: 'Nasi Lemak',
        typeId: 'breakfast',
        description: 'A classic Malaysian dish of rice cooked in coconut milk and pandan leaf.', 
        imagePath: '',
        ingredients: ['Rice','Coconut milk','Anchovies','Egg','Sambal'],
        steps: ['Cook rice with coconut milk','Fry anchovies','Boil egg','Serve']
      );
      await box.add(sample);
    }
  }
}
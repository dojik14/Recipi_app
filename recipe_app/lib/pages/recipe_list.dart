import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../services/storage.dart';
import 'add_edit_recipe.dart';
import 'recipe_detail.dart';

class RecipeListPage extends StatelessWidget {

  final String? filterTypeId;
  
  const RecipeListPage({super.key, this.filterTypeId});

  void _navigateToAddRecipe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditRecipePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = StorageService.recipeBox;

    return Scaffold( 
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, child) {
          final allRecipes = box.values.cast<Recipe>().toList();

          final filteredRecipes = allRecipes.where((r) {
            return filterTypeId == null || r.typeId == filterTypeId;
          }).toList();

          if (filteredRecipes.isEmpty) {
            return Center(
              child: Text(
                'No recipes yet for this category.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return ListTile(
                title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Type: ${recipe.typeId}'), 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailPage(recipeKey: recipe.key),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRecipe(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'dart:io'; 
import '../models/recipe.dart';
import 'add_edit_recipe.dart';
import '../services/storage.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeKey;
  const RecipeDetailPage({super.key, required this.recipeKey});
  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  static const primaryColor = Color(0xFFE94E4E); 

  @override
  Widget build(BuildContext context) {
    final box = StorageService.recipeBox;
    
    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [widget.recipeKey]),
      builder: (context, box, child) {
        final recipe = box.get(widget.recipeKey) as Recipe?;
        
        if (recipe == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Recipe not found or deleted',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final imageFileExists = recipe.imagePath.isNotEmpty && File(recipe.imagePath).existsSync();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black54,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  background: imageFileExists
                      ? Image.file(
                          File(recipe.imagePath),
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.darken,
                          color: Colors.black26,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          ),
                        )
                      : Container(
                          color: primaryColor.withOpacity(0.8),
                          child: const Center(
                            child: Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
                          ),
                        ),
                ),
                backgroundColor: primaryColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white), 
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => AddEditRecipePage(recipe: recipe))
                    ).then((_) => setState((){})),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white), 
                    onPressed: () async {
                      final confirmed = await _confirmDelete(context);
                      if (confirmed) {
                        await recipe.delete();
                        Navigator.pop(context);
                      }
                    }
                  ),
                ],
              ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.description.isNotEmpty) ...[
                            _buildSectionHeader(context, 'Description', Icons.info_outline),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                recipe.description, 
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                              ),
                            ),
                          ],
                          
                          _buildSectionHeader(context, 'Ingredients', Icons.local_mall),
                          ...recipe.ingredients.map((i) => _buildIngredientTile(i)).toList(),
                          const SizedBox(height: 20),
                          
                          _buildSectionHeader(context, 'Steps', Icons.list_alt),
                          ...recipe.steps.asMap().entries.map((e) => _buildStepTile(e.key + 1, e.value)).toList(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title, 
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const Expanded(child: Divider(indent: 10, color: Colors.grey)),
        ],
      ),
    );
  }
  Widget _buildIngredientTile(String ingredient) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text(ingredient, style: const TextStyle(fontSize: 15)),
        dense: true,
      ),
    );
  }

  Widget _buildStepTile(int stepNumber, String stepDescription) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            '$stepNumber',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          stepDescription,
          style: const TextStyle(fontSize: 16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
  
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this recipe? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }
}
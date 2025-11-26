import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../services/storage.dart';
import '../models/recipetype.dart';

class AddEditRecipePage extends StatefulWidget {
  final Recipe? recipe;
  const AddEditRecipePage({super.key, this.recipe});
  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController(); 
  
  List<RecipeType> _recipeTypes = []; 
  String? _typeId;
  
  List<String> _ingredients = [];
  List<String> _steps = [];
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _loadRecipeTypes();
    
    if (widget.recipe != null) {
      _titleCtrl.text = widget.recipe!.title;
      _descriptionCtrl.text = widget.recipe!.description; 
      _typeId = widget.recipe!.typeId; 
      _ingredients = List.from(widget.recipe!.ingredients);
      _steps = List.from(widget.recipe!.steps);
      _imagePath = widget.recipe!.imagePath;
    } else {
      _typeId = 'snack'; 
    }
  }

  Future<void> _loadRecipeTypes() async {
    final types = await StorageService.loadRecipeTypesFromAsset();
    setState(() {
      _recipeTypes = types;
      if (widget.recipe == null && _recipeTypes.isNotEmpty) {
        _typeId = _recipeTypes.first.id;
      } else if (_typeId == null && _recipeTypes.isNotEmpty) {
        _typeId = _recipeTypes.first.id;
      }
    });
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final img = await p.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() { _imagePath = img.path; });
    }
  }

  void _addIngredientField() => setState(() => _ingredients.add(''));
  void _addStepField() => setState(() => _steps.add(''));

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final box = StorageService.recipeBox;
    final filteredIngredients = _ingredients.where((s) => s.isNotEmpty).toList();
    final filteredSteps = _steps.where((s) => s.isNotEmpty).toList();

    if (widget.recipe == null) {
      final id = const Uuid().v4();
      final newRecipe = Recipe(
        id: id, 
        title: _titleCtrl.text, 
        typeId: _typeId ?? 'snack',
        description: _descriptionCtrl.text, 
        imagePath: _imagePath, 
        ingredients: filteredIngredients, 
        steps: filteredSteps,
      );
      box.add(newRecipe);
    } else {
      final updatedRecipe = widget.recipe!
        ..title = _titleCtrl.text
        ..typeId = _typeId ?? widget.recipe!.typeId
        ..description = _descriptionCtrl.text 
        ..imagePath = _imagePath
        ..ingredients = filteredIngredients
        ..steps = filteredSteps;
      
      updatedRecipe.save(); 
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE94E4E);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
    );
    final focusedInputBorder = inputBorder.copyWith(
      borderSide: const BorderSide(color: primaryColor, width: 2.0),
    );
    final headerStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
      color: primaryColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe == null ? 'Add New Recipe' : 'Edit Recipe',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            
            DropdownButtonFormField<String>(
              value: _typeId,
              decoration: InputDecoration(
                labelText: 'Recipe Type',
                labelStyle: TextStyle(color: primaryColor),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedInputBorder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _recipeTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type.id,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _typeId = newValue;
                });
              },
              validator: (v) => v == null ? 'Please select a recipe type' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleCtrl, 
              decoration: InputDecoration(
                labelText: 'Title',
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedInputBorder,
              ), 
              validator: (v)=>v==null||v.isEmpty?'Required':null
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionCtrl, 
              decoration: InputDecoration(
                labelText: 'Description',
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedInputBorder,
              ),
              maxLines: 3, 
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            
            Text('Recipe Image', style: headerStyle),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage, 
              icon: const Icon(Icons.photo, color: Colors.white), 
              label: const Text('Pick Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            if (_imagePath.isNotEmpty && File(_imagePath).existsSync()) 
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  File(_imagePath), 
                  height: 200, 
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200, 
                    color: Colors.grey[200],
                    child: const Center(child: Text('Image Load Failed', style: TextStyle(color: Colors.red))),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            Text('Ingredients', style: headerStyle),
            const SizedBox(height: 12),
            ..._ingredients.asMap().entries.map((e){
              final idx = e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  key: ValueKey('ing_${idx}'),
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: e.value, 
                        decoration: InputDecoration(
                          hintText: 'Ingredient ${idx + 1}',
                          isDense: true,
                          border: inputBorder.copyWith(borderRadius: BorderRadius.circular(8.0)),
                          enabledBorder: inputBorder.copyWith(borderRadius: BorderRadius.circular(8.0)),
                          focusedBorder: focusedInputBorder.copyWith(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                        ),
                        onChanged: (t)=>_ingredients[idx]=t,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: primaryColor),
                      onPressed: () => setState(() => _ingredients.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton(
              onPressed: _addIngredientField, 
              child: const Text('Add ingredient', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 24),
        
            Text('Steps', style: headerStyle),
            const SizedBox(height: 12),
            ..._steps.asMap().entries.map((e){
              final idx = e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  key: ValueKey('step_${idx}'),
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: e.value,
                        decoration: InputDecoration(
                          hintText: 'Step ${idx + 1}',
                          isDense: true,
                          border: inputBorder.copyWith(borderRadius: BorderRadius.circular(8.0)),
                          enabledBorder: inputBorder.copyWith(borderRadius: BorderRadius.circular(8.0)),
                          focusedBorder: focusedInputBorder.copyWith(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                        ), 
                        onChanged: (t)=>_steps[idx]=t
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: primaryColor), // Ikon merah-oren
                      onPressed: () => setState(() => _steps.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton(
              onPressed: _addStepField, 
              child: const Text('Add step', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _save, 
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                widget.recipe == null ? 'Save New Recipe' : 'Update Recipe', 
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}
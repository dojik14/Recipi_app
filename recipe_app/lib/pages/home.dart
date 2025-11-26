import 'package:flutter/material.dart';
import '../models/recipetype.dart';
import '../services/storage.dart';
import 'recipe_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecipeType> _recipeTypes = [];
  String? _selectedTypeId;
  bool _isLoading = true;

  static const primaryColor = Color(0xFFE94E4E);

  @override
  void initState() {
    super.initState();
    _loadRecipeTypes();
  }

  Future<void> _loadRecipeTypes() async {
    try {
      final types = await StorageService.loadRecipeTypesFromAsset();
      setState(() {
        _recipeTypes = [
          RecipeType(id: 'all', name: 'All'), 
          ...types,
        ];
        _selectedTypeId = 'all'; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _recipeTypes = [RecipeType(id: 'all', name: 'All')];
        _selectedTypeId = 'all';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), 
      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
    );
    final focusedInputBorder = inputBorder.copyWith(
      borderSide: const BorderSide(color: primaryColor, width: 2.0),
    );

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe App', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Filter by:', 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: primaryColor
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTypeId,
                    decoration: InputDecoration(
                      labelText: 'Recipe Type',
                      labelStyle: const TextStyle(color: primaryColor),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedInputBorder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _recipeTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.id,
                        child: Text(type.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTypeId = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: RecipeListPage(
              filterTypeId: _selectedTypeId == 'all' ? null : _selectedTypeId,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/grocery.dart';

Uuid _uuid = Uuid();

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // Default settings
  static const defautName = "New grocery";
  static const defaultQuantity = 1;
  static const defaultCategory = GroceryCategory.fruit;

  // Inputs
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  GroceryCategory _selectedCategory = defaultCategory;

  @override
  void initState() {
    super.initState();

    // Initialize intputs with default settings
    _nameController.text = defautName;
    _quantityController.text = defaultQuantity.toString();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose the controlers
    _nameController.dispose();
    _quantityController.dispose();
  }

  void onReset() async {
    // Reset all fields to the initial values
    if ((_nameController.text.isNotEmpty ||
            _quantityController.text.isNotEmpty) ||
        (_nameController.text != defautName ||
            _quantityController.text != defaultQuantity.toString() ||
            _selectedCategory != defaultCategory)) {
      bool? isDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes'),
          content: const Text('Your progresses will be lose!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (isDiscard != null && isDiscard) {
        setState(() {
          _nameController.text = defautName;
          _quantityController.text = defaultQuantity.toString();
          _selectedCategory = defaultCategory;
        });
      }
    }
  }

  void onAdd() {
    // Create and return the new grocery
    String name = _nameController.text;
    int? quantity = int.tryParse(_quantityController.text);

    if (name.isEmpty || quantity == null || quantity <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Empty name or invalid quantity!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      Grocery newGrocery = Grocery(
        id: _uuid.v4(),
        name: name,
        quantity: quantity,
        category: _selectedCategory,
      );

      Navigator.pop(context, newGrocery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              maxLength: 50,
              decoration: const InputDecoration(label: Text('Name')),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(label: Text('Quantity')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<GroceryCategory>(
                    initialValue: _selectedCategory,
                    items: GroceryCategory.values
                        .map(
                          (cat) => DropdownMenuItem<GroceryCategory>(
                            value: cat,
                            child: Row(
                              spacing: 8,
                              children: [
                                Container(
                                  color: cat.color,
                                  width: 15,
                                  height: 15,
                                ),
                                Text(cat.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onReset, child: const Text('Reset')),
                ElevatedButton(onPressed: onAdd, child: const Text('Add Item')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

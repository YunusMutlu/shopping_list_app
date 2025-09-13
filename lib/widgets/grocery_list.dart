import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import "package:http/http.dart" as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      "flutter-prep-64364-default-rtdb.firebaseio.com",
      "shopping-list.json",
    );
    final respone = await http.get(url);
    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(respone.body);
    listData.entries.map((item) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value["category"],
          )
          .value;
      return loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }).toList();
    setState(() {
      _groceryItem = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (contex) => NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text("No items added yet."));

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    }
    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItem[index].id),
            onDismissed: (direction) {
              _removeItem(_groceryItem[index]);
            },
            child: ListTile(
              title: Text(_groceryItem[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItem[index].category.color,
              ),
              trailing: Text(_groceryItem[index].quantity.toString()),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: () {
              _addItem();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}

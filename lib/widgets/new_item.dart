import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemSatet();
}

class _NewItemSatet extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = "";

  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formkey.currentState!.save();
      final url = Uri.https(
        "flutter-prep-64364-default-rtdb.firebaseio.com",
        "shopping-list.json",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "applications/json"},
        body: jsonEncode({
          "name": _enteredName,
          "quantity": _enteredQuantity,
          "category": _selectedCategory.title,
        }),
      );
      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData["name"],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add a new item")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Quantity"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be valid positive num";
                        }
                        return null;
                      },
                      initialValue: _enteredQuantity.toString(),
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items: categories.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.title),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formkey.currentState!.reset();
                          },
                    child: Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _saveItem();
                          },
                    child: _isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text("Add item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

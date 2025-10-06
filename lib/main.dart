import 'package:flutter/material.dart';
import 'src/pages/shopping_list_page.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(useMaterial3: true),
      home: const ShoppingListPage(),
    );
  }
}
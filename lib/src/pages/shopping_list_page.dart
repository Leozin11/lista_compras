import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _items = <String>[];
  final List<bool> _done = <bool>[];

  @override
  Widget build(BuildContext context) {
    final total = _items.length;
    final bought = _done.where((e) => e).length;
    final left = total - bought;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar tudo',
            onPressed: total == 0 ? null : _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar item...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add_shopping_cart),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          if (total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(icon: Icons.list, label: 'Total', value: '$total'),
                  _Stat(icon: Icons.check_circle, label: 'Comprados', value: '$bought'),
                  _Stat(icon: Icons.pending, label: 'Restantes', value: '$left'),
                ],
              ),
            ),
          Expanded(
            child: total == 0
                ? const Center(child: Text('Sem itens'))
                : ListView.builder(
                    itemCount: total,
                    itemBuilder: (context, i) {
                      final comprado = _done[i];
                      return Dismissible(
                        key: ValueKey(_items[i]),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmRemove(i),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red.withOpacity(.12),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: comprado,
                            onChanged: (v) => _toggle(i, v ?? false),
                          ),
                          title: Text(
                            _items[i],
                            style: TextStyle(
                              decoration: comprado ? TextDecoration.lineThrough : null,
                              color: comprado ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _remove(i),
                            tooltip: 'Remover',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    if (_items.contains(t)) {
      _toast('Item já existe');
      return;
    }
    setState(() {
      _items.add(t);
      _done.add(false);
      _ctrl.clear();
    });
    _toast('Adicionado: $t');
  }

  void _toggle(int i, bool v) {
    setState(() => _done[i] = v);
  }

  Future<bool> _confirmRemove(int i) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remover'),
            content: Text('Remover "${_items[i]}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
            ],
          ),
        ) ??
        false;
  }

  void _remove(int i) async {
    if (await _confirmRemove(i)) {
      final item = _items[i];
      setState(() {
        _items.removeAt(i);
        _done.removeAt(i);
      });
      _toast('Removido: $item');
    }
  }

  void _clearAll() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Limpar lista'),
            content: const Text('Deseja remover todos os itens?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Limpar')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    setState(() {
      _items.clear();
      _done.clear();
    });
    _toast('Lista limpa');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
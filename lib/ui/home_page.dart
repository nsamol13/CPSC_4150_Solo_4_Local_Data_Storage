import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/items_provider.dart';
import '../data/item.dart';
import 'widgets/add_edit_dialog.dart';
import 'widgets/item_tile.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool darkMode;
  const HomePage({super.key, required this.onToggleTheme, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo 4 Persistence by Noah'),
        actions: [
          IconButton(
            tooltip: darkMode ? 'Light mode' : 'Dark mode',
            icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                await vm.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All items cleared.')),
                );
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear All')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Builder(
          builder: (context) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(
                child: Text(vm.error!, textAlign: TextAlign.center),
              );
            }
            if (vm.items.isEmpty) {
              return const _EmptyState();
            }
            return ListView.separated(
              itemCount: vm.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final item = vm.items[i];
                return Dismissible(
                  key: ValueKey(item.id ?? '${item.text}-${item.createdAt}'),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) async {
                    await vm.remove(item);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted: ${item.text}')),
                    );
                  },
                  child: ItemTile(
                    item: item,
                    onTap: () async {
                      final updatedText = await showAddEditDialog(
                        context,
                        initialText: item.text,
                      );
                      if (updatedText != null && updatedText.trim().isNotEmpty) {
                        await vm.edit(item, updatedText);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item updated.')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final text = await showAddEditDialog(context);
          if (text == null) return;
          final ok = await context.read<ItemsProvider>().add(text);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ok ? 'Saved!' : 'Nothing to save.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 56),
          const SizedBox(height: 10),
          const Text('No items yet'),
          const SizedBox(height: 6),
          Text(
            'Tap \'Add\' to create your first item.\nYour data persists across launches.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

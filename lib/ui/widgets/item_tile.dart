import 'package:flutter/material.dart';
import '../../data/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  const ItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.note_alt_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.text, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(item.createdAt)
                          .toLocal()
                          .toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/localization/loc_extensions.dart';

class MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.textMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.sm),
            Text(
              '${context.tr(AppKeys.price)}: $price',
              style: TextStyle(
                fontSize: AppDimensions.textSm,
                color: AppColors.inkSoft,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(context.tr(AppKeys.addToOrder)),
                  ),
                ),
                SizedBox(width: AppDimensions.sm),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == AppKeys.editItem) {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: AppKeys.editItem,
                      child: Text(context.tr(AppKeys.editItem)),
                    ),
                    PopupMenuItem(
                      value: AppKeys.deleteItem,
                      child: Text(context.tr(AppKeys.deleteItem)),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

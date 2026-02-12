import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/language_switcher.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.ordersTab)),
        actions: const [LanguageSwitcher()],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            if (provider.orders.isEmpty) {
              return EmptyState(
                message: context.tr(AppKeys.emptyOrders),
                icon: Icons.receipt_long,
              );
            }

            return ListView.separated(
              itemCount: provider.orders.length,
              separatorBuilder: (_, unusedIndex) =>
                  Divider(color: AppColors.outline),
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.brandSoft,
                    child: Text(order.id.toString()),
                  ),
                  title: Text(_statusLabel(context, order.status)),
                  subtitle: Text(
                    '${context.tr(AppKeys.total)}: ${_formatAmount(order.total)}',
                  ),
                  trailing: _buildStatusMenu(context, provider, order),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    final text = value.toStringAsFixed(6);
    final trimmed = text
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  String _statusLabel(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return context.tr(AppKeys.statusNew);
      case OrderStatus.inProgress:
        return context.tr(AppKeys.statusInProgress);
      case OrderStatus.done:
        return context.tr(AppKeys.statusDone);
      case OrderStatus.canceled:
        return context.tr(AppKeys.statusCanceled);
    }
  }

  Widget _buildStatusMenu(
    BuildContext context,
    OrderProvider provider,
    OrderEntity order,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text(dialogContext.tr(AppKeys.confirmDeleteOrderTitle)),
                content: Text(dialogContext.tr(AppKeys.confirmDeleteOrderBody)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(dialogContext.tr(AppKeys.cancel)),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(dialogContext.tr(AppKeys.confirm)),
                  ),
                ],
              );
            },
          );

          if (!context.mounted || !(confirmed ?? false)) {
            return;
          }

          await provider.removeOrder(order.id);
          return;
        }

        final status = _statusFromValue(value);
        if (status != null) {
          await provider.setStatus(order.id, status);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'status_new',
          child: Text(context.tr(AppKeys.statusNew)),
        ),
        PopupMenuItem(
          value: 'status_in_progress',
          child: Text(context.tr(AppKeys.statusInProgress)),
        ),
        PopupMenuItem(
          value: 'status_done',
          child: Text(context.tr(AppKeys.statusDone)),
        ),
        PopupMenuItem(
          value: 'status_canceled',
          child: Text(context.tr(AppKeys.statusCanceled)),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text(context.tr(AppKeys.deleteOrder)),
        ),
      ],
      child: Icon(Icons.more_vert, color: AppColors.inkSoft),
    );
  }

  OrderStatus? _statusFromValue(String value) {
    switch (value) {
      case 'status_new':
        return OrderStatus.newOrder;
      case 'status_in_progress':
        return OrderStatus.inProgress;
      case 'status_done':
        return OrderStatus.done;
      case 'status_canceled':
        return OrderStatus.canceled;
      default:
        return null;
    }
  }
}

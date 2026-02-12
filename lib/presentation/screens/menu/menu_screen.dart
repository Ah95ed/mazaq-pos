import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/menu_item_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/language_switcher.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/order_summary_panel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = CurrencyFormatter(
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.menuTab)),
        actions: const [LanguageSwitcher()],
      ),
      floatingActionButton: _AddItemFab(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.itemForm);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= AppBreakpoints.tablet;
            final menuPanel = _MenuPanel(formatter: formatter, isWide: isWide);
            final orderPanel = const OrderSummaryPanel();

            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 3, child: menuPanel),
                  SizedBox(width: AppDimensions.lg),
                  Expanded(flex: 2, child: orderPanel),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: menuPanel),
                SizedBox(height: AppDimensions.lg),
                SizedBox(
                  height: AppDimensions.orderPanelHeight,
                  child: orderPanel,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddItemFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddItemFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(context.tr(AppKeys.addItem)),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  final CurrencyFormatter formatter;
  final bool isWide;

  const _MenuPanel({required this.formatter, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MenuProvider, OrderProvider>(
      builder: (context, menuProvider, orderProvider, _) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _CategoryFilter(menuProvider: menuProvider),
            SizedBox(height: AppDimensions.md),
            if (menuProvider.items.isEmpty)
              Expanded(
                child: EmptyState(
                  message: context.tr(AppKeys.emptyMenu),
                  icon: Icons.restaurant_menu,
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide
                        ? AppLayout.menuGridColumnsWide
                        : AppLayout.menuGridColumnsNarrow,
                    childAspectRatio: AppLayout.menuCardAspectRatio,
                    crossAxisSpacing: AppDimensions.md,
                    mainAxisSpacing: AppDimensions.md,
                  ),
                  itemCount: menuProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = menuProvider.items[index];
                    return MenuItemCard(
                      title: isArabic ? item.nameAr : item.nameEn,
                      price: item.priceText ?? formatter.format(item.price),
                      onAdd: () {
                        orderProvider.addToDraft(
                          OrderItemEntity(
                            id: 0,
                            orderId: 0,
                            itemId: item.id,
                            itemName: isArabic ? item.nameAr : item.nameEn,
                            unitPrice: item.price,
                            quantity: 1,
                            lineTotal: item.price,
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.itemForm,
                          arguments: item,
                        );
                      },
                      onDelete: () {
                        _confirmDelete(context, item.id);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, int itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(AppKeys.confirmDeleteTitle)),
          content: Text(context.tr(AppKeys.confirmDeleteBody)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr(AppKeys.confirm)),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await context.read<MenuProvider>().removeItem(itemId);
    }
  }
}

class _CategoryFilter extends StatelessWidget {
  final MenuProvider menuProvider;

  const _CategoryFilter({required this.menuProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => menuProvider.setCategory(null),
            icon: Icon(
              menuProvider.selectedCategory == null
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
            ),
            label: Text(context.tr(AppKeys.all)),
            style: OutlinedButton.styleFrom(
              backgroundColor: menuProvider.selectedCategory == null
                  ? AppColors.brandSoft
                  : null,
              foregroundColor: menuProvider.selectedCategory == null
                  ? AppColors.brand
                  : null,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => menuProvider.setCategory(ItemCategory.dineIn),
            icon: Icon(
              menuProvider.selectedCategory == ItemCategory.dineIn
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
            ),
            label: Text(context.tr(AppKeys.dineIn)),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  menuProvider.selectedCategory == ItemCategory.dineIn
                  ? AppColors.brandSoft
                  : null,
              foregroundColor:
                  menuProvider.selectedCategory == ItemCategory.dineIn
                  ? AppColors.brand
                  : null,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => menuProvider.setCategory(ItemCategory.delivery),
            icon: Icon(
              menuProvider.selectedCategory == ItemCategory.delivery
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
            ),
            label: Text(context.tr(AppKeys.delivery)),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  menuProvider.selectedCategory == ItemCategory.delivery
                  ? AppColors.brandSoft
                  : null,
              foregroundColor:
                  menuProvider.selectedCategory == ItemCategory.delivery
                  ? AppColors.brand
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

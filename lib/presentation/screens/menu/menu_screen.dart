import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/constants/app_db.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
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
      floatingActionButton: _MenuFabs(
        onAddItem: () {
          Navigator.pushNamed(context, AppRoutes.itemForm);
        },
        onAddCategory: _showAddCategoryDialog,
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

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final categoryName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.tr(AppKeys.addCategoryTitle)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: dialogContext.tr(AppKeys.categoryName),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return dialogContext.tr(AppKeys.requiredField);
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.tr(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: Text(dialogContext.tr(AppKeys.addCategory)),
            ),
          ],
        );
      },
    );

    if (categoryName == null || categoryName.isEmpty || !mounted) {
      return;
    }

    await context.read<MenuProvider>().addCategory(categoryName);
  }
}

class _MenuFabs extends StatelessWidget {
  final VoidCallback onAddItem;
  final VoidCallback onAddCategory;

  const _MenuFabs({required this.onAddItem, required this.onAddCategory});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'add_category_fab',
          onPressed: onAddCategory,
          icon: const Icon(Icons.category_outlined),
          label: Text(context.tr(AppKeys.addCategory)),
        ),
        SizedBox(width: AppDimensions.sm),
        FloatingActionButton.extended(
          heroTag: 'add_item_fab',
          onPressed: onAddItem,
          icon: const Icon(Icons.add),
          label: Text(context.tr(AppKeys.addItem)),
        ),
      ],
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

    if (!context.mounted) {
      return;
    }

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
    return DropdownButtonFormField<String?>(
      initialValue: menuProvider.selectedCategory,
      decoration: InputDecoration(
        labelText: context.tr(AppKeys.itemCategory),
        prefixIcon: Icon(Icons.list_alt_rounded, color: AppColors.brand),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(context.tr(AppKeys.all)),
        ),
        ...menuProvider.filterCategories.map(
          (category) => DropdownMenuItem<String?>(
            value: category,
            child: Text(_categoryLabel(context, category)),
          ),
        ),
      ],
      onChanged: (value) => menuProvider.setCategory(value),
    );
  }

  String _categoryLabel(BuildContext context, String category) {
    if (category == AppDbValues.categoryDineIn) {
      return context.tr(AppKeys.dineIn);
    }
    if (category == AppDbValues.categoryDelivery) {
      return context.tr(AppKeys.delivery);
    }
    if (category == AppDbValues.categoryBoth) {
      return context.tr(AppKeys.both);
    }
    return category;
  }
}

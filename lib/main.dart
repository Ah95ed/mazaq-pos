import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_keys.dart';
import 'core/constants/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/loc_extensions.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/app_database.dart';
import 'data/datasources/local/export_local_data_source.dart';
import 'data/datasources/local/menu_local_data_source.dart';
import 'data/datasources/local/order_local_data_source.dart';
import 'data/datasources/local/printer_settings_local_data_source.dart';
import 'data/datasources/local/sales_local_data_source.dart';
import 'data/repositories/export_repository_impl.dart';
import 'data/repositories/menu_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/printer_settings_repository_impl.dart';
import 'data/repositories/sales_repository_impl.dart';
import 'domain/usecases/export/export_table.dart';
import 'domain/usecases/menu/add_menu_item.dart';
import 'domain/usecases/menu/add_menu_category.dart';
import 'domain/usecases/menu/delete_menu_item.dart';
import 'domain/usecases/menu/get_all_menu_categories.dart';
import 'domain/usecases/menu/get_all_menu_items.dart';
import 'domain/usecases/menu/update_menu_item.dart';
import 'domain/usecases/orders/add_order_item.dart';
import 'domain/usecases/orders/create_order.dart';
import 'domain/usecases/orders/delete_order.dart';
import 'domain/usecases/orders/get_orders.dart';
import 'domain/usecases/orders/update_order_status.dart';
import 'domain/usecases/printer_settings/get_printer_settings.dart';
import 'domain/usecases/printer_settings/save_printer_settings.dart';
import 'domain/usecases/sales/get_sales_report.dart';
import 'domain/usecases/sales/get_sales_summary.dart';
import 'presentation/providers/export_provider.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/printer_settings_provider.dart';
import 'presentation/providers/sales_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/items/item_form_screen.dart';
import 'presentation/screens/settings/printer_settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  final localeProvider = await LocaleProvider.create();
  runApp(AppRoot(localeProvider: localeProvider));
}

class AppRoot extends StatelessWidget {
  final LocaleProvider localeProvider;

  const AppRoot({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance.database;
    final menuRepository = MenuRepositoryImpl(MenuLocalDataSource(db));
    final orderRepository = OrderRepositoryImpl(OrderLocalDataSource(db));
    final salesRepository = SalesRepositoryImpl(SalesLocalDataSource(db));
    final exportRepository = ExportRepositoryImpl(ExportLocalDataSource(db));
    final printerSettingsRepository = PrinterSettingsRepositoryImpl(
      PrinterSettingsLocalDataSource(db),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(
            getAllItems: GetAllMenuItems(menuRepository),
            getAllCategories: GetAllMenuCategories(menuRepository),
            addMenuCategory: AddMenuCategory(menuRepository),
            addItem: AddMenuItem(menuRepository),
            updateItem: UpdateMenuItem(menuRepository),
            deleteItem: DeleteMenuItem(menuRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            createOrder: CreateOrder(orderRepository),
            addOrderItem: AddOrderItem(orderRepository),
            getOrders: GetOrders(orderRepository),
            updateOrderStatus: UpdateOrderStatus(orderRepository),
            deleteOrder: DeleteOrder(orderRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(
            getSalesSummary: GetSalesSummary(salesRepository),
            getSalesReport: GetSalesReport(salesRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ExportProvider(exportTable: ExportTable(exportRepository)),
        ),
        ChangeNotifierProvider(
          create: (_) => PrinterSettingsProvider(
            getSettings: GetPrinterSettings(printerSettingsRepository),
            saveSettings: SavePrinterSettings(printerSettingsRepository),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: AppConfig.designSize,
        builder: (context, child) {
          return Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => context.tr(AppKeys.appTitle),
                theme: AppTheme.lightTheme(context),
                locale: localeProvider.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routes: {
                  AppRoutes.home: (_) => const HomeScreen(),
                  AppRoutes.itemForm: (_) => const ItemFormScreen(),
                  AppRoutes.printerSettings: (_) =>
                      const PrinterSettingsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

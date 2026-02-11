import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/loc_extensions.dart';
import '../menu/menu_screen.dart';
import '../orders/orders_screen.dart';
import '../sales/sales_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [MenuScreen(), OrdersScreen(), SalesScreen()];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.tablet;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.restaurant_menu),
                      label: Text(context.tr(AppKeys.menuTab)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.receipt_long),
                      label: Text(context.tr(AppKeys.ordersTab)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.bar_chart),
                      label: Text(context.tr(AppKeys.salesTab)),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screens[_index]),
              ],
            ),
          );
        }

        return Scaffold(
          body: screens[_index],
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.sm),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (value) {
                setState(() {
                  _index = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.restaurant_menu),
                  label: context.tr(AppKeys.menuTab),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long),
                  label: context.tr(AppKeys.ordersTab),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart),
                  label: context.tr(AppKeys.salesTab),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

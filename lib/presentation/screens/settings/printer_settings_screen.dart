import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../widgets/language_switcher.dart';

// Reverted to a stateless widget for static display.
class PrinterSettingsScreen extends StatelessWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.printerSettings)),
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: ListView(
          children: [
            _SectionHeader(title: context.tr(AppKeys.printerSettings)),
            // Reverted to static ListTiles
            const ListTile(
              leading: Icon(Icons.local_fire_department),
              title: Text('طابعة الشواء'),
              subtitle: Text('IP: 192.168.0.100'),
              trailing: Text('Port: 9100'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('طابعة المطبخ'),
              subtitle: Text('IP: 192.168.0.165'),
              trailing: Text('Port: 9100'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.point_of_sale),
              title: Text('طابعة الكاشير'),
              subtitle: Text('IP: 192.168.0.166'),
              trailing: Text('Port: 9100'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.md),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppDimensions.textLg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

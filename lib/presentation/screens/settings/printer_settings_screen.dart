import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../providers/printer_settings_provider.dart';
import '../../widgets/language_switcher.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterSettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(AppKeys.printerSettings)),
        actions: const [LanguageSwitcher()],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Consumer<PrinterSettingsProvider>(
          builder: (context, provider, _) {
            return ListView(
              children: [
                _SectionHeader(title: context.tr(AppKeys.printerSettings)),
                const ListTile(
                  leading: Icon(Icons.local_fire_department),
                  title: Text('طابعة الشواء'),
                  subtitle: Text('192.168.0.100:9100'),
                ),
                const ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('طابعة المطبخ'),
                  subtitle: Text('192.168.0.165:9100'),
                ),
                const ListTile(
                  leading: Icon(Icons.point_of_sale),
                  title: Text('طابعة الكاشير'),
                  subtitle: Text('192.168.0.166:9100'),
                ),
                SizedBox(height: AppDimensions.xl),
                Padding(
                  padding: EdgeInsets.all(AppDimensions.md),
                  child: Text(
                    'ملاحظة: عناوين IP للطابعات محددة في الكود. لتغييرها، يرجى تحديث ملف order_summary_panel.dart',
                    style: TextStyle(
                      fontSize: AppDimensions.textSm,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            );
          },
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

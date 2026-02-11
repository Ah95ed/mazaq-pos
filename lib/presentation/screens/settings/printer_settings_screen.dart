import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/constants/printer_options.dart';
import '../../../core/localization/loc_extensions.dart';
import '../../providers/printer_settings_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/language_switcher.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _wifiFormKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  String? _selectedUsbModelKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterSettingsProvider>().load();
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
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
            _selectedUsbModelKey ??=
                provider.usbSettings?.usbModelKey ??
                provider.defaultUsbModelKey;
            if (_ipController.text.isEmpty) {
              _ipController.text = provider.wifiSettings?.ip ?? '';
            }
            if (_portController.text.isEmpty) {
              _portController.text =
                  provider.wifiSettings?.port?.toString() ?? '';
            }

            return ListView(
              children: [
                _SectionHeader(title: context.tr(AppKeys.usbPrinter)),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUsbModelKey,
                  items: PrinterOptions.usbModelKeys
                      .map(
                        (key) => DropdownMenuItem(
                          value: key,
                          child: Text(context.tr(key)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUsbModelKey = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: context.tr(AppKeys.usbModel),
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      final key =
                          _selectedUsbModelKey ?? provider.defaultUsbModelKey;
                      provider.saveUsb(modelKey: key);
                    },
                    child: Text(context.tr(AppKeys.save)),
                  ),
                ),
                SizedBox(height: AppDimensions.xl),
                _SectionHeader(title: context.tr(AppKeys.wifiPrinter)),
                Form(
                  key: _wifiFormKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _ipController,
                        label: context.tr(AppKeys.printerIp),
                        validator: _requiredValidator(context),
                      ),
                      SizedBox(height: AppDimensions.md),
                      AppTextField(
                        controller: _portController,
                        label: context.tr(AppKeys.printerPort),
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      if (!(_wifiFormKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      provider.saveWifi(
                        ip: _ipController.text.trim(),
                        port: int.parse(_portController.text.trim()),
                      );
                    },
                    child: Text(context.tr(AppKeys.save)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.tr(AppKeys.requiredField);
      }
      return null;
    };
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

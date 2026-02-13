import 'package:file_picker/file_picker.dart';

/// Helper to pick a save location for PDF file
Future<String?> pickSavePath(String suggestedName) async {
  final result = await FilePicker.platform.saveFile(
    dialogTitle: 'اختر مكان حفظ ملف PDF',
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  return result;
}

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Service for interacting with Windows Spooler API to list printers
/// and send raw ESC/POS bytes to a named printer.
class WindowsPrinterService {
  /// Returns a list of printer names installed on this Windows machine.
  static List<String> listPrinters() {
    final printers = <String>[];

    // First call to get required buffer size
    final pcbNeeded = calloc<DWORD>();
    final pcReturned = calloc<DWORD>();

    try {
      // PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS = 0x00000002 | 0x00000004
      EnumPrinters(
        PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
        nullptr,
        2, // Level 2 = PRINTER_INFO_2
        nullptr,
        0,
        pcbNeeded,
        pcReturned,
      );

      final bufferSize = pcbNeeded.value;
      if (bufferSize == 0) return printers;

      final buffer = calloc<Uint8>(bufferSize);
      try {
        final result = EnumPrinters(
          PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
          nullptr,
          2,
          buffer,
          bufferSize,
          pcbNeeded,
          pcReturned,
        );

        if (result == 0) return printers;

        final count = pcReturned.value;
        final infoSize = sizeOf<PRINTER_INFO_2>();

        for (int i = 0; i < count; i++) {
          final info = Pointer<PRINTER_INFO_2>.fromAddress(
            buffer.address + i * infoSize,
          );
          final name = info.ref.pPrinterName;
          if (name != nullptr) {
            printers.add(name.toDartString());
          }
        }
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(pcbNeeded);
      calloc.free(pcReturned);
    }

    return printers;
  }

  /// Sends raw [data] bytes to the Windows printer identified by [printerName].
  /// Returns true on success, false on failure.
  static bool sendRawBytes(String printerName, Uint8List data) {
    final hPrinter = calloc<HANDLE>();

    try {
      final printerNamePtr = printerName.toNativeUtf16();
      try {
        final opened = OpenPrinter(printerNamePtr, hPrinter, nullptr);
        if (opened == 0) {
          print(
            '[WindowsPrinterService] OpenPrinter failed: ${GetLastError()}',
          );
          return false;
        }
      } finally {
        calloc.free(printerNamePtr);
      }

      // Set up DOC_INFO_1
      final docName = 'ESC/POS Receipt'.toNativeUtf16();
      final dataType = 'RAW'.toNativeUtf16();
      final docInfo = calloc<DOC_INFO_1>();
      docInfo.ref.pDocName = docName;
      docInfo.ref.pOutputFile = nullptr;
      docInfo.ref.pDatatype = dataType;

      try {
        final jobId = StartDocPrinter(hPrinter.value, 1, docInfo.cast());
        if (jobId == 0) {
          print(
            '[WindowsPrinterService] StartDocPrinter failed: ${GetLastError()}',
          );
          ClosePrinter(hPrinter.value);
          return false;
        }

        if (StartPagePrinter(hPrinter.value) == 0) {
          print(
            '[WindowsPrinterService] StartPagePrinter failed: ${GetLastError()}',
          );
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          return false;
        }

        // Copy data to native buffer
        final nativeData = calloc<Uint8>(data.length);
        final nativeList = nativeData.asTypedList(data.length);
        nativeList.setAll(0, data);

        final dwWritten = calloc<DWORD>();
        try {
          final written = WritePrinter(
            hPrinter.value,
            nativeData.cast(),
            data.length,
            dwWritten,
          );

          if (written == 0) {
            print(
              '[WindowsPrinterService] WritePrinter failed: ${GetLastError()}',
            );
          }
        } finally {
          calloc.free(nativeData);
          calloc.free(dwWritten);
        }

        EndPagePrinter(hPrinter.value);
        EndDocPrinter(hPrinter.value);
      } finally {
        calloc.free(docName);
        calloc.free(dataType);
        calloc.free(docInfo);
        ClosePrinter(hPrinter.value);
      }

      return true;
    } finally {
      calloc.free(hPrinter);
    }
  }
}

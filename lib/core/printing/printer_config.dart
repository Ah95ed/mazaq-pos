class PrinterConfig {
  final String id;
  final String name;
  final String? ip;
  final int? port;
  final PrinterType type;

  const PrinterConfig({
    required this.id,
    required this.name,
    required this.type,
    this.ip,
    this.port,
  });
}

enum PrinterType { usb, tcp }

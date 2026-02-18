/// Represents the configuration for a single printer role.
class PrinterConfig {
  final int id;
  final String role; // 'Cashier' | 'Kitchen' | 'Grill'
  final String? printerName; // Windows printer name (for Spooler API)
  final String? ip; // IP address (for direct TCP socket)
  final int port; // TCP port, default 9100
  final DateTime updatedAt;

  const PrinterConfig({
    required this.id,
    required this.role,
    this.printerName,
    this.ip,
    required this.port,
    required this.updatedAt,
  });

  PrinterConfig copyWith({String? printerName, String? ip, int? port}) {
    return PrinterConfig(
      id: id,
      role: role,
      printerName: printerName ?? this.printerName,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      updatedAt: DateTime.now(),
    );
  }
}

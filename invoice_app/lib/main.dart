import 'package:flutter/material.dart';
import 'package:invoice_app/src/utils/api_endpoint_page.dart';
import 'package:invoice_app/src/utils/cache_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CacheManager.init();

  runApp(const RealtimeInvoiceGenerationApp());
}

class RealtimeInvoiceGenerationApp extends StatelessWidget {
  const RealtimeInvoiceGenerationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: APIEndpointPage(),
    );
  }
}

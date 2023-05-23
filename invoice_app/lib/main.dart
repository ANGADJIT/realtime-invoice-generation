import 'package:flutter/material.dart';
import 'package:invoice_app/src/presentation/pages/home.dart';
import 'package:invoice_app/src/utils/api_endpoint_page.dart';

void main() {
  runApp(const RealtimeInvoiceGenerationApp());
}

class RealtimeInvoiceGenerationApp extends StatelessWidget {
  const RealtimeInvoiceGenerationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

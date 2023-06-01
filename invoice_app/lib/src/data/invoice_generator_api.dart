import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice_app/src/utils/cache_manager.dart';
import 'package:web_socket_channel/io.dart';

class InvoiceGeneratorApi {
  final String baseApiUrl = 'http://${CacheManager.apiHost}:8000/invoice';
  final String baseWebsocketUrl = 'ws://${CacheManager.apiHost}:8000/invoice';

  // api object
  final Dio _dio = Dio();

  InvoiceGeneratorApi() {
    _dio.options.baseUrl = baseApiUrl;
  }

  Future<String> sendPaymentEvent(Map<String, dynamic> paymentEvent) async {
    String transactionId = '';

    final IOWebSocketChannel channel =
        IOWebSocketChannel.connect(Uri.parse('$baseWebsocketUrl/generate'));

    // add payment event
    channel.sink.add(paymentEvent);

    // listen for events
    channel.stream.listen((event) {
      try {
        final response = event as Map;

        if (response.keys.contains('status')) {
          if (response['status'] == 200) {
            transactionId = response['transaction_id'];
          } else {
            throw Exception('something went wrong');
          }
        }
      } catch (e) {
        // nothing to do
      }
    });

    return transactionId;
  }

  Future<String> getInvoice(String transactionId) async {
    String invoicePath = '';

    try {
      final Response response = await _dio.get('/get_invoice');

      if (response.statusCode == 200) {
        final pdf = response.data;
        print(pdf);
      }
    } catch (e) {
      rethrow;
    }

    return invoicePath;
  }
}

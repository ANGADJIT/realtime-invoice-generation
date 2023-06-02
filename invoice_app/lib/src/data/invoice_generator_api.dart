import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:invoice_app/src/utils/custom_loading.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
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

  Future<void> sendPaymentEvent(
      String paymentEvent, BuildContext context) async {
    final IOWebSocketChannel channel =
        IOWebSocketChannel.connect(Uri.parse('$baseWebsocketUrl/generate'));

    CustomLoading.showLoading(context);

    // add payment event
    channel.sink.add(paymentEvent);

    // listen for events
    channel.stream.listen((event) {
      try {
        final response = jsonDecode(event);

        if (response.keys.contains('status')) {
          if (response['status'] == 200) {
            final transactionId = response['transaction_id'];

            _getInvoice(transactionId);
          } else {
            throw Exception('something went wrong');
          }
        }
      } catch (e) {
        // nothing to do
      }
    });
  }

  Future<void> _getInvoice(String transactionId) async {
    try {
      final Response response = await _dio.get('/get_invoice/$transactionId',
          options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        final pdfFile = response.data;

        // save file to dir
        final dir = await getExternalStorageDirectory();
        final filePath = '${dir!.path}/$transactionId.pdf';
        await File(filePath).writeAsBytes(pdfFile, flush: true);

        // launch file intent
        OpenFile.open(filePath);
        CustomLoading.dismiss();
      }
    } catch (e) {
      rethrow;
    }
  }
}

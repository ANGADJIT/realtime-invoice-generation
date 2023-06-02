import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:invoice_app/src/data/invoice_generator_api.dart';
import 'package:invoice_app/src/utils/colors.dart';
import 'package:invoice_app/src/utils/custom_media_query.dart';
import 'package:invoice_app/src/utils/strings.dart';
import 'package:pay/pay.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _amount;

  final Random _random = Random();

  // api object
  final InvoiceGeneratorApi _invoiceGeneratorApi = InvoiceGeneratorApi();

  @override
  void initState() {
    _generateRandomAmount();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VxAppBar(
        elevation: .0,
        backgroundColor: white,
        actions: [
          IconButton(
              onPressed: _generateRandomAmount,
              icon: Icon(
                Icons.refresh,
                color: purple,
              ))
        ],
      ),
      backgroundColor: white,
      body: SafeArea(
          child: VStack([
        //
        CustomMediaQuery.makeHeight(context, .1).heightBox,
        Image.asset(homeImageAssetPath),

        //
        CustomMediaQuery.makeHeight(context, .06).heightBox,
        FutureBuilder(
            future: PaymentConfiguration.fromAsset(googlePayConfiguration),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GooglePayButton(
                    loadingIndicator: CircularProgressIndicator(
                      backgroundColor: purple,
                      color: white,
                    ).centered(),
                    paymentConfiguration: snapshot.data,
                    onPaymentResult: (result) async {
                      try {
                        // add amount
                        result['amount'] = double.parse(_amount);

                        // add date
                        DateTime now = DateTime.now();
                        result['date'] = '${now.day}-${now.month}-${now.year}';

                        _invoiceGeneratorApi.sendPaymentEvent(
                            jsonEncode(result), context);
                      } catch (e) {
                        VxToast.show(context, msg: e.toString());
                      }
                    },
                    paymentItems: [
                      PaymentItem(
                          label: 'Total Amount',
                          amount: _amount,
                          status: PaymentItemStatus.final_price)
                    ]).centered();
              }

              return CircularProgressIndicator(
                backgroundColor: purple,
                color: white,
              ).centered();
            })
      ])),
    );
  }

  void _generateRandomAmount() => _amount = (_random.nextInt(1001) +
          double.parse(_random.nextDouble().toStringAsFixed(2)))
      .toString();
}

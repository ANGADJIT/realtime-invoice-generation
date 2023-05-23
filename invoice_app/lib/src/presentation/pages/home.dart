import 'dart:math';
import 'package:flutter/material.dart';
import 'package:invoice_app/src/utils/colors.dart';
import 'package:invoice_app/src/utils/custom_media_query.dart';
import 'package:invoice_app/src/utils/strings.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _amount;

  final Random _random = Random();

  @override
  void initState() {
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
              onPressed: () {},
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
        Image.asset(homeImageAssetPath)
      ])),
    );
  }

  void _generateRandomAmount() => _amount = _random.nextInt(1001);
}

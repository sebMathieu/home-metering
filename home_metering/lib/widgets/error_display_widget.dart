import 'package:flutter/material.dart';
import 'package:home_metering/utils/widgets.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final Object? error;

  const ErrorDisplayWidget({this.error, super.key});

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(translator.problemOccurred),
        const SizedBox(height: defaultMargin*2,),
        Text("${translator.description} : ${error?.toString() ?? translator.noInformationAvailable}"),
        const SizedBox(height: defaultMargin*2,),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inbank_frontend/colors.dart';
import 'package:inbank_frontend/fonts.dart';
import 'package:inbank_frontend/slider_style.dart';
import 'package:inbank_frontend/widgets/loan_form.dart';

void main() {
  runApp(const InBankApp());
}

class InBankApp extends StatelessWidget {
  const InBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Application',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.primaryColor,
        textTheme: TextTheme(
          displayLarge: displayLarge,
          bodyMedium: bodyMedium,
        ),
        sliderTheme: sliderThemeData,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: AppColors.primaryColor)
            .copyWith(secondary: AppColors.secondaryColor)
            .copyWith(error: AppColors.errorColor),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.textColor.withOpacity(0.3),
        ),
      ),
      home: const InBankForm(),
    );
  }
}

class InBankForm extends StatelessWidget {
  const InBankForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bodyHeight = screenHeight / 1.5;
    const minHeight = 500.0;
    final showText = bodyHeight > minHeight;

    return Scaffold(
      body: Center(
        child: SizedBox(
          height: max(minHeight, bodyHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: showText,
                child: Text(
                  'Act. Apply for a loan.',
                  style: displayLarge,
                ),
              ),
              if (showText) const SizedBox(height: 60),
              const LoanForm(),
            ],
          ),
        ),
      ),
    );
  }
}

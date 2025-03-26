import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inbank_frontend/fonts.dart';
import 'package:inbank_frontend/widgets/national_id_field.dart';

import '../api_service.dart';
import '../colors.dart';

const int minLoanPeriod = 12;
const int maxLoanPeriod = 48;

class LoanForm extends StatefulWidget {
  const LoanForm({Key? key}) : super(key: key);

  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String _nationalId = '';
  int _loanAmount = 2500;
  int _loanPeriod = 36;
  int _loanAmountResult = 0;
  int _loanPeriodResult = 0;
  String _errorMessage = '';
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _loanAmountResult = 0;
      _loanPeriodResult = 0;
    });

    final result = await _apiService.requestLoanDecision(
      _nationalId,
      _loanAmount,
      _loanPeriod,
    );

    setState(() {
      _isLoading = false;
      if (result['errorMessage'] != null && result['errorMessage'] != '') {
        _errorMessage = result['errorMessage'].toString();
      } else {
        _loanAmountResult = int.tryParse(result['loanAmount'].toString()) ?? 0;
        _loanPeriodResult = int.tryParse(result['loanPeriod'].toString()) ?? 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth / 3;
    const minWidth = 500.0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: max(minWidth, formWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FormField<String>(
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NationalIdTextFormField(
                            onChanged: (value) {
                              setState(() {
                                _nationalId = value ?? '';
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 60.0),
                  Text('Loan Amount: $_loanAmount €'),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _loanAmount.toDouble(),
                    min: 2000,
                    max: 10000,
                    divisions: 80,
                    label: '$_loanAmount €',
                    activeColor: AppColors.secondaryColor,
                    onChanged: _isLoading
                        ? null
                        : (double newValue) {
                      setState(() {
                        _loanAmount = ((newValue.floor() / 100).round() * 100);
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('2000€'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('10000€'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text('Loan Period: $_loanPeriod months'),
                  const SizedBox(height: 8),
                  Slider.adaptive(
                    value: _loanPeriod.toDouble(),
                    min: minLoanPeriod.toDouble(),
                    max: maxLoanPeriod.toDouble(),
                    divisions: (maxLoanPeriod - minLoanPeriod) ~/ 6,
                    label: '$_loanPeriod months',
                    activeColor: AppColors.secondaryColor,
                    onChanged: _isLoading
                        ? null
                        : (double newValue) {
                      setState(() {
                        _loanPeriod = ((newValue.floor() / 6).round() * 6);
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('12 months'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('48 months'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text('Approved Loan Amount: ${_loanAmountResult != 0 ? _loanAmountResult : "--"} €'),
              const SizedBox(height: 8.0),
              Text('Approved Loan Period: ${_loanPeriodResult != 0 ? _loanPeriodResult : "--"} months'),
              Visibility(
                visible: _errorMessage.isNotEmpty,
                child: Builder(
                  builder: (context) {
                    final lowerError = _errorMessage.toLowerCase();

                    if (lowerError.contains('under the minimum age')) {
                      return Text(
                        'You must be at least 18 years old to apply.',
                        style: errorMedium.copyWith(fontWeight: FontWeight.bold),
                      );
                    } else if (lowerError.contains('exceeds maximum')) {
                      return Text(
                        'You are above the eligible age limit for a loan.',
                        style: errorMedium.copyWith(fontWeight: FontWeight.bold),
                      );
                    } else if (lowerError.contains('age')) {
                      return Text(
                        'You are not eligible due to age requirements.',
                        style: errorMedium.copyWith(fontWeight: FontWeight.bold),
                      );
                    } else {
                      return Text(_errorMessage, style: errorMedium);
                    }
                  },
                ),
              )


            ],
          ),
        ],
      ),
    );
  }
}

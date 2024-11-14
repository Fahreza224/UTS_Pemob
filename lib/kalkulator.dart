import 'package:flutter/material.dart';
import 'dart:math';

class KalkulatorScreen extends StatefulWidget {
  @override
  _KalkulatorScreenState createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  String _display = '0';
  String _operand1 = '';
  String _operand2 = '';
  String _operator = '';
  bool _isSecondOperand = false;

  // [Previous calculation methods remain the same]
  void _inputNumber(String number) {
    setState(() {
      if (_isSecondOperand) {
        _operand2 += number;
        _display = _operand2;
      } else {
        _operand1 += number;
        _display = _operand1;
      }
    });
  }

  void _inputOperator(String operator) {
    setState(() {
      if (_operand1.isNotEmpty) {
        _operator = operator;
        _isSecondOperand = true;
      }
    });
  }

  void _calculate() {
    double num1 = double.tryParse(_operand1) ?? 0;
    double num2 = double.tryParse(_operand2) ?? 0;
    double result;

    switch (_operator) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '*':
        result = num1 * num2;
        break;
      case '/':
        result = num2 != 0 ? num1 / num2 : 0;
        break;
      case '%':
        result = num1 * (num2 / 100);
        break;
      case '√':
        result = sqrt(num1);
        break;
      case 'x²':
        result = pow(num1, 2).toDouble();
        break;
      default:
        result = num1;
    }

    setState(() {
      _display = result.toString();
      _operand1 = result.toString();
      _operand2 = '';
      _operator = '';
      _isSecondOperand = false;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operand1 = '';
      _operand2 = '';
      _operator = '';
      _isSecondOperand = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_isSecondOperand) {
        if (_operand2.isNotEmpty) {
          _operand2 = _operand2.substring(0, _operand2.length - 1);
          _display = _operand2.isEmpty ? '0' : _operand2;
        }
      } else {
        if (_operand1.isNotEmpty) {
          _operand1 = _operand1.substring(0, _operand1.length - 1);
          _display = _operand1.isEmpty ? '0' : _operand1;
        }
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_isSecondOperand) {
        _operand2 = (_operand2.startsWith('-')
            ? _operand2.substring(1)
            : '-$_operand2');
        _display = _operand2;
      } else {
        _operand1 = (_operand1.startsWith('-')
            ? _operand1.substring(1)
            : '-$_operand1');
        _display = _operand1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5FF),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Calculator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B4865),
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        // Menambahkan SafeArea
        child: Column(
          children: <Widget>[
            // Display Container
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _operator.isEmpty ? '' : '$_operand1 $_operator',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF256D85).withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _display,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF256D85),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Calculator Buttons Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 30, 20, 20), // Mengurangi padding bottom
              child: GridView.builder(
                // Menggunakan GridView.builder
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 20, // Jumlah total tombol
                itemBuilder: (context, index) {
                  // Definisi tombol berdasarkan index
                  final List<String> buttons = [
                    'C',
                    '⌫',
                    '%',
                    '/',
                    '7',
                    '8',
                    '9',
                    '*',
                    '4',
                    '5',
                    '6',
                    '-',
                    '1',
                    '2',
                    '3',
                    '+',
                    '+/-',
                    '0',
                    '.',
                    '=',
                  ];

                  // Menentukan warna tombol
                  Color? buttonColor;
                  if (buttons[index] == 'C') {
                    buttonColor = Color(0xFFFF6B6B);
                  } else if (['⌫', '%', '/', '*', '-', '+', '=']
                      .contains(buttons[index])) {
                    buttonColor = Color(0xFF8CB9BD);
                  } else if (buttons[index] == '=') {
                    buttonColor = Color(0xFF2B4865);
                  }

                  return _buildButton(buttons[index], color: buttonColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, {Color? color}) {
    bool isOperator = ['+', '-', '*', '/', '%', '='].contains(label);
    bool isClear = label == 'C';
    bool isEquals = label == '=';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (label == 'C') {
            _clear();
          } else if (label == '⌫') {
            _backspace();
          } else if (label == '=') {
            _calculate();
          } else if (['+', '-', '*', '/', '%', '√', 'x²'].contains(label)) {
            _inputOperator(label);
          } else if (label == '+/-') {
            _toggleSign();
          } else {
            _inputNumber(label);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isOperator ? 28 : 24,
                fontWeight: isEquals ? FontWeight.w700 : FontWeight.w600,
                color: isClear
                    ? Colors.white
                    : isEquals
                        ? Colors.white
                        : isOperator
                            ? Color(0xFF256D85)
                            : Color(0xFF2B4865),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

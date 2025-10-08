import 'package:flutter/material.dart';

class NumberPadModel extends ChangeNotifier {
  String _input = '';

  String get input => _input;

  void addNumber(int number) {
    if (_input.length >= 2) return;
    _input += number.toString();
    notifyListeners();
  }

  void deleteNumber() {
    if (_input.isEmpty) return;
    _input = _input.substring(0, _input.length - 1);
    notifyListeners();
  }

  void clearNumber() {
    _input = '';
    notifyListeners();
  }
}

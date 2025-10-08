import 'package:clinic_parking/popup/assets.dart';
import 'package:clinic_parking/provider/number_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'car_discount.dart';

class FourDigitNumberPad extends StatelessWidget {
  const FourDigitNumberPad({super.key});

  Future<void> onSubmit(BuildContext context) async {
    final carNumberProvider =
    Provider.of<NumberPadModel>(context, listen: false);
    try {
      String carNumber = carNumberProvider.input;
      if (carNumberProvider.input.length >= 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarDiscountPage(carNumber: carNumber)));
        carNumberProvider.clearNumber();
      } else {
        Assets().showPopupAutoPop(context, '차량 번호는 2자리 이상 입력해주세요.');
      }
    } catch (e) {
      Assets().showPopupAutoPop(context, '차량 조회에 실패했습니다.');
    }
  }

  Widget _buildNumberButton(
      int number, NumberPadModel carNumberProvider, BuildContext context) {
    if (number >= 1 && number <= 9) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.addNumber(number),
          child: Text(
            number.toString(),
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red // 수정: 버튼 텍스트 색상을 레드로 변경
            ),
          ),
        ),
      );
    } else if (number == 10) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.deleteNumber(),
          child: const Icon(
            Icons.arrow_back,
            size: 50,
            color: Colors.red, // 수정: 아이콘 색상을 레드로 변경
          ),
        ),
      );
    } else if (number == 11) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.addNumber(0),
          child: const Text(
            '0',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red // 수정: 버튼 텍스트 색상을 레드로 변경
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            await onSubmit(context);
          },
          child: const Text(
            '조회',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red // 수정: 버튼 텍스트 색상을 레드로 변경
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPinDisplayCard(BuildContext context, String digit) {
    double boxSize = MediaQuery.of(context).size.width * 0.1;
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: Colors.red, width: 2), // 수정: 테두리 색상을 Colors.blue에서 Colors.red로 변경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
              fontSize: 80, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carNumberProvider = Provider.of<NumberPadModel>(context);
    var size = MediaQuery.of(context).size;
    final double screenHeight = (size.height - kToolbarHeight - 24) / 2;
    final double screenWidth = size.width;
    final paddedInput = carNumberProvider.input.padRight(4, ' ');
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: (size.height - kToolbarHeight - 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left input area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '차량 번호를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: paddedInput
                        .split('')
                        .map((digit) => _buildPinDisplayCard(context, digit))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Right number pad area
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: (screenHeight) / 2.5),
                child: GridView.count(
                  childAspectRatio: screenWidth / screenHeight / 2,
                  crossAxisCount: 3,
                  children: List.generate(12, (index) {
                    int number = index + 1;
                    return _buildNumberButton(
                        number, carNumberProvider, context);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
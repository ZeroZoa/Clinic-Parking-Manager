import 'package:flutter/material.dart';

class Assets {
  void showPopupAutoPop(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width * 0.7; // 너비 조정
        final height = MediaQuery.of(context).size.height * 0.4; // 높이 조정
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게 변경
          ),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // 모서리 둥글게 변경
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '알림',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold, // 글꼴 두께 추가
                        color: Color(0xFF465974),
                        letterSpacing: 1.0, // 자간 설정
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void showPopupAndReturnMain(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width * 0.7; // 너비 조정
        final height = MediaQuery.of(context).size.height * 0.4; // 높이 조정
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게 변경
          ),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // 모서리 둥글게 변경
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '알림',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        // const로 부터 수정
                        fontSize: 30,
                        fontWeight: FontWeight.bold, // 글꼴 두께 추가
                        color: Color(0xFF465974),
                        letterSpacing: 1.0, // 자간 설정
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void showErrorSnackBar(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(message ?? ""),
          ],
        ),
        backgroundColor: Colors.red[200],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

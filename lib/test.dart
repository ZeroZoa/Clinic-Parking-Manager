import 'package:flutter/material.dart';

import 'api/parking_api.dart';


class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await ParkingApi().checkSession();
            },
            child: const Text('테스트 API 호출'),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await ParkingApi().logout();
            },
            child: const Text('로그아웃'),
          ),
        ),
      ],
    );
  }
}

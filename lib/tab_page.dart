import 'dart:async';

import 'package:clinic_parking/popup/assets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api/parking_api.dart';
import 'key_pad.dart';
import 'manage_page.dart';


class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription<ConnectivityResult>? _networkListenrs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);

    setNetworkChecker();
    setSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _networkListenrs?.cancel();
    super.dispose();
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('인터넷 연결 없음'),
          content: const Text('인터넷 연결이 해제되었습니다. 다시 연결해주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  void setNetworkChecker() async {
    // 초기 1회
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionDialog();
    }

    // 리스너 등록
    _networkListenrs = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _showConnectionDialog();
      }
    });
  }

  void setSession() async {
    try {
      await dotenv.load(fileName: ".env");
      await ParkingApi().login();
    } on Exception catch (e) {
      Assets().showPopupAutoPop(context, '로그인에 실패했습니다.\n [$e]');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '주차 등록'),
              Tab(text: '차량 목록'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FourDigitNumberPad(),
            CarInfoTablePage(),
          ],
        ),
      ),
    );
  }
}

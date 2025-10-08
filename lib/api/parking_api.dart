import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../model/car_entrance_info.dart';
import '../model/car_info.dart';
import '../model/db_helper.dart';
import '../model/discount_type.dart';
import '../model/error_msg.dart';

class ParkingApi {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final timoutTime = const Duration(seconds: 2);

  Future<String> getSessionId() async {
    final url = Uri.parse(baseUrl);
    final response = await http
        .get(
      url,
    )
        .timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    final String? setCookie = response.headers[HttpHeaders.setCookieHeader];

    if (setCookie != null) {
      debugPrint('Set-Cookie: $setCookie');
      final jsessionIdRegExp = RegExp(r'JSESSIONID=([^;]+)');
      final jsessionIdMatch = jsessionIdRegExp.firstMatch(setCookie);

      if (jsessionIdMatch != null) {
        final jsessionId = jsessionIdMatch.group(1);
        debugPrint('JSESSIONID: $jsessionId');
        if (jsessionId != null) {
          return jsessionId;
        }
      }
    }
    debugPrint('JSESSIONID not found');
    throw Exception('JSESSIONID 세팅 실패');
  }

  Future<void> login() async {
    String sessionId = await getSessionId();
    String id = dotenv.env['ID']!;
    String pw = dotenv.env['PW']!;
    await _storage.write(key: 'sessionId', value: sessionId);
    final url = Uri.parse('$baseUrl/login?referer&userId=$id&userPwd=$pw');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });
    if (response.statusCode != 302) {
      throw Exception('로그인에 실패했습니다.\n [${response.statusCode}]');
    }
  }

  Future<void> logout() async {
    String? sessionId = await _storage.read(key: 'sessionId');
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    debugPrint('${response.statusCode}');
  }

  Future<void> checkSession() async {
    String? sessionId = await _storage.read(key: 'sessionId');
    String id = dotenv.env['ID']!;
    String entryDate =
        DateTime.now().toString().substring(0, 10).replaceAll('-', '');
    if (sessionId == null) {
      debugPrint('세션 생성');
      await ParkingApi().login();
      return;
    }

    try {
      final url = Uri.parse(
          '$baseUrl/state/doListMst?startDate=$entryDate&endDate=$entryDate&account_no=$id&dc_id=&carno=&corp=&paid_stat=&master_id=&rowcount=1000');
      final response = await http.post(
        url,
        headers: {
          'Cookie': 'JSESSIONID=$sessionId',
        },
      ).timeout(timoutTime, onTimeout: () {
        throw TimeoutException("Request took too long.");
      });

      jsonDecode(response.body);
      debugPrint('세션 유지됨');
      return;
    } catch (e) {
    }

    debugPrint('세션 재설정 시도');
    // 세션 갱신 시도
    try {
      await login();
    } catch (e) {
      throw Exception('세션 갱신 실패');
    }
  }

  Future<List<CarEntranceInfo>> getCarListByNumber(String carNumber) async {
    await checkSession();
    String? sessionId = await _storage.read(key: 'sessionId');
    String iLotArea = dotenv.env['I_LOT_AREA']!;
    String entryDate =
        DateTime.now().toString().substring(0, 10).replaceAll('-', '');

    if (sessionId == null) {
      throw Exception('세션ID 없음');
    }

    final url = Uri.parse(
        '$baseUrl/discount/registration/listForDiscount?iLotArea=$iLotArea&entryDate=$entryDate&carNo=$carNumber');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode != 200) {
      throw Exception('차량 정보 요청 실패 ${response.statusCode}');
    }

    debugPrint(response.body);
    List<dynamic> carListJson = jsonDecode(response.body);

    List<CarEntranceInfo> carList =
        carListJson.map((json) => CarEntranceInfo.fromJson(json)).toList();

    return carList;
  }

  Future<void> checkDiscountable(CarEntranceInfo carEntranceInfo) async {
    String? sessionId = await _storage.read(key: 'sessionId');
    String id = dotenv.env['ID']!;
    if (sessionId == null) {
      throw Exception('세션ID 없음');
    }

    final url = Uri.parse(
        '$baseUrl/discount/registration/getForDiscount?id=${carEntranceInfo.id}&member_id=$id');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode != 200) {
      throw Exception('할인권 정보 요청 실패');
    }

    Map<String, dynamic> discountInfoJson = jsonDecode(response.body);
    List<dynamic> listDiscountTypeJson = discountInfoJson['listDiscountType'];
    List<DiscountType> listDiscountType = listDiscountTypeJson
        .map((json) => DiscountType.fromJson(json))
        .toList();
    debugPrint(listDiscountType.toString());
    try {
      DiscountType targetDiscountType = listDiscountType.firstWhere(
        (discountType) =>
            discountType.discountName.compareTo('2시간할인(1회사용가능)') == 0,
      );

      if (targetDiscountType.discountValue.toInt() != 120 ||
          targetDiscountType.id != '2') {
        throw Exception();
      }
    } catch (e) {
      throw Exception('2시간 할인권 조회 실패');
    }
  }

  Future<void> giveDiscount(CarEntranceInfo carEntranceInfo) async {
    String? sessionId = await _storage.read(key: 'sessionId');
    String encodedCarNo = Uri.encodeComponent(carEntranceInfo.carNo);
    if (sessionId == null) {
      throw Exception('세션ID 없음');
    }

    final url = Uri.parse(
        '$baseUrl/discount/registration/save?peId=${carEntranceInfo.id}&discountType=2&carNo=$encodedCarNo&acPlate2&memo');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    debugPrint(response.body);

    if (response.statusCode != 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      ErrorMsg error = ErrorMsg.fromJson(json);
      throw Exception(error.errorMsg);
    }

    CarInfo newInfo = CarInfo(
        id: null,
        carNum: carEntranceInfo.carNo,
        date: DateTime.now(),
        isChecked: 0);
    await ParkingInfoDB().insert(newInfo);
  }

  Future<void> getDicountedList(CarEntranceInfo carEntranceInfo) async {
    String? sessionId = await _storage.read(key: 'sessionId');
    String id = dotenv.env['ID']!;
    String entryDate =
        DateTime.now().toString().substring(0, 10).replaceAll('-', '');
    if (sessionId == null) {
      throw Exception('세션ID 없음');
    }

    final url = Uri.parse(
        '$baseUrl/state/doListMst?startDate=$entryDate&endDate=$entryDate&account_no=$id&dc_id=&carno=&corp=&paid_stat=&master_id=&rowcount=1000');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'JSESSIONID=$sessionId',
      },
    ).timeout(timoutTime, onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode != 200) {
      throw Exception('할인권 정보 요청 실패');
    }

    Map<String, dynamic> discountInfoJson = jsonDecode(response.body);
    List<dynamic> listDiscountTypeJson = discountInfoJson['data'];
    List<DiscountType> listDiscountType = listDiscountTypeJson
        .map((json) => DiscountType.fromJson(json))
        .toList();
  }
}

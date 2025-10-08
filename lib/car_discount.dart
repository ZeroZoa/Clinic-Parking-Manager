import 'package:cached_network_image/cached_network_image.dart';
import 'package:clinic_parking/popup/assets.dart';
import 'package:flutter/material.dart';

import 'api/parking_api.dart';
import 'model/car_entrance_info.dart';

class CarDiscountPage extends StatefulWidget {
  final String? carNumber;

  const CarDiscountPage({super.key, required this.carNumber});

  @override
  State<CarDiscountPage> createState() => _CarDiscountPageState();
}

class _CarDiscountPageState extends State<CarDiscountPage> {
  CarEntranceInfo? _selectedCar;
  bool _isLoading = true;
  List<CarEntranceInfo> carEntranceInfos = [

  ];

  @override
  void initState() {
    setCarList();
    super.initState();
  }

  void setCarList() async {
    try {
      List<CarEntranceInfo> carEntranceRes =
          await ParkingApi().getCarListByNumber(widget.carNumber!);

      if (carEntranceRes.isEmpty) {
        Assets().showPopupAndReturnMain(
            context, '차량 번호 [${widget.carNumber}]가 존재하지 않습니다.');
        return;
      }
      if (carEntranceRes.length == 1) {
        _selectedCar = carEntranceRes[0];
      }

      setState(() {
        carEntranceInfos = carEntranceRes;
        _isLoading = false;
      });
    } catch (e) {
      Assets().showPopupAndReturnMain(context, '차량 번호 조회에 실패했습니다. [서버 접속 실패]');
      return;
    }
  }

  void onDiscountRequest(DateTime entryDate) async {
    try {
      // 등록 로직
      await ParkingApi().checkDiscountable(_selectedCar!);
      await ParkingApi().giveDiscount(_selectedCar!);

      DateTime endTime = entryDate.add(const Duration(hours: 2));
      Assets().showPopupAndReturnMain(context,
          '2시간 주차권이 등록되었습니다. [${endTime.toString().substring(11, 19)} 까지] \n추가 등록은 직원에게 문의해주세요.');
    } on Exception catch (e) {
      Assets().showPopupAutoPop(context,
          '주차권 등록에 실패했습니다.\n[${e.toString().substring(12)}]\n직원에게 문의해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주차권 등록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDataTable(
                        carEntranceInfos, screenWidth, screenheight),
                    const Divider(thickness: 1),
                    _buildSubmitButton(
                        carEntranceInfos, screenWidth, screenheight)
                  ],
                )),
                const VerticalDivider(width: 1),
                Expanded(
                    child: _buildVehicleInfoDisplay(screenWidth, screenheight)),
              ],
            ),
    );
  }

  Widget _buildDataTable(List<CarEntranceInfo> carEntranceInfos,
      double screenWidth, double screenheight) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(height: screenheight * 0.08),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label: SizedBox(
                    width: 60,
                    child: Center(
                        // 추가된 줄: 텍스트 중앙 정렬
                        child: Text(
                      'ID',
                      style: TextStyle(fontSize: 22, color: Colors.blue),
                    )))),
            DataColumn(
                label: SizedBox(
                    width: 100,
                    child: Text(
                      '차량 번호',
                      style: TextStyle(fontSize: 22, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ))),
            DataColumn(
                label: SizedBox(
                    width: 180,
                    child: Center(
                        // 추가된 줄: 텍스트 중앙 정렬
                        child: Text(
                      '입차 시간',
                      style: TextStyle(fontSize: 22, color: Colors.blue),
                    )))),
            DataColumn(
                label: SizedBox(
                    width: 100,
                    child: Text(
                      '  ',
                      style: TextStyle(fontSize: 22, color: Colors.blue),
                      textAlign: TextAlign.left,
                    )))
          ],
          rows: carEntranceInfos.map((carInfo) {
            return DataRow(cells: [
              DataCell(Text(carInfo.id.toString(),
                  style: const TextStyle(fontSize: 20))),
              DataCell(Text(carInfo.carNo,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold))),
              DataCell(Text(carInfo.entryTime.toString().substring(0, 19),
                  style: const TextStyle(fontSize: 20))),
              DataCell(ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCar = carInfo;
                  });
                },
                child: const Text('선택', style: TextStyle(fontSize: 18)),
              )),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildSubmitButton(List<CarEntranceInfo> carEntranceInfos,
      double screenWidth, double screenheight) {
    DateTime? discountTime;
    String formattedTime = '';

    if (_selectedCar != null) {
      discountTime = _selectedCar!.entryTime.add(const Duration(hours: 2));
      formattedTime = '${discountTime.hour}시 ${discountTime.minute}분';
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
        child: Container(
          width: screenWidth * 0.48,
          height: screenheight * 0.4,
          padding: const EdgeInsets.all(20.0),
          child: _selectedCar == null
              ? const Center(
                  child: Text(
                    '주차권 등록을 위해 차량을 선택해주세요.',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '2시간 주차 할인 등록을 위해 아래 버튼을 눌러주세요.',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        onDiscountRequest(_selectedCar!.entryTime);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '2시간 주차권 등록(1회만 가능)',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '할인권 적용 시간은 [',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: formattedTime,
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                                fontWeight:
                                    FontWeight.w700), // 리뷰라인: 원하는 색상으로 변경하세요.
                          ),
                          TextSpan(
                            text: ']까지 입니다.',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '할인권 추가 등록은 직원에게 문의해주세요.',
                      style:
                          TextStyle(fontSize: 24, color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoDisplay(double screenWidth, double screenHeight) {
    if (_selectedCar == null) {
      return const Center(
          child: Text('차량을 선택해주세요.', style: TextStyle(fontSize: 30)));
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '차량 정보',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     onDiscountRequest(_selectedCar!.entryTime);
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.white,
                        //     backgroundColor: Colors.red,
                        //     shadowColor: Colors.blue,
                        //     padding: const EdgeInsets.symmetric(
                        //         vertical: 15.0, horizontal: 20.0),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     '2시간 주차권 등록을 위해 터치해주세요',
                        //     style: TextStyle(
                        //         fontSize: 24, fontWeight: FontWeight.bold),
                        //   ),
                        // )
                      ],
                    ),
                    const Divider(thickness: 2),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('차량번호',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      trailing: Text(_selectedCar!.carNo,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('입차시간',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      trailing: Text(
                          _selectedCar!.entryTime.toString().substring(0, 19),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(thickness: 1),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('차량사진',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    CachedNetworkImage(
                      imageUrl:
                          'https://bphyosung.parkingweb.kr/image/${_selectedCar!.acEntrancePicName}',
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.45,
                      fit: BoxFit.scaleDown,
                      errorWidget: (context, url, error) => const Center(
                          child: Text(
                        '이미지를 불러올 수 없습니다.',
                        style: TextStyle(fontSize: 20),
                      )),
                      placeholder: (context, url) => SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.4,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

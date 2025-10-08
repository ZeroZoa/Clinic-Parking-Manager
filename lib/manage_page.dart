import 'package:clinic_parking/popup/assets.dart';
import 'package:flutter/material.dart';

import 'model/car_info.dart';
import 'model/db_helper.dart';

class CarInfoTablePage extends StatefulWidget {
  const CarInfoTablePage({Key? key}) : super(key: key);

  @override
  State<CarInfoTablePage> createState() => _CarInfoTablePageState();
}

class _CarInfoTablePageState extends State<CarInfoTablePage> {
  List<CarInfo> carInfos = [];
  String carNumberFilter = '';
  DateTime? selectedDate = DateTime.now();
  TextEditingController carNumberController = TextEditingController();
  int unconfirmedCount = 0;
  int todayCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setTodayData();
  }

  Future<void> setTodayData() async {
    setState(() => _isLoading = true);
    try {
      final fetchedCarInfos = await ParkingInfoDB()
          .getAllCarInfosByDate(DateTime.now().toString().substring(0, 10));
      if (!mounted) return;
      setState(() {
        carInfos = fetchedCarInfos;
        unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
        todayCount = fetchedCarInfos.length;
        carNumberFilter = '';
        carNumberController.clear();
        selectedDate = DateTime.now();
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) Assets().showPopupAutoPop(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> setAllData() async {
    setState(() => _isLoading = true);
    try {
      final fetchedCarInfos = await ParkingInfoDB().getAllCarInfos();
      if (!mounted) return;
      setState(() {
        carInfos = fetchedCarInfos;
        unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
        carNumberFilter = '';
        carNumberController.clear();
        selectedDate = null;
      });
    } catch (e) {
      if (mounted) Assets().showPopupAutoPop(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> onSearch() async {
    setState(() => _isLoading = true);
    try {
      late List<CarInfo> fetchedCarInfos;
      if (carNumberFilter.isNotEmpty && selectedDate != null) {
        fetchedCarInfos = await ParkingInfoDB().getAllCarInfosByCarNumberAndDate(
            carNumberFilter, selectedDate.toString().substring(0, 10));
      } else if (carNumberFilter.isNotEmpty) {
        fetchedCarInfos =
        await ParkingInfoDB().getAllCarInfosByCarNumber(carNumberFilter);
      } else if (selectedDate != null) {
        fetchedCarInfos = await ParkingInfoDB()
            .getAllCarInfosByDate(selectedDate.toString().substring(0, 10));
      } else {
        fetchedCarInfos = await ParkingInfoDB().getAllCarInfos();
      }
      if (!mounted) return;
      setState(() {
        carInfos = fetchedCarInfos;
        unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) Assets().showPopupAutoPop(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void resetFilter() {
    setState(() {
      carNumberFilter = '';
      selectedDate = null;
      carNumberController.clear();
    });
    setAllData();
  }

  Future<void> onConfirm(int? id) async {
    if (id == null) {
      Assets().showPopupAutoPop(context, 'ID가 제공되지 않았습니다.');
      return;
    }
    try {
      await ParkingInfoDB().updateConfirm(id, true);
      if (!mounted) return;
      setState(() {
        final index = carInfos.indexWhere((info) => info.id == id);
        if (index != -1) {
          carInfos[index].isChecked = 1;
          unconfirmedCount =
              carInfos.where((info) => info.isChecked == 0).length;
        }
      });
    } catch (e) {
      if (mounted) Assets().showPopupAutoPop(context, '데이터베이스 업데이트 중 오류가 발생했습니다.');
    }
  }

  Future<void> deleteRow(int? id) async {
    if (id == null) {
      Assets().showPopupAutoPop(context, 'ID가 제공되지 않았습니다.');
      return;
    }
    try {
      await ParkingInfoDB().delete(id);
      if (!mounted) return;
      final newTodayCount = (await ParkingInfoDB()
          .getAllCarInfosByDate(DateTime.now().toString().substring(0, 10)))
          .length;
      setState(() {
        carInfos.removeWhere((info) => info.id == id);
        unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
        todayCount = newTodayCount;
      });
    } catch (e) {
      if (mounted) Assets().showPopupAutoPop(context, '데이터베이스 업데이트 중 오류가 발생했습니다.');
    }
  }

  void onDelete(int? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 데이터를 정말 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                '삭제',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteRow(id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // 수정: 로딩 인디케이터를 FAB 대신 Stack을 사용해 화면 중앙에 오버레이합니다.
        // 이 방식이 더 표준적이며 다른 UI와의 충돌을 피할 수 있습니다.
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: DataTable(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        headingRowColor: MaterialStateProperty.all(
                            themeData.colorScheme.primary.withOpacity(0.1)),
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeData.colorScheme.primary,
                        ),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('차량 번호')),
                          DataColumn(label: Text('날짜')),
                          DataColumn(label: Center(child: Text('확인'))),
                          DataColumn(label: Center(child: Text('삭제'))),
                        ],
                        rows: carInfos.map((carInfo) {
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (carInfos.indexOf(carInfo) % 2 == 0) {
                                  return Colors.grey.withOpacity(0.05);
                                }
                                return null;
                              },
                            ),
                            cells: [
                              DataCell(Text(carInfo.id.toString())),
                              DataCell(Text(carInfo.carNum)),
                              DataCell(Text(
                                  carInfo.date.toString().substring(0, 19))),
                              DataCell(
                                Center(
                                  child: carInfo.isChecked == 1
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '확인됨',
                                        style: TextStyle(
                                            color: Colors.green[700]),
                                      ),
                                    ],
                                  )
                                      : ElevatedButton(
                                    onPressed: () => onConfirm(carInfo.id),
                                    child: const Text('확인'),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      themeData.colorScheme.error,
                                      foregroundColor:
                                      themeData.colorScheme.onError,
                                    ),
                                    onPressed: () => onDelete(carInfo.id),
                                    child: const Text('삭제'),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1.0, thickness: 1.0),
                Expanded(
                  flex: 3,
                  child: _buildSidePanel(themeData),
                ),
              ],
            ),
            // 로딩 중일 때 반투명한 배경과 함께 인디케이터를 표시합니다.
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(ThemeData themeData) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 수정: 각 섹션을 Card 위젯으로 감싸서 입체감과 구분감을 줍니다.
            Card(
              elevation: 2, // 그림자 효과
              margin: const EdgeInsets.only(bottom: 16.0), // 카드 간 간격
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildFilterSection(themeData),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDataActions(),
              ),
            ),
            Card(
              elevation: 2,
              child: _buildSummarySection(themeData), // 요약 섹션은 자체 패딩이 있으므로 그대로 사용
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('필터', style: themeData.textTheme.titleLarge),
        const Divider(height: 24),
        Text('차량번호 검색', style: themeData.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          controller: carNumberController,
          decoration: const InputDecoration(
            hintText: '차량 번호 입력',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => carNumberFilter = value),
        ),
        const SizedBox(height: 16),
        Text('날짜 선택', style: themeData.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() => selectedDate = pickedDate);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              selectedDate == null
                  ? "날짜를 선택해주세요"
                  : "${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일",
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton(
              onPressed: resetFilter,
              child: const Text('필터 초기화'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onSearch();
                },
                child: const Text('검색'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('데이터 조회', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: setTodayData,
          child: const Text('오늘 데이터 조회'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: setAllData,
          child: const Text('모든 데이터 조회'),
        ),
      ],
    );
  }

  Widget _buildSummarySection(ThemeData themeData) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // 수정: Card를 사용하므로 배경색과 테두리는 Card가 담당하도록 제거 가능
      // decoration: BoxDecoration(...)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('요약 정보', style: themeData.textTheme.titleMedium),
          const Divider(height: 16),
          _buildSummaryInfoRow(
            icon: Icons.warning_amber_rounded,
            label: '미확인 차량:',
            count: unconfirmedCount,
            color: themeData.colorScheme.error,
          ),
          const SizedBox(height: 8),
          _buildSummaryInfoRow(
            icon: Icons.calendar_today,
            label: '오늘 등록 차량:',
            count: todayCount,
            color: themeData.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryInfoRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          '$count 대',
          style:
          TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
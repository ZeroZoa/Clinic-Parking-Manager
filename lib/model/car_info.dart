class CarInfo {
  int? id;
  String carNum;
  DateTime date;
  int isChecked;

  CarInfo(
      {required this.id,
      required this.carNum,
      required this.date,
      required this.isChecked});

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id'],
      carNum: json['carNumber'],
      date: DateTime.parse(json['date']),
      isChecked: json['isChecked'],
    );
  }

  // CarInfo 객체 to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['carNumber'] = carNum;
    data['date'] = date.toIso8601String();
    data['isChecked'] = isChecked;
    return data;
  }
}

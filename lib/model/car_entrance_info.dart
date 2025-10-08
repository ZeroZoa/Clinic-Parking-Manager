class CarEntranceInfo {
  final int id;
  final String carNo;
  final DateTime entryTime;
  final String? acEntrancePicName;

  CarEntranceInfo(
      {required this.id,
      required this.carNo,
      required this.entryTime,
      required this.acEntrancePicName});

  factory CarEntranceInfo.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String carNo = json['carNo'];

    DateTime entryTime;
    if (json['entryDate'] != null) {
      entryTime = DateTime.fromMillisecondsSinceEpoch(json['entryDate']);
    } else {
      entryTime = DateTime.parse(json['entryDateToString']);
    }

    String? acEntrancePicName = json['acEntrancePicName'];

    return CarEntranceInfo(
      id: id,
      carNo: carNo,
      entryTime: entryTime,
      acEntrancePicName: acEntrancePicName,
    );
  }
}

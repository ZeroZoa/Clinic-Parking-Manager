class ErrorMsg {
  final String errorCode;
  final String errorMsg;

  ErrorMsg({
    required this.errorCode,
    required this.errorMsg,
  });

  factory ErrorMsg.fromJson(Map<String, dynamic> json) {
    return ErrorMsg(
      errorCode: json['errorCode'],
      errorMsg: json['errorMsg'],
    );
  }

  @override
  String toString() {
    return 'ErrorMsg(errorCode: $errorCode, errorMsg: $errorMsg)';
  }
}

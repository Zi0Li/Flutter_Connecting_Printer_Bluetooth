class PrinterModel {
  int? id;
  String? mac;
  String? name;

  PrinterModel();

  PrinterModel.fromMap(Map map) {
    name = map['name'];
    mac = map['mac'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'mac': mac,
    };
    return map;
  }

  @override
  String toString() {
    return "Printer(ID: $id / Name: $name / Mac: $mac)";
  }
}

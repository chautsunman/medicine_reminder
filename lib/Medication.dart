class Medication {
  int id;
  final String name;

  Medication({this.id, this.name});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

class Medication {
  final String name;

  Medication({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name
    };
  }
}

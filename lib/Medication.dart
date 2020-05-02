class Medication {
  int id;
  final String name;
  String photoFileName;

  Medication({this.id, this.name, this.photoFileName});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'photo_file_name': photoFileName
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

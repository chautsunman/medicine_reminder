class MedicationObj {
  int id;
  final String name;
  String photoFileName;

  MedicationObj({this.id, this.name, this.photoFileName});

  MedicationObj.fromDbMap(Map<String, dynamic> map) : this(
    id: map['id'],
    name: map['name'],
    photoFileName: map['photo_file_name'],
  );

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

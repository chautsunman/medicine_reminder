class MedicationObj {
  int id;
  final String name;
  String photoFileName;

  MedicationObj({this.id, this.name, this.photoFileName});

  MedicationObj.fromDbMap(Map<String, dynamic> map, {String keyPrefix = ''}) : this(
    id: map.containsKey('${keyPrefix}id') ? map['${keyPrefix}id'] : null,
    name: map.containsKey('${keyPrefix}name') ? map['${keyPrefix}name'] : null,
    photoFileName: map.containsKey('${keyPrefix}photo_file_name') ? map['${keyPrefix}photo_file_name'] : null,
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

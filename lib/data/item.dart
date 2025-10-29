class Item {
  final int? id;
  final String text;
  final int createdAt;


  Item({this.id, required this.text, required this.createdAt});


  Item copyWith({int? id, String? text, int? createdAt}) => Item(
    id: id ?? this.id,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
  );


  factory Item.fromMap(Map<String, Object?> map) => Item(
    id: map['id'] as int?,
    text: map['text'] as String,
    createdAt: map['created_at'] as int,
  );


  Map<String, Object?> toMap() => {
    'id': id,
    'text': text,
    'created_at': createdAt,
  };
}
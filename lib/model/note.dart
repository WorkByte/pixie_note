import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';
/*
@JsonSerializable()
class NotesGroup {
  String? groupTitle;
  List<Note>? notes;
  int? lastUpdated;
  String? id;

  NotesGroup(this.id, this.groupTitle, this.notes, this.lastUpdated);

  factory NotesGroup.fromJson(Map<String, dynamic> json) =>
      _$NotesGroupFromJson(json);

  Map<String, dynamic> toJson() => _$NotesGroupToJson(this);
}*/

@JsonSerializable()
class Note {
  String? id;
  Map<String, NoteItem>? noteItems;
  String? title;
  String? type;
  List<String>? tags;
  bool? obscureText;
  int? lastUpdated;
  int? noteColor;

  Note(
      {this.id,
      this.title,
      this.type,
      this.obscureText,
      this.noteItems,
      this.noteColor,
      this.tags,
      this.lastUpdated});

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

@JsonSerializable()
class NoteItem {
  String? id;
  String? note;
  String? type;
  bool? obscureText;
  bool? enableCopy;

  NoteItem({this.id, this.note, this.type, this.obscureText, this.enableCopy});

  factory NoteItem.fromJson(Map<String, dynamic> json) =>
      _$NoteItemFromJson(json);

  Map<String, dynamic> toJson() => _$NoteItemToJson(this);
}

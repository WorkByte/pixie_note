// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      obscureText: json['obscureText'] as bool?,
      noteItems: (json['noteItems'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, NoteItem.fromJson(e as Map<String, dynamic>)),
      ),
      noteColor: json['noteColor'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      lastUpdated: json['lastUpdated'] as int?,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'noteItems': instance.noteItems,
      'title': instance.title,
      'type': instance.type,
      'tags': instance.tags,
      'obscureText': instance.obscureText,
      'lastUpdated': instance.lastUpdated,
      'noteColor': instance.noteColor,
    };

NoteItem _$NoteItemFromJson(Map<String, dynamic> json) => NoteItem(
      id: json['id'] as String?,
      note: json['note'] as String?,
      type: json['type'] as String?,
      obscureText: json['obscureText'] as bool?,
      enableCopy: json['enableCopy'] as bool?,
    );

Map<String, dynamic> _$NoteItemToJson(NoteItem instance) => <String, dynamic>{
      'id': instance.id,
      'note': instance.note,
      'type': instance.type,
      'obscureText': instance.obscureText,
      'enableCopy': instance.enableCopy,
    };

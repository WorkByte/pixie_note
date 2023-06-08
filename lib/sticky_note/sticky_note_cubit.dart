import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../model/note.dart';
import 'sticky_note_state.dart';

class StickyNoteCubit extends Cubit<StickyNoteState> {
  final NotesRepository _notesRepository;

  StickyNoteCubit(this._notesRepository)
      : super(SimpleStickyNoteState(_notesRepository));

  initNotes() async {
    Map<String, dynamic> savedItems = await readPreviousNotes();
    emit(SimpleStickyNoteState(NotesRepository(
        notesList: savedItems['notes'],
        tags: savedItems['tags'],
        stateConfig: EditorStateConfig.VIEW_NOTES,
        currentNote: getCurrentNote())));
  }

  saveNoteItem(
      {bool? exitNow,
      required String noteText,
      required String key,
      bool? toggleObscureText,
      bool? toggleEnableCopy}) async {
    NoteItem? noteItem = (getCurrentNote().noteItems ??= {})[key];

    print('NoteItem:0 ' + jsonEncode(noteItem?.toJson()));
    noteItem ??= NoteItem(id: key);

    noteItem.note = noteText ?? '';
    if (toggleObscureText != null) {
      noteItem.obscureText = !(noteItem.obscureText ??= false);
      print('NoteItem:1 ' + jsonEncode(noteItem?.toJson()));
    }
    if (toggleEnableCopy != null) {
      noteItem.enableCopy = !(noteItem.enableCopy ??= false);
      print('NoteItem:2 ' + jsonEncode(noteItem?.toJson()));
    }

    (getCurrentNote().noteItems ?? {})[key] = noteItem;

    await writeNote(getCurrentNote());
    updateNoteList(exitNow);
  }

  updateNoteList(bool? exitNow) {
    getStateRepo().notesList ??= LinkedHashMap();
    getStateRepo().notesList![getCurrentNote().id!] = getCurrentNote();

    if (exitNow ?? false) {
      getStateRepo().stateConfig = EditorStateConfig.EDIT_NOTE;
    }
    reloadState();
  }

  deleteNoteItem(
      {required String noteText,
      required String key,
      required bool exitNow}) async {
    if ((getCurrentNote().noteItems ?? {}).containsKey(key)) {
      (getCurrentNote().noteItems ?? {}).remove(key);
      await writeNote(getCurrentNote());
    }
    updateNoteList(false);
  }

  saveNoteTitle({required String title, required String key}) async {
    getCurrentNote().title = title ?? '';
    await writeNote(getCurrentNote());

    getStateRepo().notesList ??= LinkedHashMap();
    getStateRepo().notesList![getCurrentNote().id!] = getCurrentNote();

    getStateRepo().stateConfig = EditorStateConfig.EDIT_NOTE;
    reloadState();
  }

  reloadState() {
    emit(SimpleStickyNoteState(getStateRepo()));
  }

  NotesRepository getStateRepo() {
    return (state as SimpleStickyNoteState).notesRepository ??
        NotesRepository();
  }

  editCurrentNote({Note? note}) {
    getStateRepo().stateConfig = EditorStateConfig.EDIT_NOTE;
    getStateRepo().currentNote = note;
    getStateRepo().currentNoteItem =
        getCurrentNote().noteItems!.entries.first.value;
    reloadState();
  }

  clearSearch() {
    getStateRepo().searchTerm = '';
    getStateRepo().searchResults = {};
    reloadState();
  }

  viewCurrentNote({Note? note}) {
    getStateRepo().stateConfig = EditorStateConfig.VIEW_SELECTED_NOTE;
    getStateRepo().currentNote = note;
    getStateRepo().currentNoteItem =
        getCurrentNote().noteItems!.entries.first.value;
    reloadState();
  }

  createNewNote() {
    NoteItem noteItem =
        NoteItem(id: DateTime.now().millisecondsSinceEpoch.toString());
    Map<String, NoteItem> noteItems = {};
    noteItems[noteItem.id!] = noteItem;

    getStateRepo().currentNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        noteItems: noteItems,
        lastUpdated: DateTime.now().millisecondsSinceEpoch);

    getStateRepo().notesList![getStateRepo().currentNote!.id!] =
        getStateRepo().currentNote!;
    getCurrentNote().noteColor = defaultColors()[Random().nextInt(6)];
    editCurrentNote(note: getStateRepo().currentNote!);
  }

  Future<String> get _localPath async {
    Directory directory = await getApplicationSupportDirectory();
    return '${directory.path}/pixie_note';
  }

  Future<File> fileNote(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<File> writeNote(Note note) async {
    /*  Map<String, dynamic> noteMap = note.toJson();
    noteMap.forEach((key, value) {
      noteMap[key] = value as NoteItem;
    });
*/
    final file = await fileNote(note.id!);
    /* print('Writing to ${file.path}');
    print('Writing: ' + jsonEncode(note.toJson()));
    print('\n\n');*/
    return file.writeAsString(jsonEncode(note.toJson()));
  }

  List<int> defaultColors() {
    return [
      0xFFB3FFAE,
      0xFFFFF1DC,
      0xFF7afcff,
      0xFFfeff9c,
      0xFFfff740,
      0xFFff7eb9,
      0xFFF8CBA6,
    ];
  }

  readPreviousNotes() async {
    // Map<String, NotesGroup> previousGroups = {};\
    Map<String, Note> previousNotes = {};
    Set<String> tagsInNotes = {};
    Directory directory = Directory(await _localPath);

    for (var element in (await directory.list().toList())) {
      String noteText = (element as File).readAsStringSync();
      Map<String, dynamic> map = jsonDecode(noteText);
      if (map.containsKey('type')) {
        Note note = Note.fromJson(map);
        previousNotes[element.path.split('/').last] = note;
        note.noteColor = defaultColors()[Random().nextInt(6)];
        tagsInNotes.add('All');
        note.tags = (note.tags ?? []).map((e) => e.toLowerCase()).toList();
        tagsInNotes.addAll(note.tags ?? []);
      } /*else {
        previousGroups[element.path.split('/').last] = NotesGroup.fromJson(map);
      }*/
    }

    Map<String, dynamic> savedItems = {};
    // savedItems['groups'] = previousGroups;
    savedItems['notes'] = previousNotes;

    List<String> tagsList = tagsInNotes.toList();
    tagsList.sort();
    tagsInNotes = tagsList.toSet();

    savedItems['tags'] = tagsInNotes;
    return savedItems;
  }

  deleteNote(String key) async {
    getStateRepo().notesList?.remove(key);
    try {
      File('${(await getApplicationSupportDirectory()).path}/pixie_note/$key')
          .deleteSync();
    } catch (e) {
      // print(e);
    }
    getStateRepo().stateConfig = (getStateRepo().notesList ?? {}).isEmpty
        ? EditorStateConfig.EDIT_NOTE
        : EditorStateConfig.VIEW_NOTES;
    getStateRepo().deleteNow = null;
    reloadState();
  }

  startNoteDeletion(String key) async {
    getStateRepo().deleteNow = getStateRepo().notesList![key];
    reloadState();
  }

  discardEditor() {
    getStateRepo().stateConfig = EditorStateConfig.VIEW_NOTES;
    /*if ((getStateRepo().notesList ?? {}).isEmpty) {
      getStateRepo().editNow = false;
    }*/
    reloadState();
  }

  Note getCurrentNote() {
    if (null == getStateRepo().currentNote) {
      NoteItem noteItem =
          NoteItem(id: DateTime.now().millisecondsSinceEpoch.toString());
      Map<String, NoteItem> noteItems = {};
      noteItems[noteItem.id!] = noteItem;
      getStateRepo().currentNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          noteItems: noteItems,
          lastUpdated: DateTime.now().millisecondsSinceEpoch);
    }
    return getStateRepo().currentNote!;
  }

  void editCurrentNoteItem(String key) {
    getStateRepo().currentNoteItem = getCurrentNote().noteItems![key];
    reloadState();
  }

  void searchText(String value) {
    getStateRepo().searchTerm = value;
    getStateRepo().stateConfig = EditorStateConfig.VIEW_SEARCHED_NOTES;
    Map<String, Note> results = {};
    value = value.toLowerCase();
    getStateRepo().notesList?.forEach((key, note) {
      if ((note.title ?? '').toLowerCase().contains(value) ||
          (note.tags ?? []).any((element) => element.startsWith(value))) {
        results[key] = note;
      } else {
        note.noteItems?.forEach((noteItemKey, noteItem) {
          Note note = Note(id: key, noteItems: LinkedHashMap());
          if (noteItem.note!.toLowerCase().contains(value)) {
            results[key] = note;
            note.noteItems![noteItemKey] = noteItem;
          }
        });
      }
    });
    getStateRepo().searchResults = results;
    reloadState();
  }

  String getSearchTerm() {
    return getStateRepo().searchTerm ?? '';
  }

  cleanNotes() {
    getStateRepo().notesList?.forEach((key, note) {
      note.noteItems?.removeWhere(
          (key, noteItem) => (noteItem.note?.trim().isEmpty ?? false));
    });
    getStateRepo().stateConfig = EditorStateConfig.VIEW_NOTES;
    clearSearch();
    clearTags();
    reloadState();
  }

  void cancelDeletion(String key) {
    getStateRepo().deleteNow = null;
    reloadState();
  }

  Map<String, Note>? getDisplayList() {
    Map<String, Note>? displayList = LinkedHashMap();
    if (getStateRepo().stateConfig == EditorStateConfig.EDIT_NOTE ||
        getStateRepo().stateConfig == EditorStateConfig.VIEW_SELECTED_NOTE) {
      displayList[getCurrentNote().id!] = getCurrentNote();
      return displayList;
    } else {
      return getSearchTerm().trim().isNotEmpty
          ? getStateRepo().searchResults
          : (getStateRepo().tagSelected ?? '').isNotEmpty
              ? getStateRepo().taggedNotes
              : getStateRepo().notesList;
    }
  }

  bool editThisNote(String key) {
    return (getStateRepo().stateConfig == EditorStateConfig.EDIT_NOTE) &&
        (getCurrentNote().id! == key);
  }

  bool isSelectedNote(String key) {
    return (getStateRepo().stateConfig ==
                EditorStateConfig.VIEW_SELECTED_NOTE ||
            getStateRepo().stateConfig == EditorStateConfig.EDIT_NOTE) &&
        getStateRepo().currentNote!.id! == key;
  }

  saveNoteTags(String tags) async {
    getCurrentNote().tags =
        tags.split(',').map((e) => e.trim().toLowerCase()).toList();
    await writeNote(getCurrentNote());
    getStateRepo().tags!.addAll((await readPreviousNotes())['tags']);
    updateNoteList(false);
  }

  void filterNotesByTags(String selected) {
    getStateRepo().searchTerm = '';
    getStateRepo().searchResults = {};
    getStateRepo().stateConfig = EditorStateConfig.VIEW_NOTES;

    if (selected.toLowerCase() == 'all') {
      getStateRepo().tagSelected = '';
      getStateRepo().taggedNotes = {};
      reloadState();
      return;
    }

    Map<String, Note>? notes = {};

    getStateRepo().tagSelected = selected;

    List<MapEntry<String, Note>> noteEntries =
        getStateRepo().notesList!.entries.where((element) {
      return (element.value.tags?.contains(selected) ?? false);
    }).toList();

    noteEntries.forEach((element) => notes[element.key] = element.value);
    getStateRepo().taggedNotes = notes;
    reloadState();
  }

  void toggleTagsWidget() {
    getStateRepo().hideTags = !(getStateRepo().hideTags ?? false);
    reloadState();
  }

  void clearTags() {
    getStateRepo().tagSelected = '';
    getStateRepo().taggedNotes = {};
    reloadState();
  }
}

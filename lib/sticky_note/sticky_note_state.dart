import 'dart:collection';

import '../model/note.dart';

enum EditorStateConfig {
  VIEW_NOTES,
  VIEW_SEARCHED_NOTES,
  VIEW_SELECTED_NOTE,
  EDIT_NOTE
}

class NotesRepository {
  Note? currentNote;
  String? searchTerm;
  bool? hideTags;

  EditorStateConfig? stateConfig;

  /*
  NotesGroup? currentGroup;
  Map<String, NotesGroup>? groupsList;*/
  LinkedHashMap<String, Note>? notesList;
  Map<String, Note>? searchResults;
  Map<String, Note>? taggedNotes;
  Set<String>? tags;

  NoteItem? currentNoteItem;

  Note? deleteNow;

  String? tagSelected;

  NotesRepository(
      {this.currentNote, this.notesList, this.stateConfig, this.tags});
}

abstract class StickyNoteState {
  const StickyNoteState();
}

class SimpleStickyNoteState extends StickyNoteState {
  NotesRepository? notesRepository;

  SimpleStickyNoteState(this.notesRepository);
}

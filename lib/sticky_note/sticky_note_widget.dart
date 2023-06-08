import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';
import 'sticky_note_cubit.dart';
import 'sticky_note_state.dart';

class StickyNoteWidget extends StatefulWidget {
  const StickyNoteWidget({Key? key}) : super(key: key);

  @override
  State<StickyNoteWidget> createState() => _StickyNoteWidgetState();
}

class _StickyNoteWidgetState extends State<StickyNoteWidget> {
  late StickyNoteCubit _stickyNoteCubit;

  @override
  void initState() {
    super.initState();
    _stickyNoteCubit = BlocProvider.of<StickyNoteCubit>(context);
    _stickyNoteCubit.initNotes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StickyNoteCubit, StickyNoteState>(
        listenWhen: (previousState, nextState) {
      return true;
    }, listener: (context, state) {
      if (state is SimpleStickyNoteState &&
          null != (state.notesRepository?.deleteNow)) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  IconButton(
                      onPressed: () {
                        _stickyNoteCubit
                            .deleteNote(state.notesRepository!.deleteNow!.id!);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.done,
                        color: Colors.red,
                      )),
                  IconButton(
                      onPressed: () {
                        _stickyNoteCubit.cancelDeletion(
                            state.notesRepository!.deleteNow!.id!);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close, color: Colors.blue))
                ],
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Are you sure to delete note \"${state.notesRepository?.deleteNow?.title ?? ''}\"'),
                  ],
                ),
              );
            });
      }
    }, builder: (BuildContext context, state) {
      return BlocBuilder<StickyNoteCubit, StickyNoteState>(
          builder: (BuildContext context, state) {
        return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _stickyNoteCubit.createNewNote();
              },
            ),
            body: GestureDetector(
              onTap: () {
                _stickyNoteCubit.cleanNotes();
              },
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: getRequiredWidgetByStateConfig(
                          state as SimpleStickyNoteState, _stickyNoteCubit))),
            ));
      });
    });
  }

  /* Widget noteEditorWidget(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    NotesGroup note = stickyNoteCubit.getCurrentNote();
    int? index = 0;

    TextEditingController titleController =
        TextEditingController(text: note.groupTitle ?? '');

    return Container(
        width: 300,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Padding(padding: EdgeInsets.all(8)),
              TextField(
                  controller: titleController,
                  decoration: InputDecoration.collapsed(hintText: 'Title'),
                  onEditingComplete: () async {}),
              Padding(padding: EdgeInsets.all(8)),
            ])));
  }*/
/*

  Widget noteEditorWidget(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    Note note = stickyNoteCubit.getCurrentNote();

    TextEditingController titleController =
        TextEditingController(text: note.title ?? '');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
              controller: titleController,
              decoration: InputDecoration.collapsed(hintText: 'Note Title'),
              onEditingComplete: () async {
                await stickyNoteCubit.saveNoteTitle(
                    title: titleController.text, key: note.id!);
              }),
          Padding(padding: EdgeInsets.all(16)),
          Expanded(child: noteItemsEditorWidget(state, stickyNoteCubit, note)),
          Padding(padding: EdgeInsets.all(4)),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    stickyNoteCubit.addNoteItem();
                  },
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                OutlinedButton(
                  onPressed: () async {
                    await _stickyNoteCubit.discardEditor();
                  },
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ]),
          noteItemsPreviewWidget(state, stickyNoteCubit, note),
        ],
      ),
    );
  }
*/

  Widget previousNotes(SimpleStickyNoteState state, StickyNoteCubit cubit) {
    List<Widget> notesList = [];

    Map<String, Note>? displayList = cubit.getDisplayList();

    displayList?.forEach((key, note) {
      List<Widget> noteWidgets = [];
      Column noteColumn = Column();
      noteWidgets.add(noteTitleWidget(note, state));
      noteWidgets.add(const Divider(
        indent: 0,
        endIndent: 0,
        thickness: 1,
      ));
      // noteWidgets.add(const Padding(padding: EdgeInsets.all(12)));
      noteWidgets.addAll(noteItemsWidget(note, state, cubit));
    /*  noteWidgets.add(const Divider(
        thickness: 1,
      ));*/
      noteWidgets.add(noteTagsWidget(note, state, cubit));

      noteColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: noteWidgets,
      );

      Widget noteWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: cubit.isSelectedNote(key)
                  ? constraints.maxWidth * 0.80
                  : constraints.maxWidth < 360
                      ? null
                      : 320,
              child: GestureDetector(
                onTap: () {
                  if (!(state.notesRepository!.stateConfig ==
                          EditorStateConfig.EDIT_NOTE &&
                      state.notesRepository!.currentNote!.id! == key)) {
                    _stickyNoteCubit.viewCurrentNote(note: note);
                  }
                },
                onDoubleTap: () {
                  _stickyNoteCubit.editCurrentNote(note: note);
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Color(
                    note.noteColor ?? Random().nextInt(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: noteColumn,
                  ),
                ),
              ),
            );
          },
        ),
      );

      notesList.add(noteWidget);
    });

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: notesList,
    );
  }

  List<Widget> noteItemsWidget(
      Note note, SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    List<Widget> noteItemWidgets = [];

    note.noteItems!.forEach((key, noteItem) {
      noteItemWidgets.add(
          getTextWidgetBasedOnViewType(note, noteItem, state, stickyNoteCubit));
      noteItemWidgets.add(const Padding(padding: EdgeInsets.all(2)));
    });

    return noteItemWidgets;
  }

  Widget noteItemsPreviewWidget(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit, Note note) {
    List<Widget> noteItems = [];

    note.noteItems?.entries.forEach((element) {
      noteItems.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () {
            stickyNoteCubit.editCurrentNoteItem(element.key);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 240,
                height: 80,
                child: Text(element.value.note ?? ''),
              ),
            ),
          ),
        ),
      ));
    });

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              children: noteItems,
            ),
          ),
        ),
      ],
    );
  }

  Widget searchWidget(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    TextEditingController controller = TextEditingController();

    controller.text = stickyNoteCubit.getSearchTerm();
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);

    InputDecoration decoration = InputDecoration(
        hintText: 'Search your notes here',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16),
          child: SizedBox(
            width: constraints.maxWidth * 0.60,
            child: TextField(
              controller: controller,
              decoration: decoration,
              onChanged: (value) {
                _stickyNoteCubit.searchText(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget getRequiredWidgetByStateConfig(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    switch (stickyNoteCubit.getStateRepo().stateConfig) {
      /* return noteEditorWidget(state, stickyNoteCubit);
        return Column(
          children: [
            searchWidget(state as SimpleStickyNoteState, _stickyNoteCubit),
            fullViewWidget(state, _stickyNoteCubit),
          ],
        );*/
      case EditorStateConfig.EDIT_NOTE:
      case EditorStateConfig.VIEW_SELECTED_NOTE:
      case EditorStateConfig.VIEW_NOTES:
      case EditorStateConfig.VIEW_SEARCHED_NOTES:
      default:
        return Column(
          children: [
            pixytitle(),
            searchWidget(state as SimpleStickyNoteState, _stickyNoteCubit),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text((state.notesRepository!.hideTags ?? true)
                    ? 'View Tags'
                    : 'Hide Tags'),
                IconButton(
                    onPressed: () {
                      stickyNoteCubit.toggleTagsWidget();
                    },
                    icon: Icon(
                      (state.notesRepository!.hideTags ?? true)
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up,
                      color: Colors.blue,
                    )),
              ],
            ),
            if (!(state.notesRepository!.hideTags ?? false))
              Container(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                      child: getTagsWidget(
                          (state.notesRepository!.tags ?? {}).toList(),
                          (selected) {
                    _stickyNoteCubit.filterNotesByTags(selected);
                  }, inNoteWidget: false))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: previousNotes(state, _stickyNoteCubit)),
                  ],
                )),
              ),
            ),
          ],
        );
    }
  }

/*
  Widget fullViewWidget(
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    List<Widget> noteWidgets = [];
    Column currentNote = Column();

    List<Color> colors = [
      Color(0xFFB3FFAE),
      Color(0xFFFFF1DC),
      Color(0xFF7afcff),
      Color(0xFFfeff9c),
      Color(0xFFfff740),
      Color(0xFFff7eb9),
      Color(0xFFF8CBA6),
    ];

    Note note = stickyNoteCubit.getCurrentNote();

    String title = note.title ?? '';

    noteWidgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SelectableText(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
        ),
      ],
    ));

    noteWidgets.add(Padding(padding: EdgeInsets.all(4)));
    noteWidgets.addAll(noteItemsWidget(note, state, stickyNoteCubit));
    noteWidgets.add(Divider(
      thickness: 1,
    ));

    noteWidgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () async {
            await _stickyNoteCubit.editCurrentNote(note: note);
          },
          icon: Icon(Icons.edit, size: 18),
        ),
        IconButton(
          onPressed: () async {
            await _stickyNoteCubit.deleteNote(note.id!);
          },
          icon: Icon(Icons.close, size: 20),
        ),
      ],
    ));

    currentNote = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: noteWidgets,
    );
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth * 0.6,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: colors[Random().nextInt(6)],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: currentNote,
                  ),
                )),
          );
        },
      ),
    );
  }*/

  getTextWidgetBasedOnViewType(
    Note note,
    NoteItem noteItem,
    SimpleStickyNoteState state,
    StickyNoteCubit stickyNoteCubit,
  ) {
    bool editNow =
        (state.notesRepository!.stateConfig == EditorStateConfig.EDIT_NOTE &&
            state.notesRepository!.currentNote!.id! == note.id!);
    if (editNow) {
      TextEditingController controller =
          TextEditingController(text: noteItem.note ?? '');

      controller.text = noteItem.note ?? '';
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0X1A000000)),
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Enter your note here'),
                  onChanged: (value) {
                    _stickyNoteCubit.saveNoteItem(
                      noteText: value,
                      key: noteItem.id!,
                      exitNow: false,
                    );
                  },
                ),
              ),
            ),
            noteItemOptions(note, noteItem, state, stickyNoteCubit)
          ],
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Text(
                (noteItem.obscureText ?? false)
                    ? '********'
                    : noteItem.note ?? '',
                maxLines: (_stickyNoteCubit.getStateRepo().stateConfig ==
                            EditorStateConfig.VIEW_SELECTED_NOTE &&
                        _stickyNoteCubit.getStateRepo().currentNote!.id! ==
                            note.id)
                    ? null
                    : 2),
          ),
          (noteItem.enableCopy ?? false)
              ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: noteItem.note,
                    )).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')));
                    });
                  },
                  icon: const Icon(
                    Icons.content_copy,
                    size: 20,
                  ))
              : SizedBox.shrink()
        ],
      );
    }

/*
  Widget titleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('New Note'),
        IconButton(
          icon: Icon(Icons.add),
          color: Colors.blue,
          onPressed: () {
            _stickyNoteCubit.editNow();
          },
        )
      ],
    );
  }
*/
  }

  Widget noteItemOptions(Note note, NoteItem noteItem,
      SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                    onPressed: () async {
                      await stickyNoteCubit.saveNoteItem(
                          noteText: noteItem.note ?? '',
                          key: noteItem.id!,
                          exitNow: false,
                          toggleEnableCopy: true);
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: (noteItem.enableCopy ?? false)
                          ? Colors.blue
                          : Colors.black26,
                    )),
                IconButton(
                    onPressed: () async {
                      await stickyNoteCubit.saveNoteItem(
                          noteText: noteItem.note ?? '',
                          key: noteItem.id!,
                          exitNow: false,
                          toggleObscureText: true);
                    },
                    icon: Icon(
                      Icons.key,
                      size: 20,
                      color: (noteItem.obscureText ?? false)
                          ? Colors.blue
                          : Colors.black26,
                    )),
              ],
            ),
          ),
          IconButton(
              onPressed: () async {
                await stickyNoteCubit.deleteNoteItem(
                    noteText: noteItem.note ?? '',
                    key: noteItem.id!,
                    exitNow: false);
              },
              icon: const Icon(
                Icons.delete,
                size: 18,
                color: Colors.redAccent,
              )),
        ],
      ),
    );
  }

  editableTitle(
      Note note, SimpleStickyNoteState state, StickyNoteCubit stickyNoteCubit) {
    TextEditingController controller =
        TextEditingController(text: note.title ?? '');
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);

    return TextField(
        controller: controller,
        decoration: const InputDecoration.collapsed(hintText: 'Note Title'),
        onChanged: (value) async {
          await stickyNoteCubit.saveNoteTitle(title: value, key: note.id!);
        });
  }

  Widget noteTitleWidget(
    Note note,
    SimpleStickyNoteState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _stickyNoteCubit.editThisNote(note.id!)
              ? editableTitle(note, state, _stickyNoteCubit)
              : Text(
                  note.title ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                ),
        ),
        IconButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(4),
          onPressed: () async {
            await _stickyNoteCubit.startNoteDeletion(note.id!);
          },
          icon: const Icon(
            Icons.delete,
            size: 18,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget noteTagsWidget(
      Note note, SimpleStickyNoteState state, StickyNoteCubit cubit) {
    Widget widget;
    if (cubit.editThisNote(note.id!)) {
      TextEditingController controller =
          TextEditingController(text: (note.tags ?? []).join(", "));

      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);

      widget = TextField(
        controller: controller,
        decoration: const InputDecoration(
            labelText: 'Tags', hintText: 'Enter your tags for this note'),
        onEditingComplete: () {
          cubit.saveNoteTags(controller.text);
        },
      );
    } else {
      widget =
          getTagsWidget(note.tags ?? [], (selected) {}, inNoteWidget: true);
    }

    return widget;
  }

  Widget getTagsWidget(List<String> tags, Function(String)? onClick,
      {bool? inNoteWidget}) {
    List<Widget> children = [];
    tags.forEach((tag) {
      children.add(InkWell(
        onTap: () {
          if (null != onClick) {
            onClick(tag);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '#${tag.toLowerCase().trim()}',
            style: TextStyle(
                color: (inNoteWidget ?? false) ? Colors.black87 : Colors.blue),
          ),
        ),
      ));
    });
    return Wrap(
      children: children,
    );
  }

  Widget pixytitle() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Pixie Note',
        style: TextStyle(
            fontSize: 32,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            color: Colors.black45),
      ),
    );
  }
}

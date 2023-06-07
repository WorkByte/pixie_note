import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sticky_note_cubit.dart';
import 'sticky_note_state.dart';
import 'sticky_note_widget.dart';


class StickyNote extends StatefulWidget {
  const StickyNote({Key? key}) : super(key: key);

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  @override
  Widget build(BuildContext context) {
    return const StickyNoteProvider();
  }
}

class StickyNoteProvider extends StatelessWidget {
  const StickyNoteProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StickyNoteCubit>(
      create: (_) => StickyNoteCubit(NotesRepository()),
      child:   StickyNoteWidget(),
    );
  }
}
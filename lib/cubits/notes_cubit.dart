import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/note_model.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotesCubit() : super(NotesInitial());

  void getNotes() {
    emit(NotesLoading());
    // Removed .orderBy('createdAt') because existing data in your screenshot 
    // doesn't have the 'createdAt' field yet.
    _firestore
        .collection('notic_app')
        .snapshots()
        .listen((snapshot) {
      final notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      emit(NotesLoaded(notes));
    }, onError: (error) {
      emit(NotesError(error.toString()));
    });
  }

  Future<void> addNote(String title, String content) async {
    try {
      await _firestore.collection('notic_app').add({
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> updateNote(String id, String title, String content) async {
    try {
      await _firestore.collection('notic_app').doc(id).update({
        'title': title,
        'content': content,
      });
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _firestore.collection('notic_app').doc(id).delete();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}

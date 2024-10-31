import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddNoteScreen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    setState(() {
      notes = List<Map<String, String>>.from(json.decode(notesString));
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', json.encode(notes));
  }

  void _addOrEditNote(Map<String, String>? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(existingNote: note),
      ),
    );
    if (result != null) {
      setState(() {
        if (note != null) {
          notes[notes.indexOf(note)] = result;
        } else {
          notes.add(result);
        }
      });
      _saveNotes();
    }
  }

  void _deleteNote(Map<String, String> note) {
    setState(() {
      notes.remove(note);
      _saveNotes();
    });
  }

  void _confirmDelete(Map<String, String> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _createNoteWidget(Map<String, String> note) {
    return ListTile(
      leading: Icon(Icons.note),
      title: Text(
        note['title'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        note['content'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _addOrEditNote(note),
      onLongPress: () {
        showMenu(
          context: context,
          position: RelativeRect.fill,
          items: [
            PopupMenuItem(
              child: Text('Edit'),
              onTap: () => _addOrEditNote(note),
            ),
            PopupMenuItem(
              child: Text('Delete'),
              onTap: () => _confirmDelete(note),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Management'),
      ),
      body: notes.isEmpty
          ? Center(child: Text("No notes yet, please add one"))
          : ListView.separated(
              itemCount: notes.length,
              itemBuilder: (context, index) => _createNoteWidget(notes[index]),
              separatorBuilder: (context, index) => Divider(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(null),
        child: Icon(Icons.add),
      ),
    );
  }
}

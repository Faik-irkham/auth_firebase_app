// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://if7k-auth-default-rtdb.asia-southeast1.firebasedatabase.app", // Ganti dengan URL Firebase Anda
  );
  late DatabaseReference _notesRef;
  late StreamSubscription _notesSubscription;
  List<Map<dynamic, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    super.dispose();
    // Membatalkan listener Firebase untuk menghindari memory leak
    _notesSubscription.cancel();
  }

  // Load notes setelah pengguna login
  void _loadNotes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notesRef = _database.ref().child('users').child(user.uid).child('notes');
      _notesSubscription = _notesRef.onValue.listen((event) {
        final data = event.snapshot.value;
        setState(() {
          _notes = [];
          if (data != null) {
            (data as Map).forEach((key, value) {
              _notes.add({
                'id': key,
                'title': value['title'],
                'content': value['content'],
              });
            });
          }
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view your notes')),
      );
    }
  }

  // Fungsi untuk menambahkan catatan baru
  void _addNote() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController contentController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Navigator.pop(
                      context); // Jika pengguna belum login, tutup dialog
                  return;
                }

                final newNoteRef = _notesRef.push();
                newNoteRef.set({
                  'title': titleController.text,
                  'content': contentController.text,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note added successfully')),
                  );
                  Navigator.pop(
                      context); // Tutup dialog setelah menambah catatan
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add note: $error')),
                  );
                });
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog jika dibatalkan
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus catatan
  void _deleteNote(String id) {
    _notesRef.child(id).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully')),
      );
      setState(() {
        _notes.removeWhere((note) => note['id'] == id);
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: $error')),
      );
    });
  }

  // Fungsi untuk memperbarui catatan
  void _editNote(String id, String title, String content) {
    _notesRef.child(id).update({
      'title': title,
      'content': content,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
      setState(() {
        final index = _notes.indexWhere((note) => note['id'] == id);
        if (index != -1) {
          _notes[index] = {
            'id': id,
            'title': title,
            'content': content,
          };
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update note: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _addNote,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 2,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return InkWell(
            onTap: () {
              _showEditDialog(note['id'], note['title'], note['content']);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0XFFFFC600).withOpacity(0.1),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        capitalizeEachWord(note['title']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Image.asset('assets/pin.png', width: 20),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              _deleteNote(note['id']);
                            },
                            icon: const Icon(Icons.delete,
                                color: Colors.red,
                                size: 20,
                                semanticLabel: 'Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note['content'],
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String capitalizeEachWord(String text) {
    return text
        .split(' ') // Memisahkan teks menjadi daftar kata
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '') // Huruf pertama kapital, sisanya kecil
        .join(' '); // Menggabungkan kembali menjadi satu string
  }

  // Dialog untuk memperbarui catatan
  void _showEditDialog(String id, String title, String content) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController contentController =
        TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _editNote(id, titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

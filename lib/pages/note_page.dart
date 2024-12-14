import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddNoteDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          final notes = snapshot.data?.docs ?? [];
          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              String noteId = note.id;
              String title = note['title'];
              String content = note['content'];
              Timestamp? createdAt = note['created_at'];
              createdAt ??= Timestamp.fromDate(DateTime.now());

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.23,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getRandomPastelColor(),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Image.asset(
                          'assets/writing.png',
                          width: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(175, 255, 255, 255),
                                  Color.fromARGB(0, 255, 255, 255),
                                ],
                                // stop 0% dan 100%
                                stops: [0, 1],
                              ),
                            ),
                            child: Text(
                              _formatDate(createdAt),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                _showEditNoteDialog(
                                    context, noteId, title, content);
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.black),
                              onPressed: () {
                                _deleteNote(noteId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Menampilkan dialog untuk menambahkan catatan baru
  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan Obat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNote(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Menambahkan catatan ke Firestore
  void _addNote(String title, String content) async {
    if (title.isNotEmpty && content.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Format tanggal agar terlihat lebih baik
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final dateFormat = DateFormat('d MMM y');
    return dateFormat.format(date);
  }

  // Menampilkan dialog untuk mengedit catatan
  void _showEditNoteDialog(BuildContext context, String noteId,
      String currentTitle, String currentContent) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Catatan Obat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _editNote(noteId, titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Mengedit catatan di Firestore
  void _editNote(String noteId, String title, String content) async {
    if (title.isNotEmpty && content.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notes').doc(noteId).update({
        'title': title,
        'content': content,
      });
    }
  }

  // Menghapus catatan dari Firestore
  void _deleteNote(String noteId) async {
    await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
  }

  // Function to get a random color
  Color _getRandomPastelColor() {
    Random random = Random();
    // Pastel colors are typically light, so we generate values in the higher range (150-255)
    int red = random.nextInt(106) + 150; // Random value between 150 and 255
    int green = random.nextInt(106) + 150; // Random value between 150 and 255
    int blue = random.nextInt(106) + 150; // Random value between 150 and 255

    return Color.fromARGB(255, red, green, blue);
  }
}

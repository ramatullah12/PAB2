import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import '../services/fcm_service.dart';
import '../widgets/note_dialog.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() =>
      _NoteListScreenState();
}

class _NoteListScreenState
    extends State<NoteListScreen> {
  final NoteService _noteService =
      NoteService();

  final FcmService _fcmService =
      FcmService();

  Future<void> _addNote() async {
    final l10n =
        AppLocalizations.of(context)!;

    final note = await showDialog<Note>(
      context: context,
      builder: (context) =>
          const NoteDialog(),
    );

    if (note != null) {
      try {
        await _noteService.addNote(note);

        await _fcmService.sendNoteNotification(
          title: note.title,
          description: note.description,
        );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content:
                  Text(l10n.noteAdded),
              backgroundColor:
                  Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                l10n.noteAddFailed(
                  e.toString(),
                ),
              ),
              backgroundColor:
                  Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editNote(Note note) async {
    final l10n =
        AppLocalizations.of(context)!;

    final updatedNote =
        await showDialog<Note>(
      context: context,
      builder: (context) =>
          NoteDialog(note: note),
    );

    if (updatedNote != null) {
      try {
        await _noteService.updateNote(
          updatedNote,
        );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                l10n.noteUpdated,
              ),
              backgroundColor:
                  Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                l10n.noteUpdateFailed(
                  e.toString(),
                ),
              ),
              backgroundColor:
                  Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteNote(Note note) async {
    final l10n =
        AppLocalizations.of(context)!;

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deleteNote,
        ),
        content: Text(
          l10n.deleteConfirm(
            note.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: Text(
              l10n.cancel,
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor:
                  Colors.white,
            ),
            child: Text(
              l10n.delete,
            ),
          ),
        ],
      ),
    );

    if (confirm == true &&
        note.id != null) {
      try {
        await _noteService.deleteNote(
          note.id!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                l10n.noteDeleted,
              ),
              backgroundColor:
                  Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                l10n.noteDeleteFailed(
                  e.toString(),
                ),
              ),
              backgroundColor:
                  Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.deepPurple,
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.sticky_note_2,
            ),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.language),
            tooltip:
                l10n.language,
            onSelected: (value) async {
              if (value == 'id') {
                await MainApp.setLocale(
                  const Locale('id'),
                );
              } else if (value == 'en') {
                await MainApp.setLocale(
                  const Locale('en'),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'id',
                child: Row(
                  children: [
                    const Text('🇮🇩'),
                    const SizedBox(width: 8),
                    Text(
                      l10n
                          .languageIndonesian,
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇺🇸'),
                    const SizedBox(width: 8),
                    Text(
                      l10n
                          .languageEnglish,
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon:
                const Icon(Icons.copy),
            tooltip:
                l10n.copyFcmToken,
            onPressed: () async {
              final token =
                  await FirebaseMessaging
                      .instance
                      .getToken();

              if (token != null) {
                await Clipboard.setData(
                  ClipboardData(
                    text: token,
                  ),
                );

                if (mounted) {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n
                            .fcmTokenCopied,
                      ),
                    ),
                  );
                }

                debugPrint(
                  'FCM Token: $token',
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<List<Note>>(
          stream:
              _noteService.getNotes(),
          builder:
              (context, snapshot) {
            if (snapshot
                    .connectionState ==
                ConnectionState
                    .waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.errorOccurred,
                ),
              );
            }

            final notes =
                snapshot.data ?? [];

            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons
                          .note_add_outlined,
                      size: 80,
                      color: Colors
                          .deepPurple
                          .shade200,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      l10n.noNotes,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors
                            .grey.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      l10n.addNoteHint,
                      style: TextStyle(
                        color: Colors
                            .grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              itemCount:
                  notes.length,
              itemBuilder:
                  (context, index) {
                final note =
                    notes[index];

                return _buildNoteCard(
                  note,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: _addNote,
        backgroundColor:
            Colors.deepPurple,
        foregroundColor:
            Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (note.imageBase64 !=
                  null &&
              note.imageBase64!
                  .isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius
                      .vertical(
                top: Radius.circular(
                  16,
                ),
              ),
              child: Image.memory(
                base64Decode(
                  note.imageBase64!,
                ),
                height: 220,
                width:
                    double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  note.title,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  note.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors
                        .grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors
                          .grey.shade500,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      _formatDate(
                        note.createdAt,
                      ),
                      style:
                          TextStyle(
                        fontSize: 12,
                        color: Colors
                            .grey
                            .shade500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          _editNote(note),
                      icon: const Icon(
                        Icons.edit,
                      ),
                      color: Colors
                          .deepPurple,
                    ),
                    IconButton(
                      onPressed: () =>
                          _deleteNote(note),
                      icon: const Icon(
                        Icons.delete,
                      ),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../constants/app_theme.dart';

class RecentNotesCard extends StatelessWidget {
  const RecentNotesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final recentNotes = notesProvider.pendingNotes.take(3).toList();
        final overdueNotes = notesProvider.getOverdueNotes();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ghi chú',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (overdueNotes.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${overdueNotes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (recentNotes.isEmpty)
                  _buildEmptyState()
                else
                  ...recentNotes.map((note) => _buildNoteItem(note)),
                
                const SizedBox(height: 8),
                
                TextButton(
                  onPressed: () {
                    // Navigate to notes screen
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    Color priorityColor;
    switch (note.priority) {
      case NotePriority.urgent:
        priorityColor = AppTheme.errorColor;
        break;
      case NotePriority.high:
        priorityColor = AppTheme.warningColor;
        break;
      case NotePriority.normal:
        priorityColor = AppTheme.primaryColor;
        break;
      case NotePriority.low:
        priorityColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.hasReminder)
                      Icon(
                        Icons.notifications_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  note.shortContent,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có ghi chú',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

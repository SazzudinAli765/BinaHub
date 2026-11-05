import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../models/audio_item.dart';

/// Reorderable Playback Queue Sheet
/// SRS: AUD-04 (Queue management, drag-and-drop, swipe removal)
class QueueSheet extends StatefulWidget {
  final List<AudioItem> initialQueue;
  final int currentIndex;
  final ValueChanged<int> onTrackSelected;

  const QueueSheet({
    required this.initialQueue,
    required this.currentIndex,
    required this.onTrackSelected,
  });

  @override
  _QueueSheetState createState() => _QueueSheetState();
}

class _QueueSheetState extends State<QueueSheet> {
  late List<AudioItem> _queue;
  late int _activeIdx;

  @override
  void initState() {
    super.initState();
    _queue = List.from(widget.initialQueue);
    _activeIdx = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CyberColors.borderStructural,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Playback Queue (${_queue.length})', style: CyberTypography.headlineSmall),
              IconButton(
                icon: const Icon(Icons.clear_all, color: CyberColors.textSecondary, size: 20),
                tooltip: 'Clear Queue',
                onPressed: () {
                  setState(() => _queue.clear());
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _queue.isEmpty
                ? Center(
                    child: Text('Queue is empty', style: CyberTypography.bodyMedium),
                  )
                : ReorderableListView.builder(
                    itemCount: _queue.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _queue.removeAt(oldIndex);
                        _queue.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final track = _queue[index];
                      final isCurrent = index == _activeIdx;

                      return Dismissible(
                        key: ValueKey(track.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: CyberColors.thermalRed,
                          child: const Icon(Icons.delete, color: Colors.white, size: 20),
                        ),
                        onDismissed: (_) {
                          setState(() => _queue.removeAt(index));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isCurrent ? CyberColors.surfaceElevated : CyberColors.surfaceCarbon,
                            borderRadius: CyberShapes.roundedMicro,
                            border: Border.all(
                              color: isCurrent ? CyberColors.primaryCyan : CyberColors.borderStructural,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              isCurrent ? Icons.volume_up : Icons.music_note_outlined,
                              color: isCurrent ? CyberColors.primaryCyan : CyberColors.textSecondary,
                              size: 18,
                            ),
                            title: Text(
                              track.title,
                              style: CyberTypography.bodyMedium.copyWith(
                                color: isCurrent ? CyberColors.primaryCyan : CyberColors.textPrimary,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(track.artist, style: CyberTypography.bodySmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CodecBadge(label: track.format, isViolet: isCurrent),
                                const SizedBox(width: 8),
                                const Icon(Icons.drag_handle, color: CyberColors.textTertiary, size: 18),
                              ],
                            ),
                            onTap: () {
                              setState(() => _activeIdx = index);
                              widget.onTrackSelected(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

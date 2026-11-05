import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_chip.dart';

/// Video Search & Multi-Attribute Filter Modal
class SearchFilterModal extends StatefulWidget {
  final Function(String query, String resolution, String sort) onApply;

  const SearchFilterModal({required this.onApply});

  @override
  _SearchFilterModalState createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedResolution = 'All';
  String _selectedSort = 'Date Added (Newest)';

  final List<String> _resolutions = ['All', '4K UHD', '1440p', '1080p', '720p', '480p'];
  final List<String> _sortOptions = [
    'Date Added (Newest)',
    'Date Added (Oldest)',
    'Resolution (Highest)',
    'File Size (Largest)',
    'Duration (Longest)',
    'Title (A-Z)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: CyberColors.primaryCyan, size: 22),
              const SizedBox(width: 8),
              Text('Search & Library Query', style: CyberTypography.headlineSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: TextField(
              controller: _queryController,
              style: CyberTypography.bodyMedium.copyWith(color: CyberColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search filename, directory, or tags...',
                hintStyle: TextStyle(color: CyberColors.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: CyberColors.textSecondary, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resolution Filter
          Text('RESOLUTION TAGS', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _resolutions.map((res) {
                return CyberFilterChip(
                  label: res,
                  isSelected: _selectedResolution == res,
                  onTap: () => setState(() => _selectedResolution = res),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Sorting
          Text('SORT ORDER', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                dropdownColor: CyberColors.surfaceCarbonRaised,
                style: CyberTypography.bodyMedium.copyWith(color: CyberColors.textPrimary),
                items: _sortOptions.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSort = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CyberGhostButton(
                  label: 'RESET',
                  onPressed: () {
                    setState(() {
                      _queryController.clear();
                      _selectedResolution = 'All';
                      _selectedSort = 'Date Added (Newest)';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CyberPrimaryButton(
                  label: 'APPLY FILTER',
                  onPressed: () {
                    widget.onApply(_queryController.text, _selectedResolution, _selectedSort);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

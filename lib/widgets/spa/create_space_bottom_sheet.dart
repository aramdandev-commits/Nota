import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../controllers/spaces_provider.dart';
import '../../model/space_model.dart';

class CreateSpaceBottomSheet extends StatefulWidget {
  const CreateSpaceBottomSheet({super.key});

  @override
  State<CreateSpaceBottomSheet> createState() => _CreateSpaceBottomSheetState();
}

class _CreateSpaceBottomSheetState extends State<CreateSpaceBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151821)
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              AppLocalizations.of(context)!.createNewSpace,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.createNewSpaceDescription,
              style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Space Name Field
            Text(
              AppLocalizations.of(context)!.spaceName,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: AppLocalizations.of(context)!.enterSpaceName,
            ),
            const SizedBox(height: 20),
            
            // Description Field
            Text(
              AppLocalizations.of(context)!.description,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descController,
              hintText: AppLocalizations.of(context)!.enterDescription,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF202430)
                          : Theme.of(context).cardColor,
                      foregroundColor: cs.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isDark
                            ? BorderSide.none
                            : BorderSide(
                                color: cs.onSurface.withValues(alpha: 0.1)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.isEmpty
                          ? AppLocalizations.of(context)!.newSpace
                          : _nameController.text;
                      final desc = _descController.text.isEmpty
                          ? AppLocalizations.of(context)!.noDescription
                          : _descController.text;
                      context.read<SpacesProvider>().createSpace(name, desc);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B58FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.create,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int? maxLines = 1,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202430) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? null
            : Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: cs.onSurface),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0xFF1E1B3A)
                  : cs.primary.withValues(alpha: 0.05))
              : (isDark
                  ? const Color(0xFF202430)
                  : Theme.of(context).cardColor),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : (isDark
                    ? Colors.transparent
                    : cs.onSurface.withValues(alpha: 0.1)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Custom Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? Colors.white : cs.primary)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.3),
                  width: isSelected ? 6 : 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFFD838B5) : Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

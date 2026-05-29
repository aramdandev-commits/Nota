import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nota/helper/app_theme.dart';
import 'package:nota/l10n/app_localizations.dart';

class ShareNoteSheet extends StatefulWidget {
  const ShareNoteSheet({super.key});

  @override
  State<ShareNoteSheet> createState() => _ShareNoteSheetState();
}

class _ShareNoteSheetState extends State<ShareNoteSheet> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  // Use a stable key, never the translated string
  static const _canEditKey = 'can_edit';
  static const _viewerKey = 'viewer';
  String _permissionLevel = _canEditKey;

  String _permissionLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    return key == _canEditKey ? l10n.canEdit : l10n.viewer;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvite() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Invite sent to $email as ${_permissionLabel(context, _permissionLevel)}'),
          backgroundColor: const Color(0xFF3D7AF9),
        ),
      );
    }

    // Clear error if valid
    setState(() {
      _emailError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite sent to $email as $_permissionLevel'),
        backgroundColor: const Color(0xFF3D7AF9),
      ),
    );
    Navigator.pop(context);
  }

  void _copyLink() async {
    await Clipboard.setData(
        const ClipboardData(text: "https://nota.app/share/dummy-link-123"));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          backgroundColor: Color(0xFF3D7AF9),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sheetBg = AppTheme.sheetColor(context);
    final itemBg = AppTheme.itemColor(context);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.shareNote,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(color: itemBg, shape: BoxShape.circle),
                    child: Icon(Icons.close,
                        color: cs.onSurface.withValues(alpha: 0.5), size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.shareThisNote,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(12),
                      border: _emailError != null
                          ? Border.all(color: Colors.redAccent, width: 1.5)
                          : null,
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: TextStyle(color: cs.onSurface),
                      onChanged: (val) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterEmail,
                        hintStyle: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.4),
                            fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _permissionLevel,
                      dropdownColor: itemBg,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: cs.onSurface.withValues(alpha: 0.5), size: 18),
                      style: TextStyle(color: cs.onSurface, fontSize: 14),
                      items: [_canEditKey, _viewerKey].map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(_permissionLabel(context, key)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _permissionLevel = newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_emailError != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _emailError!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9D50FF), Color(0xFF3D7AF9)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sendInvite,
                child: Text(
                  AppLocalizations.of(context)!.sendInvite,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: itemBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _copyLink,
                icon:
                    const Icon(Icons.copy, color: Color(0xFF3D7AF9), size: 18),
                label: Text(
                  AppLocalizations.of(context)!.copyLink,
                  style: TextStyle(
                      color: Color(0xFF3D7AF9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

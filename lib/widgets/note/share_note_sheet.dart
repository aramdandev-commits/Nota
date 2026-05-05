import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareNoteSheet extends StatefulWidget {
  const ShareNoteSheet({super.key});

  @override
  State<ShareNoteSheet> createState() => _ShareNoteSheetState();
}

class _ShareNoteSheetState extends State<ShareNoteSheet> {
  final TextEditingController _emailController = TextEditingController();
  String _permissionLevel = 'Can Edit';

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
          content: Text('Invite sent to $email as $_permissionLevel'),
          backgroundColor: const Color(0xFF3D7AF9),
        ),
      );
    }
    Navigator.pop(context);
  }

  void _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: "https://nota.app/share/dummy-link-123"));
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
    const Color sheetColor = Color(0xFF1E1E2A);
    const Color inputColor = Color(0xFF2A2A38);
    const Color textColor = Colors.white;
    const Color subtitleColor = Colors.grey;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: inputColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.grey, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Share this note with your team',
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Enter email address',
                        hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _permissionLevel,
                      dropdownColor: inputColor,
                      icon: const Icon(Icons.keyboard_arrow_down, color: subtitleColor, size: 18),
                      style: const TextStyle(color: textColor, fontSize: 14),
                      items: <String>['Can Edit', 'Can View'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _permissionLevel = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9D50FF),
                    Color(0xFF3D7AF9),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _sendInvite,
                child: const Text(
                  'Send Invite',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF202434),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _copyLink,
                icon: const Icon(Icons.copy, color: Color(0xFF3D7AF9), size: 18),
                label: const Text(
                  'Copy Link',
                  style: TextStyle(
                    color: Color(0xFF3D7AF9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
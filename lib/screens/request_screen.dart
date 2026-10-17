import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import '../widgets/ios_press.dart';
import '../widgets/lottie_badge.dart';

enum RequestKind { prayer, song }

/// Prayer or song request. "Send on WhatsApp" opens a chat with the ministry's
/// WhatsApp number with the typed request already filled in; the user just
/// taps send.
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key, required this.kind});

  final RequestKind kind;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  /// Prayer: the request. Song: the song title.
  final _main = TextEditingController();

  /// Song only: singer or album.
  final _artist = TextEditingController();

  /// Song only: dedication or message.
  final _note = TextEditingController();

  bool get _song => widget.kind == RequestKind.song;

  @override
  void dispose() {
    for (final c in [_name, _phone, _main, _artist, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  String _message() {
    String? line(String label, TextEditingController c) => c.text.trim().isEmpty ? null : '$label: ${c.text.trim()}';
    final lines = _song
        ? [
            '🎵 Song request',
            '',
            line('Name', _name),
            line('Song', _main),
            line('Singer / album', _artist),
            if (_note.text.trim().isNotEmpty) ...['', _note.text.trim()],
          ]
        : ['🙏 Prayer request', '', line('Name', _name), line('Phone', _phone), '', _main.text.trim()];
    return [...lines.whereType<String>(), '', '— Sent from the ${AppConstants.appName} app'].join('\n');
  }

  Future<void> _send() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final number = context.read<AppState>().content.whatsapp;
    if (number.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not set up yet.')));
      return;
    }
    await Launcher.whatsapp(context, number, text: _message());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(_song ? 'SONG REQUEST' : 'PRAYER REQUEST')),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 32 + MediaQuery.paddingOf(context).bottom),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              decoration: BoxDecoration(color: p.tile(0), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const LottieBadge(AppAnimation.post, size: 84, background: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _song
                          ? '"Sing unto the Lord a new song." — Psalm 96:1'
                          : '"Is any among you afflicted? let him pray." — James 5:13',
                      style: TextStyle(fontFamily: AppTheme.verseFont, color: p.text, fontSize: 17, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 12),
            if (_song) ...[
              TextFormField(
                controller: _main,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Song title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Which song would you like?' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _artist,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Singer or album (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Dedication or message (optional)',
                  alignLabelWithHint: true,
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _main,
                minLines: 5,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Your prayer request', alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please write your request' : null,
              ),
            ],
            const SizedBox(height: 24),
            IosPress(
              child: FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Send on WhatsApp'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'WhatsApp opens with your message ready. Just tap send.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

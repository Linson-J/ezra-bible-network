import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prayer_request.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';

/// Collects a prayer request. With a backend it is submitted through
/// [PrayerRepository]; until then it is sent via WhatsApp or email.
class PrayerRequestScreen extends StatefulWidget {
  const PrayerRequestScreen({super.key});

  @override
  State<PrayerRequestScreen> createState() => _PrayerRequestScreenState();
}

class _PrayerRequestScreenState extends State<PrayerRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _request = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _request.dispose();
    super.dispose();
  }

  PrayerRequest? _validated() {
    if (!(_form.currentState?.validate() ?? false)) return null;
    return PrayerRequest(name: _name.text, phone: _phone.text, request: _request.text);
  }

  Future<void> _submit() async {
    final req = _validated();
    if (req == null) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AppState>().repos.prayer.submit(req);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Thank you. Our team will pray for you.')));
      Navigator.of(context).pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not send. Please try again.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _sendWhatsApp(String number) {
    final req = _validated();
    if (req != null) Launcher.whatsapp(context, number, text: req.toMessage());
  }

  void _sendEmail(String email) {
    final req = _validated();
    if (req != null) {
      Launcher.email(context, email, subject: 'Prayer request', body: req.toMessage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final direct = app.repos.prayer.supportsDirectSubmit;
    final c = app.content;

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer request')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '"Is any among you afflicted? let him pray." — James 5:13',
              style: TextStyle(fontFamily: AppTheme.verseFont, color: AppColors.goldLight, fontSize: 15),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _request,
              minLines: 5,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'How can we pray for you?',
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please write your request' : null,
            ),
            const SizedBox(height: 20),
            if (direct)
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Send prayer request'),
              )
            else ...[
              if (c.whatsapp.isNotEmpty)
                FilledButton.icon(
                  onPressed: () => _sendWhatsApp(c.whatsapp),
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Send via WhatsApp'),
                ),
              if (c.whatsapp.isNotEmpty && c.email.isNotEmpty) const SizedBox(height: 10),
              if (c.email.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => _sendEmail(c.email),
                  icon: const Icon(Icons.email_rounded),
                  label: const Text('Send via email'),
                ),
              const SizedBox(height: 12),
              const Text(
                'Your request opens in WhatsApp or your email app, ready to send.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

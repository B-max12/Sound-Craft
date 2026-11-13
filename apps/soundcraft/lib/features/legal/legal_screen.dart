import 'package:flutter/material.dart';
import 'package:soundcraft/design_system/tokens.dart';

/// Legal documents (SET-005, §26): complete drafts bundled with the app,
/// explicitly marked DRAFT pending owner/legal review (§29.6).
enum LegalDoc { privacy, terms, licenses }

class LegalScreen extends StatelessWidget {
  const LegalScreen.document(this.doc, {super.key});

  final LegalDoc doc;

  static const _privacy = '''
SOUNDCRAFT PRIVACY POLICY — DRAFT (owner review pending)

SoundCraft is local-first by Aur Labs. This draft summarizes data handling; it is NOT yet counsel-approved.

1. What SoundCraft stores on your device
   • Your imported music references (paths/URIs), metadata (titles, artists, durations, embedded artwork thumbnails), playlists, favorites, listening history, recent searches, queue position, and settings. All of it stays in the app database on your device.
   • Listening history is device-local by default. You can pause it (Settings → Privacy), clear it, or delete individual entries.
   • Downloads you create are stored in the app's storage area on your device.

2. What leaves your device
   • Nothing from your library is uploaded. There is no SoundCraft account in V1 and no mandatory sign-in.
   • When you use online discovery (Audius), your search queries and feed requests are sent to Audius API hosts to return results. Audius' own privacy terms apply to their handling.
   • YouTube discovery (when configured) sends your query to Aur Labs' discovery gateway, which forwards it to the YouTube Data API. The gateway stores privacy-safe request logs without query content where feasible.
   • No advertising SDKs, no third-party trackers.

3. Controls you have
   • Clear listening history / recent searches / provider metadata cache — each scoped precisely in Settings.
   • Disable personalization, history, or search history entirely.
   • Export: playlists export to a documented JSON format from the playlist screen.

4. Deletion
   • Removing the app deletes its database and app-owned downloads. Audio files you imported from elsewhere on your device are NOT deleted by uninstalling SoundCraft.

Contact: support@aurlabs.example (owner to finalize — Owner Action Queue #10).
''';

  static const _terms = '''
SOUNDCRAFT TERMS OF USE — DRAFT (owner review pending)

1. What SoundCraft is: an offline-first music player with optional, clearly-labeled online discovery from Audius and (when configured) YouTube.

2. Your content: You may import audio files you legitimately have the right to access on your device. SoundCraft never uploads them.

3. Online content: Discovery and playback of online content follow each provider's terms. Audius content is streamed from Audius with attribution. YouTube content is presented through YouTube's official player only; SoundCraft does not extract, cache, or download YouTube media.

4. Downloads: Only content whose source explicitly marks it as downloadable can be saved for offline use. Unknown rights mean no download — the app denies such requests by design.

5. No circumvention: You must not use SoundCraft to bypass technical protections, regional restrictions, or provider policies. The app is built to prevent this.

6. Acceptable use: No attempts to abuse provider APIs, extract data beyond permitted surfaces, or circumvent rate limits.

7. Warranty & liability: The software is provided "as is" without warranty of any kind. To the maximum extent permitted by law, Aur Labs is not liable for damages arising from use of the software.

8. Changes: Terms may change with notice in-app. Continued use constitutes acceptance.

Full legal review is an owner action (Owner Action Queue #10) before public launch.
''';

  static const _licenses = '''
SOUNDCRAFT OPEN-SOURCE LICENSES & ATTRIBUTIONS

Application: SoundCraft 0.1.0 — An Aur Labs Product.
Open-source license: TO BE CHOSEN BY OWNER (Owner Action Queue #10). Candidate licenses: MIT, Apache-2.0, GPL-3.0.

Key dependencies (versions in pubspec.lock):
  • Flutter — BSD-style license — flutter.dev
  • flutter_riverpod — MIT
  • go_router — BSD-3-Clause
  • drift / sqlite3 — MIT (SQLite is public domain)
  • just_audio / audio_service / audio_session — MIT
  • dio — MIT
  • file_picker — MIT
  • audio_metadata_reader — MIT
  • cached_network_image — MIT
  • connectivity_plus, path_provider, shared_preferences, uuid, crypto, collection — per their pub.dev licenses

Music provider attribution:
  • Audius — discovery and streaming via the official Audius public API (https://audius.co). "Trending on Audius" and similar labels reflect Audius catalog data only.
  • YouTube — discovery via the YouTube Data API through Aur Labs' secure gateway; playback only through YouTube's official player surfaces per YouTube API Services Terms.

Brand assets:
  • The cricket-with-guitar mascot concept is an original draft artwork generated for SoundCraft pending the owner's approved concept file (Owner Action Queue #1). It is not derived from any third-party mascot.

Full license texts are shown by Flutter's standard LicensePage registry in release builds.
''';

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (doc) {
      LegalDoc.privacy => ('Privacy policy', _privacy),
      LegalDoc.terms => ('Terms of use', _terms),
      LegalDoc.licenses => ('Licenses & attributions', _licenses),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<SoundCraftColors>()!
                    .warning
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DRAFT DOCUMENT — pending owner/legal review before public launch.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Text(body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

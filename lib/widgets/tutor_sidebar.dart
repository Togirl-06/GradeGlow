import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_session.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../screens/membership_screen.dart';

/// ChatGPT-style sidebar: New chat · Search · Recents · profile (no Projects/Apps/Codex).
class TutorSidebar extends StatefulWidget {
  const TutorSidebar({
    super.key,
    required this.onCloseDrawer,
  });

  final VoidCallback? onCloseDrawer;

  @override
  State<TutorSidebar> createState() => _TutorSidebarState();
}

class _TutorSidebarState extends State<TutorSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _newChat(ChatService chat) async {
    await chat.startNewChat();
    widget.onCloseDrawer?.call();
  }

  Future<void> _openSession(ChatService chat, String sessionId) async {
    await chat.selectSession(sessionId);
    widget.onCloseDrawer?.call();
  }

  List<ChatSession> _filter(List<ChatSession> sessions) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return sessions;
    return sessions.where((ChatSession s) => s.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ChatService chat = context.watch<ChatService>();
    final AuthService auth = context.watch<AuthService>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color bg = brightness == Brightness.dark ? const Color(0xFF171717) : const Color(0xFFF7F7F8);
    final Color hover = brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFECECF1);
    final Color text = StudyColors.textPrimary(brightness);
    final Color muted = StudyColors.textSecondary(brightness);

    return ColoredBox(
      color: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: _SidebarTile(
                icon: Icons.edit_outlined,
                label: 'New chat',
                hoverColor: hover,
                textColor: text,
                onTap: () => _newChat(chat),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (String value) => setState(() => _query = value),
                style: TextStyle(color: text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search chats',
                  hintStyle: TextStyle(color: muted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, size: 20, color: muted),
                  filled: true,
                  fillColor: hover.withValues(alpha: 0.65),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text('Recents', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: StreamBuilder<List<ChatSession>>(
                stream: chat.watchSessions(),
                builder: (BuildContext context, AsyncSnapshot<List<ChatSession>> snapshot) {
                  final List<ChatSession> sessions = _filter(snapshot.data ?? <ChatSession>[]);
                  if (sessions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _query.isEmpty ? 'No chats yet' : 'No matches',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: sessions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ChatSession session = sessions[index];
                      final bool active = session.id == chat.activeSessionId;
                      return _SessionTile(
                        title: session.title,
                        active: active,
                        hoverColor: hover,
                        textColor: text,
                        mutedColor: muted,
                        onTap: () => _openSession(chat, session.id),
                        onDelete: () => chat.deleteSession(session.id),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            StreamBuilder<UserProfile>(
              stream: context.read<UserService>().watchProfile(),
              builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
                final UserProfile profile = snapshot.data ??
                    UserProfile.empty(email: auth.email, displayName: auth.displayName);
                final String planLabel = switch (profile.plan) {
                  'premium_plus' => 'Premium',
                  'premium' => 'Premium',
                  _ => 'Free',
                };
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: StudyColors.primaryTint(brightness),
                        child: Text(
                          profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : '?',
                          style: TextStyle(color: StudyColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(planLabel, style: TextStyle(color: muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (profile.plan == 'free')
                        TextButton(
                          onPressed: () {
                            widget.onCloseDrawer?.call();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Upgrade'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.hoverColor,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color hoverColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.title,
    required this.active,
    required this.hoverColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
    required this.onDelete,
  });

  final String title;
  final bool active;
  final Color hoverColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? hoverColor : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, size: 18, color: mutedColor),
                padding: EdgeInsets.zero,
                onSelected: (String value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'delete', child: Text('Delete chat')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

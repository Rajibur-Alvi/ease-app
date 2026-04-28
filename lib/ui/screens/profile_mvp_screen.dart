import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/analytics_models.dart';
import '../../models/models.dart';
import '../../services/analytics_service.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class ProfileMvpScreen extends StatelessWidget {
  const ProfileMvpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;
    final profile = appState.userProfile;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 18),
            onPressed: () => _openEditSheet(context, profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(EaseSpace.lg),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _openEditSheet(context, profile),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            EaseTheme.primaryContainer.withValues(alpha: 0.2),
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : 'E',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: EaseTheme.primarySage,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: EaseTheme.primarySage,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.pencil,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: EaseSpace.sm),
                Text(profile.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  _personalityLabel(profile.personalityType),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: EaseTheme.secondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: EaseSpace.lg),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.brainCircuit,
                  label: 'Brain Dumps',
                  value: '${appState.brainDumpEntries.length}',
                ),
              ),
              const SizedBox(width: EaseSpace.sm),
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.zap,
                  label: 'This week',
                  value: '${appState.stressorsOffloadedThisWeek}',
                ),
              ),
              const SizedBox(width: EaseSpace.sm),
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.checkCircle,
                  label: 'Tasks done',
                  value:
                      '${appState.tasks.where((t) => t.completed).length}',
                ),
              ),
            ],
          ),

          const SizedBox(height: EaseSpace.md),

          // Analytics card
          _AnalyticsCard(),

          const SizedBox(height: EaseSpace.md),

          // Profile details
          _SectionCard(children: [
            _ProfileRow(
              icon: LucideIcons.messageCircle,
              label: 'Communication',
              value: _styleLabel(profile.communicationStyle),
            ),
            const Divider(height: 1, color: EaseTheme.surfaceDim),
            _ProfileRow(
              icon: LucideIcons.activity,
              label: 'Introvert level',
              value: '${profile.introvertLevel} / 100',
            ),
            if (profile.interests.isNotEmpty) ...[
              const Divider(height: 1, color: EaseTheme.surfaceDim),
              _ProfileRow(
                icon: LucideIcons.heart,
                label: 'Interests',
                value: profile.interests.join(', '),
              ),
            ],
          ]),

          const SizedBox(height: EaseSpace.md),

          _SectionCard(children: [
            ListTile(
              leading: const Icon(LucideIcons.trendingUp,
                  color: EaseTheme.primarySage),
              title: const Text('Investment Guidance'),
              subtitle: const Text('Save, invest, grow wealth'),
              trailing:
                  const Icon(LucideIcons.chevronRight, size: 18),
              onTap: () => context.push('/investments'),
            ),
          ]),

          const SizedBox(height: EaseSpace.lg),

          OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(LucideIcons.rotateCcw, size: 16),
            label: const Text('Reset app data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EaseTheme.tertiaryTerracotta,
              side: const BorderSide(color: EaseTheme.tertiaryTerracotta),
            ),
          ),

          const SizedBox(height: EaseSpace.xxl),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: EaseTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _EditProfileSheet(profile: profile),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text(
            'This will clear all your entries and return to onboarding.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AppStateProvider>().resetState();
              if (context.mounted) context.go('/onboarding');
            },
            style: FilledButton.styleFrom(
                backgroundColor: EaseTheme.tertiaryTerracotta),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _personalityLabel(PersonalityType type) => switch (type) {
        PersonalityType.introvert => 'Introvert',
        PersonalityType.extrovert => 'Extrovert',
        PersonalityType.ambivert => 'Ambivert',
      };

  String _styleLabel(CommunicationStyle style) => switch (style) {
        CommunicationStyle.text => 'Text',
        CommunicationStyle.voice => 'Voice',
        CommunicationStyle.either => 'Either',
      };
}

// ── Edit Profile Sheet ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late PersonalityType _personality;
  late CommunicationStyle _style;
  late double _introvertLevel;
  late List<String> _interests;

  static const _interestOptions = [
    'books', 'music', 'mindfulness', 'fitness', 'art',
    'journaling', 'productivity', 'finance', 'home',
    'nature', 'cooking', 'travel',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _personality = widget.profile.personalityType;
    _style = widget.profile.communicationStyle;
    _introvertLevel = widget.profile.introvertLevel.toDouble();
    _interests = List.from(widget.profile.interests);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: EaseSpace.lg,
        right: EaseSpace.lg,
        top: EaseSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + EaseSpace.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Profile',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: EaseSpace.md),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: EaseSpace.md),
            Text('Personality',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: EaseSpace.xs),
            Wrap(
              spacing: EaseSpace.xs,
              children: PersonalityType.values.map((t) {
                return ChoiceChip(
                  label: Text(_pLabel(t)),
                  selected: _personality == t,
                  onSelected: (_) => setState(() => _personality = t),
                );
              }).toList(),
            ),
            const SizedBox(height: EaseSpace.md),
            Text('Communication style',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: EaseSpace.xs),
            Wrap(
              spacing: EaseSpace.xs,
              children: CommunicationStyle.values.map((s) {
                return ChoiceChip(
                  label: Text(_sLabel(s)),
                  selected: _style == s,
                  onSelected: (_) => setState(() => _style = s),
                );
              }).toList(),
            ),
            const SizedBox(height: EaseSpace.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Introvert level',
                    style: Theme.of(context).textTheme.labelSmall),
                Text('${_introvertLevel.round()}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: EaseTheme.primarySage)),
              ],
            ),
            Slider(
              value: _introvertLevel,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (v) => setState(() => _introvertLevel = v),
            ),
            const SizedBox(height: EaseSpace.sm),
            Text('Interests',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: EaseSpace.xs),
            Wrap(
              spacing: EaseSpace.xs,
              runSpacing: EaseSpace.xs,
              children: _interestOptions.map((i) {
                final sel = _interests.contains(i);
                return FilterChip(
                  label: Text(i),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    sel ? _interests.remove(i) : _interests.add(i);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: EaseSpace.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final updated = widget.profile.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? widget.profile.name : _nameCtrl.text.trim(),
      personalityType: _personality,
      communicationStyle: _style,
      introvertLevel: _introvertLevel.round(),
      interests: _interests,
    );
    await context.read<AppStateProvider>().updateUserProfile(updated);
    if (mounted) Navigator.of(context).pop();
  }

  String _pLabel(PersonalityType t) => switch (t) {
        PersonalityType.introvert => 'Introvert',
        PersonalityType.extrovert => 'Extrovert',
        PersonalityType.ambivert => 'Ambivert',
      };

  String _sLabel(CommunicationStyle s) => switch (s) {
        CommunicationStyle.text => 'Text',
        CommunicationStyle.voice => 'Voice',
        CommunicationStyle.either => 'Either',
      };
}

// ── Analytics Card ────────────────────────────────────────────────────────────

class _AnalyticsCard extends StatefulWidget {
  @override
  State<_AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<_AnalyticsCard> {
  AnalyticsSummary? _summary;

  @override
  void initState() {
    super.initState();
    AnalyticsService().getSummary().then((s) {
      if (mounted) setState(() => _summary = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_summary == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: EaseTheme.primarySage.withValues(alpha: 0.06),
        borderRadius: EaseRadius.md,
        border: Border.all(
            color: EaseTheme.primarySage.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR INSIGHTS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    color: EaseTheme.primarySage,
                  )),
          const SizedBox(height: EaseSpace.sm),
          Row(
            children: [
              _InsightItem(
                  icon: LucideIcons.flame,
                  label: 'Streak',
                  value: '${_summary!.streakDays}d'),
              _InsightItem(
                  icon: LucideIcons.brainCircuit,
                  label: 'This week',
                  value: '${_summary!.brainDumpsThisWeek}'),
              _InsightItem(
                  icon: LucideIcons.messageCircle,
                  label: 'Chats',
                  value: '${_summary!.chatOpens}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: EaseTheme.primarySage, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 18)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: EaseTheme.secondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        children: [
          Icon(icon, color: EaseTheme.primarySage, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 20)),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EaseTheme.secondary,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EaseSpace.md, vertical: EaseSpace.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: EaseTheme.primarySage),
          const SizedBox(width: EaseSpace.sm),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: EaseTheme.secondary)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

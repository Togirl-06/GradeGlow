import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_theme.dart';
import '../shared/professional_widgets.dart';

/// Client brief → persona → campaign → launch → rescue.
class MarketingCampaignMission extends StatefulWidget {
  const MarketingCampaignMission({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final ProCaseStore store;
  final VoidCallback onComplete;

  @override
  State<MarketingCampaignMission> createState() =>
      _MarketingCampaignMissionState();
}

class _MarketingCampaignMissionState extends State<MarketingCampaignMission> {
  static const ProSimTheme t = ProSimTheme.marketing;

  int _q = 0;
  final Set<String> _learned = <String>{};
  String? _audience;
  String? _platform;
  String? _message;
  double _budget = 40;
  bool _launched = false;
  bool _rescued = false;
  Map<String, String>? _metrics;
  String? _feedback;

  static const List<_Qa> _interview = <_Qa>[
    _Qa('Who is your ideal customer?',
        'Campus students 18–24 who buy lifestyle gear online.'),
    _Qa('What is the real problem?',
        'Awareness is fine — consideration is where they drop. Reviews scare them.'),
    _Qa('Budget ceiling?', '\$50k this quarter. Prefer Instagram + TikTok.'),
    _Qa('What have you tried?', 'Broad Meta ads. High CPC, weak conversions.'),
  ];

  void _ask() {
    if (_q >= _interview.length) return;
    setState(() {
      _learned.add(_interview[_q].answer);
      _q++;
    });
  }

  Future<void> _launch() async {
    if (_learned.length < 3) {
      setState(() => _feedback = 'Interview the client — don’t guess the brief.');
      return;
    }
    if (_audience == null || _platform == null || _message == null) {
      setState(() => _feedback = 'Complete audience, platform, and message.');
      return;
    }
    final bool goodAudience = _audience == 'Students 18–24';
    final bool goodPlatform =
        _platform == 'Instagram + TikTok' || _platform == 'TikTok';
    final bool goodMsg = _message == 'Social proof / reviews first';

    int ctr = 1;
    int conv = 1;
    int roi = 1;
    if (goodAudience) {
      ctr += 2;
      conv += 1;
    }
    if (goodPlatform) {
      ctr += 2;
      conv += 2;
    }
    if (goodMsg) {
      conv += 3;
      roi += 2;
    }
    if (_budget > 55) roi -= 1;

    await widget.store.applyMeters(<String, double>{
      'Impressions': 10.0 + _budget / 5,
      'CTR': ctr * 8.0,
      'Conversions': conv * 7.0,
      'ROI': roi * 12.0,
    });
    await widget.store.addDecision(
      'Launch audience=$_audience platform=$_platform msg=$_message budget=$_budget',
    );

    setState(() {
      _launched = true;
      _metrics = <String, String>{
        'Impressions': '${(120000 + _budget * 2000).round()}',
        'CTR': '${(0.8 + ctr * 0.35).toStringAsFixed(2)}%',
        'Conversions': '${40 + conv * 18}',
        'CAC': '\$${(55 - conv * 3).clamp(18, 60)}',
        'ROI': '${(0.6 + roi * 0.35).toStringAsFixed(2)}x',
      };
      _feedback = (goodAudience && goodPlatform && goodMsg)
          ? 'Client Sol: “Directionally right. Optimize the weak stage.”'
          : 'Data Analyst: “Campaign underperforming. Check audience/message fit.”';
    });
  }

  Future<void> _rescue() async {
    if (!_launched) return;
    setState(() {
      _rescued = true;
      _message = 'Social proof / reviews first';
      _audience = 'Students 18–24';
      _platform = 'Instagram + TikTok';
      _metrics = <String, String>{
        'Impressions': '210,000',
        'CTR': '2.4%',
        'Conversions': '186',
        'CAC': '\$22',
        'ROI': '2.1x',
      };
      _feedback =
          'Creative Director: “Consideration stage rescued. Defend this in the client pitch.”';
    });
    await widget.store.addNote('Optimized to social-proof creative for 18–24 on IG/TikTok');
    await widget.store.awardXp(160, coinsGain: 4, skill: 'Strategy');
    await widget.store.awardXp(40, skill: 'Analytics');
    await widget.store.completeMission('campaign');
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1320),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Text(
            'Account Manager: “Client Sol Rivera is here. Interview first — then build.”',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text('CLIENT INTERVIEW',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          if (_q < _interview.length)
            FilledButton(
              onPressed: _ask,
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                foregroundColor: Colors.black,
              ),
              child: Text('ASK: ${_interview[_q].q}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            )
          else
            const Text('Interview complete.',
                style: TextStyle(color: Colors.white54)),
          ..._learned.map(
            (String a) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('• $a', style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 14),
          Text('PERSONA + CAMPAIGN BUILDER',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          _choice('Audience', <String>[
            'Students 18–24',
            'Parents 35–50',
            'Everyone 18–65',
          ], _audience, (String v) => setState(() => _audience = v)),
          _choice('Platform', <String>[
            'Instagram + TikTok',
            'TikTok',
            'Search only',
            'Billboards',
          ], _platform, (String v) => setState(() => _platform = v)),
          _choice('Message', <String>[
            'Social proof / reviews first',
            'Lowest price scream',
            'Feature dump',
          ], _message, (String v) => setState(() => _message = v)),
          Text('Budget \$${_budget.round()}k',
              style: const TextStyle(color: Colors.white70)),
          Slider(
            value: _budget,
            min: 10,
            max: 80,
            activeColor: t.accent,
            onChanged: (double v) => setState(() => _budget = v),
          ),
          FilledButton(
            onPressed: _launched ? null : _launch,
            child: const Text('LAUNCH CAMPAIGN'),
          ),
          if (_metrics != null) ...<Widget>[
            const SizedBox(height: 12),
            ProConsequencePanel(
              theme: t,
              title: 'ANALYTICS',
              deltas: _metrics!,
              interpretation: _feedback ?? '',
            ),
            if (!_rescued)
              TextButton(
                onPressed: _rescue,
                child: const Text('OPTIMIZE / RESCUE CAMPAIGN'),
              ),
          ],
          if (_feedback != null && _metrics == null)
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
        ],
      ),
    );
  }

  Widget _choice(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String> onC,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w800)),
        ProSelectList(
          accent: t.accent,
          value: value,
          onChanged: onC,
          options: options,
        ),
      ],
    );
  }
}

class _Qa {
  const _Qa(this.q, this.answer);
  final String q;
  final String answer;
}

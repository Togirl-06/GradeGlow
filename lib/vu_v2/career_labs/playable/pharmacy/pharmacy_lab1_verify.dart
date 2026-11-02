import 'package:flutter/material.dart';

/// Prescription verification — catch penicillin allergy conflict.
class PharmacyLab1VerifyScreen extends StatefulWidget {
  const PharmacyLab1VerifyScreen({super.key});

  @override
  State<PharmacyLab1VerifyScreen> createState() =>
      _PharmacyLab1VerifyScreenState();
}

class _PharmacyLab1VerifyScreenState extends State<PharmacyLab1VerifyScreen> {
  static const Color _accent = Color(0xFF5EEAD4);
  static const Color _bg = Color(0xFF041411);
  static const Color _surface = Color(0xFF0C221E);

  final Set<String> _checks = <String>{};
  bool _caughtAllergy = false;
  bool _paused = false;
  String? _warning;

  static const List<_CheckItem> _items = <_CheckItem>[
    _CheckItem(
      id: 'patient',
      title: 'Patient identity',
      detail: 'Jordan Hale · DOB 03/14/1990 · MRN 44821 matches Rx.',
    ),
    _CheckItem(
      id: 'drug',
      title: 'Drug',
      detail: 'Amoxicillin 500 mg capsules — for acute sinusitis.',
    ),
    _CheckItem(
      id: 'dose',
      title: 'Dose & directions',
      detail: '500 mg PO TID × 7 days — within adult range.',
    ),
    _CheckItem(
      id: 'allergy',
      title: 'Allergy profile',
      detail:
          'ALLERGY: Penicillin — anaphylaxis (2019). Banner is active on profile.',
      isTrap: true,
    ),
    _CheckItem(
      id: 'interaction',
      title: 'Interactions',
      detail: 'On oral contraceptive — counsel backup method if antibiotic prescribed.',
    ),
  ];

  void _toggle(String id) {
    if (_paused && id != 'allergy') return;
    setState(() {
      if (_checks.contains(id)) {
        _checks.remove(id);
      } else {
        _checks.add(id);
      }
    });
  }

  Future<void> _attemptApprove() async {
    if (_checks.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review each profile line before acting.')),
      );
      return;
    }
    if (!_caughtAllergy) {
      setState(() {
        _paused = true;
        _warning =
            'STOP. Ada Okonkwo holds the bag. “Penicillin anaphylaxis on file — '
            'and you almost dispensed amoxicillin. That is not a red ❌ quiz mark. '
            'That is a patient safety event. Flag the allergy conflict.”';
      });
      return;
    }
    await _complete();
  }

  Future<void> _flagAllergy() async {
    setState(() {
      _caughtAllergy = true;
      _paused = false;
      _warning =
          'Allergy conflict flagged. Suggested: contact prescriber for non-penicillin alternative '
          '(e.g., doxycycline / cephalosporin per protocol).';
      _checks.add('allergy');
    });
  }

  Future<void> _complete() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Ada Okonkwo',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Good catch. You verified identity, dose, and the allergy wall. '
            'Prescriber will switch agents. Now counsel the patient at the booth.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'VERIFICATION',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Rx review — amoxicillin',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_warning != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _paused
                      ? const Color(0xFF78350F).withValues(alpha: 0.55)
                      : _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _paused
                        ? const Color(0xFFFBBF24)
                        : _accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _warning!,
                  style: const TextStyle(color: Colors.white, height: 1.45),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int i) {
                  final _CheckItem item = _items[i];
                  final bool on = _checks.contains(item.id);
                  return InkWell(
                    onTap: () => _toggle(item.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isTrap && on
                              ? const Color(0xFFFBBF24)
                              : (on ? _accent : Colors.white12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            on
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: on ? _accent : Colors.white38,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.detail,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    height: 1.35,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: <Widget>[
                  if (_paused || !_caughtAllergy)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _flagAllergy,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFBBF24),
                          side: const BorderSide(color: Color(0xFFFBBF24)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _caughtAllergy
                              ? 'Allergy flagged ✓'
                              : 'Flag allergy conflict',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  if (_paused || !_caughtAllergy) const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _caughtAllergy
                          ? _complete
                          : (_paused ? null : _attemptApprove),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _caughtAllergy
                            ? 'Send alternative request'
                            : 'Approve & dispense',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem {
  const _CheckItem({
    required this.id,
    required this.title,
    required this.detail,
    this.isTrap = false,
  });

  final String id;
  final String title;
  final String detail;
  final bool isTrap;
}

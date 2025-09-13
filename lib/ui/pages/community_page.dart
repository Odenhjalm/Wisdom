import 'package:flutter/material.dart';
import 'package:andlig_app/ui/widgets/app_scaffold.dart';
import 'package:andlig_app/data/community_service.dart';
import 'package:go_router/go_router.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _svc = CommunityService();
  bool _loading = true;
  List<Map<String, dynamic>> _teachers = [];
  final _q = TextEditingController();
  String _query = '';
  final Set<String> _selectedSpecs = {};
  String _sort = 'rating'; // rating | name | newest
  Map<String, int> _certCount = const {};

  List<String> get _allSpecs {
    final s = <String>{};
    for (final t in _teachers) {
      final list = (t['specialties'] as List?)?.cast<String>() ?? const [];
      s.addAll(list);
    }
    final out = s.toList()..sort();
    return out;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _svc.listTeachers();
    // fetch verified certificate counts + specialties fallback
    try {
      final ids = rows.map((e) => e['user_id'] as String?).whereType<String>().toList();
      _certCount = await _svc.listVerifiedCertCount(ids);
      final specMap = await _svc.listVerifiedCertSpecialties(ids);
      // merge specialties from certs if directory specials are empty
      for (final t in rows) {
        final id = t['user_id'] as String?;
        final dirSpecs = (t['specialties'] as List?)?.cast<String>() ?? const [];
        if ((dirSpecs.isEmpty) && id != null && specMap.containsKey(id)) {
          t['specialties'] = specMap[id];
        }
      }
    } catch (_) {
      _certCount = const {};
    }
    if (!mounted) return;
    setState(() {
      _teachers = rows;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _filtered() {
    Iterable<Map<String, dynamic>> list = _teachers;
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) {
        final prof = (t['profile'] as Map?)?.cast<String, dynamic>();
        final name = (prof?['display_name'] as String?)?.toLowerCase() ?? '';
        final head = (t['headline'] as String?)?.toLowerCase() ?? '';
        final specs = ((t['specialties'] as List?)?.cast<String>() ?? const [])
            .join(' ') 
            .toLowerCase();
        return name.contains(q) || head.contains(q) || specs.contains(q);
      });
    }
    if (_selectedSpecs.isNotEmpty) {
      list = list.where((t) {
        final specs = ((t['specialties'] as List?)?.cast<String>() ?? const []);
        return _selectedSpecs.every((s) => specs.contains(s));
      });
    }
    final out = list.toList();
    switch (_sort) {
      case 'name':
        out.sort((a, b) {
          final an = (((a['profile'] as Map?)?.cast<String, dynamic>())?['display_name'] as String? ?? '').toLowerCase();
          final bn = (((b['profile'] as Map?)?.cast<String, dynamic>())?['display_name'] as String? ?? '').toLowerCase();
          return an.compareTo(bn);
        });
        break;
      case 'newest':
        out.sort((a, b) {
          final ad = DateTime.tryParse((a['created_at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = DateTime.tryParse((b['created_at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
        break;
      case 'rating':
      default:
        out.sort((a, b) {
          double ra = _ratingOf(a);
          double rb = _ratingOf(b);
          return rb.compareTo(ra);
        });
    }
    return out;
  }

  double _ratingOf(Map<String, dynamic> t) {
    final r = t['rating'];
    if (r is num) return r.toDouble();
    if (r is String) return double.tryParse(r) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = _filtered();
    return AppScaffold(
      title: 'Community',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _q,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Sök lärare, specialitet eller rubrik...'
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Sortera:'),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _sort,
                              items: const [
                                DropdownMenuItem(value: 'rating', child: Text('Betyg')),
                                DropdownMenuItem(value: 'name', child: Text('Namn')),
                                DropdownMenuItem(value: 'newest', child: Text('Nyast')),
                              ],
                              onChanged: (v) => setState(() => _sort = v ?? 'rating'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_allSpecs.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._allSpecs.map((s) => ChoiceChip(
                                    label: Text(s),
                                    selected: _selectedSpecs.contains(s),
                                    onSelected: (sel) {
                                      setState(() {
                                        if (sel) {
                                          _selectedSpecs.add(s);
                                        } else {
                                          _selectedSpecs.remove(s);
                                        }
                                      });
                                    },
                                  )),
                              if (_selectedSpecs.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => setState(() => _selectedSpecs.clear()),
                                  icon: const Icon(Icons.clear_all_rounded),
                                  label: const Text('Rensa filter'),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((x) {
                  final id = x['user_id'] as String?;
                  final cc = id == null ? 0 : (_certCount[id] ?? 0);
                  return _TeacherCard(data: x, certCount: cc);
                }),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Inga lärare matchar din sökning.'),
                  )
              ],
            ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int certCount;
  const _TeacherCard({required this.data, this.certCount = 0});

  double _ratingOf(dynamic r) {
    if (r is num) return r.toDouble();
    if (r is String) return double.tryParse(r) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final prof = (data['profile'] as Map?)?.cast<String, dynamic>();
    final display = (prof?['display_name'] as String?) ?? 'Lärare';
    final headline = (data['headline'] as String?) ?? '';
    final photo = prof?['photo_url'] as String?;
    final rating = _ratingOf(data['rating']);
    final specs = (data['specialties'] as List?)?.cast<String>() ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
              child: (photo == null || photo.isEmpty)
                  ? const Icon(Icons.person_rounded)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(display, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(headline, style: t.bodyMedium),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Stars(rating: rating),
                      const SizedBox(width: 8),
                      Text(rating.toStringAsFixed(1), style: t.bodySmall),
                      const Spacer(),
                      if (certCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.green.withOpacity(.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 16, color: Colors.lightGreen),
                              const SizedBox(width: 4),
                              Text('$certCount cert', style: t.labelSmall?.copyWith(color: Colors.green[200])),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (specs.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: specs
                          .take(8)
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/teacher/${data['user_id']}'),
                  child: const Text('Visa profil'),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => context.push('/messages/dm/${data['user_id']}'),
                  child: const Text('Meddela'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating; // 0–5
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star_rounded, color: Colors.amber, size: 18);
        if (i == full && half) return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 18);
        return const Icon(Icons.star_border_rounded, color: Colors.amber, size: 18);
      }),
    );
  }
}

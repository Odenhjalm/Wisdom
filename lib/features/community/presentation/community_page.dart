import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/features/community/application/community_providers.dart';
import 'package:wisdom/shared/widgets/app_scaffold.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final _q = TextEditingController();
  String _query = '';
  final Set<String> _selectedSpecs = {};
  String _sort = 'rating'; // rating | name | newest

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directory = ref.watch(teacherDirectoryProvider);
    return directory.when(
      loading: () => const AppScaffold(
        title: 'Community',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Community',
        body: Center(child: Text(_friendlyError(error))),
      ),
      data: (state) {
        final teachers = _filtered(state.teachers);
        final allSpecs = _allSpecs(state.teachers);
        return AppScaffold(
          title: 'Community',
          body: ListView(
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
                          hintText: 'Sök lärare, specialitet eller rubrik...',
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
                              DropdownMenuItem(
                                  value: 'rating', child: Text('Betyg')),
                              DropdownMenuItem(
                                  value: 'name', child: Text('Namn')),
                              DropdownMenuItem(
                                  value: 'newest', child: Text('Nyast')),
                            ],
                            onChanged: (v) =>
                                setState(() => _sort = v ?? 'rating'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (allSpecs.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...allSpecs.map(
                              (s) => ChoiceChip(
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
                              ),
                            ),
                            if (_selectedSpecs.isNotEmpty)
                              TextButton.icon(
                                onPressed: () =>
                                    setState(() => _selectedSpecs.clear()),
                                icon: const Icon(Icons.clear_all_rounded),
                                label: const Text('Rensa filter'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...teachers.map(
                (t) => _TeacherListTile(
                  teacher: t,
                  certCount: state.certCount[t['user_id']] ?? 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> teachers) {
    Iterable<Map<String, dynamic>> list = teachers;
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
          final an = (((a['profile'] as Map?)
                      ?.cast<String, dynamic>())?['display_name'] as String? ??
                  '')
              .toLowerCase();
          final bn = (((b['profile'] as Map?)
                      ?.cast<String, dynamic>())?['display_name'] as String? ??
                  '')
              .toLowerCase();
          return an.compareTo(bn);
        });
        break;
      case 'newest':
        out.sort((a, b) {
          final ad = DateTime.tryParse((a['created_at'] as String?) ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bd = DateTime.tryParse((b['created_at'] as String?) ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
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

  List<String> _allSpecs(List<Map<String, dynamic>> teachers) {
    final s = <String>{};
    for (final t in teachers) {
      final list = (t['specialties'] as List?)?.cast<String>() ?? const [];
      s.addAll(list);
    }
    final out = s.toList()..sort();
    return out;
  }

  double _ratingOf(Map<String, dynamic> t) {
    final r = t['rating'];
    if (r is num) return r.toDouble();
    if (r is String) return double.tryParse(r) ?? 0;
    return 0;
  }

  String _friendlyError(Object error) {
    if (error is AppFailure) return error.message;
    return 'Kunde inte ladda community just nu.';
  }
}

class _TeacherListTile extends StatelessWidget {
  const _TeacherListTile({required this.teacher, required this.certCount});

  final Map<String, dynamic> teacher;
  final int certCount;

  @override
  Widget build(BuildContext context) {
    final profile = (teacher['profile'] as Map?)?.cast<String, dynamic>();
    final name = profile?['display_name'] as String? ?? 'Lärare';
    final headline = teacher['headline'] as String? ?? '';
    final specs =
        ((teacher['specialties'] as List?)?.cast<String>() ?? const [])
            .join(' • ');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_rounded),
        title: Text(name),
        subtitle: Text([
          if (headline.isNotEmpty) headline,
          if (specs.isNotEmpty) specs,
          if (certCount > 0) '$certCount verifierade certifikat',
        ].where((element) => element.isNotEmpty).join('\n')),
        trailing: OutlinedButton(
          onPressed: () => context.push('/teachers/${teacher['user_id']}'),
          child: const Text('Visa profil'),
        ),
      ),
    );
  }
}

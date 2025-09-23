// lib/ui/widgets/hero_cta.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroCTA extends StatelessWidget {
  const HeroCTA({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => context.push('/course/intro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF34D399),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Starta gratis idag'),
        ),
        OutlinedButton(
          onPressed: () => context.push('/course/intro'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.transparent),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Utforska kurser'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class OrbitBottomNav extends StatelessWidget {
  final int currentIndex;
  const OrbitBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': '/home'},
      {'icon': Icons.search_rounded, 'label': 'Search', 'route': '/chat'},
      {'icon': Icons.add_circle_rounded, 'label': 'Book', 'route': '/chat'},
      {'icon': Icons.map_rounded, 'label': 'Track', 'route': '/tracking/demo'},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'route': '/home'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isSelected = i == currentIndex;
              final isCenter = i == 2;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i != currentIndex) context.push(item['route'] as String);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCenter)
                        Container(
                          width: 48, height: 48,
                          decoration: const BoxDecoration(gradient: OrbitColors.primaryGradient, shape: BoxShape.circle),
                          child: Icon(item['icon'] as IconData, color: Colors.white, size: 26),
                        )
                      else
                        Icon(item['icon'] as IconData,
                          color: isSelected ? OrbitColors.coral : OrbitColors.textHint,
                          size: 24),
                      if (!isCenter) ...[
                        const SizedBox(height: 3),
                        Text(item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? OrbitColors.coral : OrbitColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

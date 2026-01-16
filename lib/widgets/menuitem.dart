import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const MenuItem({super.key, required this.title, this.onTap});

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(
            _isHovered ? 100.0 : 0.0,
            0,
            0,
          ), // 💡 shift right on hover

          width: 300,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [Colors.orange.shade300, Colors.deepOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(colors: [Colors.white60, Colors.white60]),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ]
                : [],
            border: Border.all(color: Colors.deepOrange, width: 1),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _isHovered ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 48, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize =
            constraints.hasBoundedWidth && constraints.maxWidth < size
            ? constraints.maxWidth
            : size;
        final label = Text(
          'PARK EASE',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black87,
            fontSize: logoSize * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: const Color(0xFF126E63),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_parking_rounded,
                color: Colors.white,
                size: logoSize * 0.55,
              ),
            ),
            if (showText &&
                (!constraints.hasBoundedWidth ||
                    constraints.maxWidth > logoSize + 10)) ...[
              const SizedBox(width: 10),
              constraints.hasBoundedWidth ? Flexible(child: label) : label,
            ],
          ],
        );
      },
    );
  }
}

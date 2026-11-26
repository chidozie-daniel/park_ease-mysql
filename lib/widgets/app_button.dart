import 'package:material_ui/material_ui.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor =
        foregroundColor ??
        (isSecondary ? const Color(0xFF9894BD) : Colors.white);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final labelWidget = Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        );

        return SizedBox(
          width: buttonWidth,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: isSecondary
                      ? Colors.transparent
                      : (backgroundColor ?? const Color(0xFF9894BD)),
                  foregroundColor:
                      foregroundColor ??
                      (isSecondary ? const Color(0xFF9894BD) : Colors.white),
                  elevation: isSecondary ? 0 : 2,
                  side: isSecondary
                      ? const BorderSide(color: Color(0xFF9894BD), width: 1.5)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  minimumSize: Size(0, height),
                ).copyWith(
                  elevation: WidgetStateProperty.resolveWith<double>((states) {
                    if (isSecondary) return 0;
                    if (states.contains(WidgetState.pressed)) return 1;
                    return 2;
                  }),
                ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: spinnerColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : buttonWidth != null && buttonWidth.isFinite
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Flexible(child: labelWidget)],
                  )
                : labelWidget,
          ),
        );
      },
    );
  }
}

part of 'main.components.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.glowOpacity = 0.05,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final double glowOpacity;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // A beautiful gradient dark slate-blue cards
    final bg = backgroundColor ?? (isDark 
        ? const Color(0xFF1A1D24).withOpacity(0.85)
        : Colors.white.withOpacity(0.9));
    
    final borderCol = borderColor ?? (isDark 
        ? const Color(0xFF2E3440).withOpacity(0.5) 
        : Colors.grey.shade200);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          // Soft outer shadow
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(glowOpacity),
              blurRadius: 30,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18.0,
    this.color = const Color(0xFFF59E0B),
  });

  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    int closedStars = rating.floor();
    bool hasHalf = (rating - closedStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < closedStars) {
          return Icon(Icons.star_rounded, size: size, color: color);
        } else if (index == closedStars && hasHalf) {
          return Icon(Icons.star_half_rounded, size: size, color: color);
        } else {
          return Icon(Icons.star_outline_rounded, size: size, color: color.withOpacity(0.3));
        }
      }),
    );
  }
}

class GlowBadge extends StatelessWidget {
  const GlowBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final txtColor = textColor ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: txtColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: txtColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

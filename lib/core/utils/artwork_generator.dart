import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Returns a gradient based on a numeric seed, used for deterministic
/// placeholder artwork for songs, playlists, photos and memories.
LinearGradient artworkGradient(int seed) {
  final palette = AppColors.artworkPalettes[seed % AppColors.artworkPalettes.length];
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: palette,
  );
}

/// A fixed-size square tile painted with a seeded gradient.
class ArtworkTile extends StatelessWidget {
  final int seed;
  final double size;
  final double borderRadius;
  final IconData? icon;
  final double iconSize;

  const ArtworkTile({
    super.key,
    required this.seed,
    this.size = 56,
    this.borderRadius = 10,
    this.icon,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: artworkGradient(seed),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white.withOpacity(0.85), size: iconSize)
          : null,
    );
  }
}

/// A circle avatar painted with a seeded gradient and initials.
class AvatarTile extends StatelessWidget {
  final String seed;
  final double size;
  final String? label;

  const AvatarTile({
    super.key,
    required this.seed,
    this.size = 40,
    this.label,
  });

  int get _seedInt => seed.codeUnits.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final initials = (label ?? seed).isNotEmpty
        ? (label ?? seed)[0].toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: artworkGradient(_seedInt),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

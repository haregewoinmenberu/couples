import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// Non-web fallback: thumbnail with a "watch on YouTube" card.
Widget buildYouTubeView(String videoId, {String? thumbnail}) =>
    _YouTubeLinkCard(videoId: videoId, thumbnail: thumbnail);

class _YouTubeLinkCard extends StatelessWidget {
  final String videoId;
  final String? thumbnail;
  const _YouTubeLinkCard({required this.videoId, this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnail != null && thumbnail!.isNotEmpty)
              Image.network(thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            Container(color: Colors.black26),
            const Center(
              child: Icon(Icons.play_circle_filled_rounded,
                  color: Colors.white, size: 64),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Watch on YouTube',
                    style: AppTextStyles.caption(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

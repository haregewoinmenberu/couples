// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registered = <String>{};

/// Embeds a YouTube iframe directly in the Flutter web page. Nothing is
/// downloaded or stored — the video streams from YouTube.
Widget buildYouTubeView(String videoId, {String? thumbnail}) {
  final viewType = 'oursound-youtube-$videoId';
  if (!_registered.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0'
        ..setAttribute('allow',
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture')
        ..setAttribute('allowfullscreen', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';
      return iframe;
    });
    _registered.add(viewType);
  }
  return SizedBox(
    height: 220,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: HtmlElementView(viewType: viewType),
    ),
  );
}

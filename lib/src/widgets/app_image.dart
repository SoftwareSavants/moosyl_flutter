import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A customizable image widget that supports file, base64, and placeholder images.
class AppImage extends StatelessWidget {
  /// The URI of the image, can be a file path or base64 string.
  final String uri;

  /// Optional full-size URI for high-resolution version of the image.
  final String? fullSizeUri;

  /// Placeholder image data to show while loading.
  final Uint8List? placeholderImage;

  /// Optional width of the image.
  final double? width;

  /// Optional height of the image.
  final double? height;

  /// How the image should be inscribed into the space.
  final BoxFit? fit;

  /// Whether the image can be zoomed.
  final bool zoomable;

  /// Border radius for the image corners.
  final BorderRadius borderRadius;

  /// Tag for hero animation.
  final Object? heroTag;

  /// List of related images for gallery view.
  final List<String>? images;

  /// Custom zoom icon widget.
  final Widget? customZoomIcon;

  /// Optional color to blend with the image.
  final Color? color;

  /// Creates an [AppImage] widget.
  ///
  /// The [uri] parameter is required and must be either a file path or base64 string.
  const AppImage({
    Key? key,
    required this.uri,
    this.fullSizeUri,
    this.placeholderImage,
    this.width,
    this.height,
    this.fit,
    this.zoomable = true,
    this.borderRadius = BorderRadius.zero,
    this.heroTag,
    this.images,
    this.customZoomIcon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? uri;

    return GestureDetector(
      child: Hero(
        tag: tag,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: uri.contains('.')
                  ? Image.file(
                      File(uri),
                      width: width,
                      height: height,
                      fit: fit,
                      color: color,
                    )
                  : uri.isEmpty
                      ? const Text('empty')
                      : Image.memory(
                          base64Decode(uri),
                          width: width,
                          height: height,
                          fit: fit,
                          color: color,
                        ),
            ),
            if (zoomable || customZoomIcon != null)
              Positioned(
                top: 8,
                right: 8,
                child: customZoomIcon ??
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.zoom_out_map_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

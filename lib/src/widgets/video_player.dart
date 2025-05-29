import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// A high-performance video player widget that supports both network and asset videos.
///
/// This widget uses the `video_player` plugin for core video functionality and
/// `chewie` for a more polished UI experience. It supports both network and local
/// asset videos, with configurable autoplay behavior.
///
/// Example usage:
/// ```dart
/// VideoPlayer(
///   videoPath: 'assets/intro.mp4',
///   autoPlay: true,
/// )
/// ```
class VideoPlayer extends HookWidget {
  /// The URI or asset path of the video to be played.
  final String videoPath;

  /// Controls whether the video should start playing automatically.
  /// Defaults to false.
  final bool autoPlay;

  /// Indicates if the video source is from network (true) or local assets (false).
  /// Defaults to false.
  final bool isNetworkVideo;

  /// Default video aspect ratio
  static const double _defaultAspectRatio = 16 / 9;

  /// Creates a new instance of [VideoPlayer].
  ///
  /// [videoPath] must not be null and should be either a valid network URL
  /// or an asset path depending on [isNetworkVideo].
  const VideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = false,
    this.isNetworkVideo = false,
  });

  VideoPlayerController _createController() {
    return isNetworkVideo
        ? VideoPlayerController.networkUrl(
            Uri.parse(videoPath),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
        : VideoPlayerController.asset(
            videoPath,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
  }

  ChewieController _createChewieController({
    required VideoPlayerController videoController,
    required BuildContext context,
  }) {
    return ChewieController(
      videoPlayerController: videoController,
      autoPlay: autoPlay,
      looping: true,
      aspectRatio: _defaultAspectRatio,
      showControls: true,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: false,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).colorScheme.primary,
        handleColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.grey.shade800,
        bufferedColor: Colors.grey.shade300,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (isNetworkVideo) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _createController(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoController =
        useMemoized(_createController, [videoPath, isNetworkVideo]);
    final initializeFuture =
        useMemoized(() => videoController.initialize(), [videoController]);
    final chewieController = useState<ChewieController?>(null);

    useEffect(() {
      return () {
        videoController.dispose();
        chewieController.value?.dispose();
      };
    }, [videoController]);

    return FutureBuilder(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _buildErrorWidget(context, snapshot.error.toString());
          }

          chewieController.value ??= _createChewieController(
            videoController: videoController,
            context: context,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AspectRatio(
              aspectRatio: _defaultAspectRatio,
              child: Chewie(
                controller: chewieController.value!,
              ),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isNetworkVideo)
              ElevatedButton.icon(
                onPressed: () {
                  final controller = _createController();
                  controller.initialize().then((_) {
                    controller.play();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/measurement_providers.dart';

void _showFullscreen(BuildContext context, ImageProvider image) {
  showDialog<void>(
    context: context,
    builder: (_) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            maxScale: 4.0,
            child: Center(
              child: Image(image: image, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Carousel of measurement images for the currently selected baby.
///
/// Each image is stored encrypted on disk; this widget decrypts on demand
/// using [MeasurementRepository.getDecryptedImage].
///
/// Set [embedded] to true when hosting inside another card so the widget
/// does not wrap itself in its own [Card].
class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({super.key, required this.babyId, this.embedded = false});

  final int babyId;
  final bool embedded;

  @override
  ConsumerState<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends ConsumerState<ImageCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(measurementsProvider(widget.babyId));

    return measurementsAsync.when(
      loading: () => _PlaceholderFrame(
          embedded: widget.embedded, child: const CircularProgressIndicator()),
      error: (e, _) =>
          _PlaceholderFrame(embedded: widget.embedded, child: Text('Error: $e')),
      data: (measurements) {
        final withImages = measurements.where((m) => m.hasImage).toList();

        if (withImages.isEmpty) {
          return _PlaceholderFrame(
            embedded: widget.embedded,
            child: const SizedBox.shrink(),
          );
        }

        final pageView = SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: withImages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) {
              final m = withImages[i];
              return _EncryptedImageTile(
                imageRef: m.encryptedImageRef!,
                measurementRepo: ref.read(measurementRepositoryProvider),
              );
            },
          ),
        );

        final dots = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(withImages.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _currentPage == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            );
          }),
        );

        if (widget.embedded) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: pageView,
              ),
              const SizedBox(height: 8),
              dots,
              const SizedBox(height: 4),
            ],
          );
        }
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              pageView,
              const SizedBox(height: 8),
              dots,
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _EncryptedImageTile extends StatefulWidget {
  const _EncryptedImageTile({
    required this.imageRef,
    required this.measurementRepo,
  });

  final String imageRef;
  final dynamic measurementRepo;

  @override
  State<_EncryptedImageTile> createState() => _EncryptedImageTileState();
}

class _EncryptedImageTileState extends State<_EncryptedImageTile> {
  late Future<List<int>?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.measurementRepo.getDecryptedImage(widget.imageRef);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>?>(
      future: _imageFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _PlaceholderFrame(child: CircularProgressIndicator());
        }
        if (snap.data == null || snap.data!.isEmpty) {
          return const _PlaceholderFrame(
            child: Icon(Icons.broken_image_outlined, size: 48),
          );
        }
        final image = MemoryImage(Uint8List.fromList(snap.data!));
        return GestureDetector(
          onTap: () => _showFullscreen(context, image),
          child: Image(
            image: image,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
    );
  }
}

class _PlaceholderFrame extends StatefulWidget {
  const _PlaceholderFrame({required this.child, this.embedded = false});

  final Widget child;
  final bool embedded;

  @override
  State<_PlaceholderFrame> createState() => _PlaceholderFrameState();
}

class _PlaceholderFrameState extends State<_PlaceholderFrame> {
  static const _placeholders = [
    'assets/images/ashbaby.jpg',
    'assets/images/ashbebe.jpg',
    'assets/images/baby.jpg',
  ];

  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final imageStack = SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: _placeholders.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final image = AssetImage(_placeholders[i]);
              return GestureDetector(
                onTap: () => _showFullscreen(context, image),
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              );
            },
          ),
          if (widget.child is! SizedBox)
            Center(child: widget.child),
        ],
      ),
    );

    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_placeholders.length, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _page == i ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _page == i ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        );
      }),
    );

    if (widget.embedded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageStack,
          ),
          const SizedBox(height: 8),
          dots,
          const SizedBox(height: 4),
        ],
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [imageStack, const SizedBox(height: 8), dots, const SizedBox(height: 8)],
      ),
    );
  }
}

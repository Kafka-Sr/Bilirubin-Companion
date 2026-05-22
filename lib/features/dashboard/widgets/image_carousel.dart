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

/// Carousel of measurement cards (one per reading, newest first).
///
/// Swiping updates [selectedCarouselMeasurementIdProvider] so the reading card
/// and Bhutani chart dot follow the selection. Cards without an image show a
/// placeholder instead of being skipped.
///
/// Set [embedded] to true when hosting inside another card.
class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({super.key, required this.babyId, this.embedded = false});

  final String babyId;
  final bool embedded;

  @override
  ConsumerState<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends ConsumerState<ImageCarousel> {
  final _controller = PageController();
  int _currentPage = 0;
  int _prevLength = 0;

  @override
  void didUpdateWidget(ImageCarousel old) {
    super.didUpdateWidget(old);
    if (old.babyId != widget.babyId) {
      _currentPage = 0;
      _prevLength = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpToPage(0);
        ref.read(selectedCarouselMeasurementIdProvider.notifier).state = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(measurementsProvider(widget.babyId));

    ref.listen<String?>(selectedCarouselMeasurementIdProvider, (_, newId) {
      final measurements =
          measurementsAsync.valueOrNull ?? [];
      final idx = newId == null
          ? 0
          : measurements.indexWhere((m) => m.measurementId == newId);
      if (idx != -1 && (_controller.page?.round() ?? 0) != idx) {
        _controller.animateToPage(
          idx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });

    return measurementsAsync.when(
      loading: () => _PlaceholderFrame(
          embedded: widget.embedded, child: const CircularProgressIndicator()),
      error: (e, _) =>
          _PlaceholderFrame(embedded: widget.embedded, child: Text('Error: $e')),
      data: (measurements) {
        // Snap to newest (page 0) when a new measurement arrives.
        if (measurements.length > _prevLength && _prevLength > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.hasClients) _controller.jumpToPage(0);
            ref.read(selectedCarouselMeasurementIdProvider.notifier).state =
                null;
          });
        }
        _prevLength = measurements.length;

        if (measurements.isEmpty) {
          return _PlaceholderFrame(
            embedded: widget.embedded,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
          );
        }

        final pageView = SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: measurements.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              // Null on page 0 means "use latest" — avoids stale selection
              // after a new reading arrives while the user is on page 0.
              ref.read(selectedCarouselMeasurementIdProvider.notifier).state =
                  i == 0 ? null : measurements[i].measurementId;
            },
            itemBuilder: (_, i) {
              final m = measurements[i];
              if (m.hasImage && m.encryptedImageRef != null) {
                return _EncryptedImageTile(
                  imageRef: m.encryptedImageRef!,
                  measurementRepo: ref.read(measurementRepositoryProvider),
                );
              }
              return const _NoImageTile();
            },
          ),
        );

        final mostRecentIsOld =
            measurements.isNotEmpty && measurements[0].ageHours > 168;
        final dots = _CarouselDots(
          count: measurements.length,
          currentPage: _currentPage,
          mostRecentIsOld: mostRecentIsOld,
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

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.count,
    required this.currentPage,
    required this.mostRecentIsOld,
  });

  final int count;
  final int currentPage;
  final bool mostRecentIsOld;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mostRecentColor =
        mostRecentIsOld ? const Color(0xFF7C3AED) : colorScheme.error;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final dotColor = i == 0
            ? mostRecentColor
            : (currentPage == i
                ? colorScheme.primary
                : colorScheme.outlineVariant);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: currentPage == i ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: dotColor,
          ),
        );
      }),
    );
  }
}

class _NoImageTile extends StatelessWidget {
  const _NoImageTile();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
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

class _PlaceholderFrame extends StatelessWidget {
  const _PlaceholderFrame({required this.child, this.embedded = false});

  final Widget child;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final frame = SizedBox(
      height: 200,
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(child: child),
      ),
    );

    if (embedded) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: frame,
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: frame,
    );
  }
}

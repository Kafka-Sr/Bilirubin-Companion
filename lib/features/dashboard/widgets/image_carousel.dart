import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/measurement_providers.dart';

/// Carousel of measurement images for the currently selected baby.
///
/// Each image is stored encrypted on disk; this widget decrypts on demand
/// using [MeasurementRepository.getDecryptedImage].
class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({super.key, required this.babyId});

  final int babyId;

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
      loading: () => const _PlaceholderFrame(child: CircularProgressIndicator()),
      error: (e, _) => _PlaceholderFrame(child: Text('Error: $e')),
      data: (measurements) {
        final withImages = measurements.where((m) => m.hasImage).toList();

        if (withImages.isEmpty) {
          return const _PlaceholderFrame(
            child: Icon(Icons.image_not_supported_outlined, size: 48),
          );
        }

        return Column(
          children: [
            SizedBox(
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
            ),
            const SizedBox(height: 8),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(withImages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 10 : 6,
                  height: _currentPage == i ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
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
        return Image.memory(
          snap.data as dynamic,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      },
    );
  }
}

class _PlaceholderFrame extends StatelessWidget {
  const _PlaceholderFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: child),
    );
  }
}

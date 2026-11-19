import 'package:flutter/material.dart';

import 'app_network_image.dart';

/// Carrusel de fotos del cóctel con indicador de puntos. Al tocar se abre a pantalla completa.
class ImageCarousel extends StatefulWidget {
  final List<String> urls;
  final double aspectRatio;

  const ImageCarousel({super.key, required this.urls, this.aspectRatio = 4 / 3});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    final scheme = Theme.of(context).colorScheme;

    if (urls.isEmpty) {
      return AspectRatio(aspectRatio: widget.aspectRatio, child: const AppNetworkImage(url: null));
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => FullscreenGallery(urls: urls, initialIndex: i),
              )),
              child: AppNetworkImage(url: urls[i]),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _index;
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(i,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? scheme.primary : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// Galería a pantalla completa con zoom (pellizcar) y deslizamiento.
class FullscreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const FullscreenGallery({super.key, required this.urls, this.initialIndex = 0});

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.urls.length > 1 ? Text('${_index + 1} / ${widget.urls.length}') : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(child: AppNetworkImage(url: widget.urls[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }
}

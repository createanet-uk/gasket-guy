import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewer extends StatelessWidget {
  final String? url;
  final File? file;
  final List<dynamic>? galleryItems;
  final int initialIndex;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ImagePreviewer({
    super.key,
    this.url,
    this.file,
    this.galleryItems,
    this.initialIndex = 0,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  void _showGallery(BuildContext context) {
    // If galleryItems is provided, use it; otherwise, wrap the single image in a list
    final List<dynamic> items = galleryItems ?? [url ?? file];

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        // Using a fade transition for a "premium" feel
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (context, _, __) => _GalleryView(
          items: items,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGallery(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: url != null ? _buildNetworkImage(url!) : _buildFileImage(file!),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[300],
            ),
          ),
        );
      },
      errorBuilder: (c, e, s) => Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[300],
        size: 24,
      ),
    );
  }

  Widget _buildFileImage(File? fileImage) {
    if (fileImage == null) return const SizedBox();
    return Image.file(
      fileImage,
      fit: fit,
      errorBuilder: (c, e, s) => const Icon(Icons.error_outline),
    );
  }
}

// --- FULLSCREEN GALLERY VIEW ---

class _GalleryView extends StatefulWidget {
  final List<dynamic> items;
  final int initialIndex;

  const _GalleryView({required this.items, required this.initialIndex});

  @override
  State<_GalleryView> createState() => _GalleryViewState();
}

// class _GalleryViewState extends State<_GalleryView> {
//   late PageController _pageController;
//   late int _currentIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white.withOpacity(0.95),
//       body: Stack(
//         children: [
//           // Main Image View with Padding so image doesn't hit screen edges
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: widget.items.length,
//               onPageChanged: (index) => setState(() => _currentIndex = index),
//               itemBuilder: (context, index) {
//                 final item = widget.items[index];
//                 return InteractiveViewer(
//                   minScale: 1.0,
//                   maxScale: 5.0,
//                   clipBehavior: Clip.none,
//                   child: item is String
//                       ? Image.network(item, fit: BoxFit.contain)
//                       : Image.file(item as File, fit: BoxFit.contain),
//                 );
//               },
//             ),
//           ),
//
//           // Top Action Bar with Cross Icon
//           SafeArea(
//             child: Align(
//               alignment: Alignment.topRight,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.close_rounded, color: Colors.black, size: 24),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Bottom Counter
//           if (widget.items.length > 1)
//             Positioned(
//               bottom: 50,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     "${_currentIndex + 1} / ${widget.items.length}",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//           // Navigation Arrows for Desktop/Large Screen feel
//           if (widget.items.length > 1) ...[
//             _buildNavArrow(
//               alignment: Alignment.centerLeft,
//               icon: Icons.chevron_left_rounded,
//               onTap: () => _pageController.previousPage(
//                   duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
//               show: _currentIndex > 0,
//             ),
//             _buildNavArrow(
//               alignment: Alignment.centerRight,
//               icon: Icons.chevron_right_rounded,
//               onTap: () => _pageController.nextPage(
//                   duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
//               show: _currentIndex < widget.items.length - 1,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavArrow({
//     required Alignment alignment,
//     required IconData icon,
//     required VoidCallback onTap,
//     required bool show,
//   }) {
//     return Align(
//       alignment: alignment,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 250),
//           opacity: show ? 1.0 : 0.0,
//           child: IgnorePointer(
//             ignoring: !show,
//             child: IconButton(
//               icon: Icon(icon, color: Colors.white60, size: 48),
//               onPressed: onTap,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _GalleryView extends StatefulWidget {
//   final List<dynamic> items;
//   final int initialIndex;
//
//   const _GalleryView({required this.items, required this.initialIndex});
//
//   @override
//   State<_GalleryView> createState() => _GalleryViewState();
// }

class _GalleryViewState extends State<_GalleryView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // initialPage ensures we start at the clicked image
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Stack(
        children: [
          // 1. SWIPEABLE PAGE VIEW
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];

                // Using a unique key for each item ensures the InteractiveViewer
                // resets its zoom level when you swipe to the next image.
                return InteractiveViewer(
                  key: ValueKey(index),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: item is String
                        ? Image.network(
                      item,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                    )
                        : Image.file(
                      item as File,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. TOP CLOSE BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),

          // 3. NAVIGATION ARROWS
          if (widget.items.length > 1) ...[
            _buildArrow(
              alignment: Alignment.centerLeft,
              icon: Icons.chevron_left_rounded,
              show: _currentIndex > 0,
              onTap: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            _buildArrow(
              alignment: Alignment.centerRight,
              icon: Icons.chevron_right_rounded,
              show: _currentIndex < widget.items.length - 1,
              onTap: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
          ],

          // 4. COUNTER
          if (widget.items.length > 1)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.items.length}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrow({
    required Alignment alignment,
    required IconData icon,
    required bool show,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: show ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !show,
          child: IconButton(
            icon: Icon(icon, color: Colors.white70, size: 50),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
import 'package:carousel_slider/carousel_slider.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/ads.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class HomeBanner extends StatefulWidget {
  final List<Ads> ads;
  final bool isDark;

  const HomeBanner({super.key, required this.ads, required this.isDark});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentBanner = 0;
  final Logger logger = Logger();

  Widget _buildSmartImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          logger.e("Lỗi tải ảnh MẠNG: $url", error: error, stackTrace: stackTrace);
          return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image_rounded));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: AppColors.primary,
          ));
        },
      );
    } else {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          logger.e("Lỗi tải ảnh ASSET: $url", error: error, stackTrace: stackTrace);
          return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image_rounded));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn, 
            viewportFraction: 0.9,
            enableInfiniteScroll: widget.ads.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBanner = index;
              });
            },
          ),
          items: widget.ads.map((ad) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSmartImage(ad.imageUrl),
                    // Gradient Overlay for text readability (optional)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.ads.asMap().entries.map((entry) {
            bool active = _currentBanner == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: active ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active 
                  ? (widget.isDark ? AppColors.primaryDark : AppColors.primary)
                  : (widget.isDark ? Colors.grey[700] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

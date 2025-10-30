import 'package:flutter/material.dart';
import '../models/place.dart';

class PopularSection extends StatelessWidget {
  final List<Place> popularPlaces;
  final Function(Place)? onPlaceTap;
  final Function(Place)? onFavoriteTap;

  const PopularSection({
    super.key,
    required this.popularPlaces,
    this.onPlaceTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Popular'),
        SizedBox(
          height: 210,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: popularPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final place = popularPlaces[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onPlaceTap?.call(place),
                child: PopularCard(
                  place: place,
                  onFavoriteTap: onFavoriteTap,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class PopularCard extends StatelessWidget {
  final Place place;
  final Function(Place)? onFavoriteTap;

  const PopularCard({
    super.key,
    required this.place,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;
    return SizedBox(
      width: 180,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.asset(
              place.imageAsset,
              height: 210,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 210,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              height: 210,
              width: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22B07D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () => onFavoriteTap?.call(place),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  place.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: place.isFavorite ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  place.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
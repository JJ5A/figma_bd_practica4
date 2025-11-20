import 'package:flutter/material.dart';
import '../models/place.dart';

class NearbySection extends StatelessWidget {
  final List<Place> nearbyPlaces;
  final Function(Place)? onPlaceTap;
  final Function(Place)? onFavoriteTap;

  const NearbySection({
    super.key,
    required this.nearbyPlaces,
    this.onPlaceTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 280,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: nearbyPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final place = nearbyPlaces[i];
              final isFavorite = place.isFavorite;
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onPlaceTap?.call(place),
                child: NearbyCard(
                  place: place,
                  isFavorite: isFavorite,
                  onFavoriteTap: onFavoriteTap,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NearbyCard extends StatelessWidget {
  final Place place;
  final bool isFavorite;
  final Function(Place)? onFavoriteTap;

  const NearbyCard({
    super.key,
    required this.place,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    const radiusOuter = 22.0;
    const radiusInner = 18.0;

    return SizedBox(
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radiusOuter),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(radiusInner),
                  child: Image.asset(
                    place.imageAsset,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(radiusInner),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      onFavoriteTap?.call(place);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: Offset(0, 4),
                            color: Color(0x22000000),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2B2B2B),
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: Color(0xFF9AA0A6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    place.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: place.price,
                          style: const TextStyle(
                            color: Color(0xFF22B07D),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const TextSpan(
                          text: '/Day',
                          style: TextStyle(
                            color: Color(0xFF22B07D),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22B07D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


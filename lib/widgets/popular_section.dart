import 'package:flutter/material.dart';
import '../models/place.dart';

class PopularSection extends StatelessWidget {
  final List<Place> popularPlaces;
  final Function(Place)? onPlaceTap;
  final Function(Place)? onFavoriteTap;
  final Function(Place)? onEditPlace;
  final Function(Place)? onDeletePlace;
  final bool Function(Place)? isPlaceProtected;

  const PopularSection({
    super.key,
    required this.popularPlaces,
    this.onPlaceTap,
    this.onFavoriteTap,
    this.onEditPlace,
    this.onDeletePlace,
    this.isPlaceProtected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 210,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: popularPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final place = popularPlaces[i];
              final isFavorite = place.isFavorite;
              final protected = isPlaceProtected?.call(place) ?? false;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onPlaceTap?.call(place),
                child: PopularCard(
                  place: place,
                  isFavorite: isFavorite,
                  onFavoriteTap: onFavoriteTap,
                  onEditPlace: onEditPlace,
                  onDeletePlace: onDeletePlace,
                  isProtected: protected,
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
  final bool isFavorite;
  final Function(Place)? onFavoriteTap;
  final Function(Place)? onEditPlace;
  final Function(Place)? onDeletePlace;
  final bool isProtected;

  const PopularCard({
    super.key,
    required this.place,
    required this.isFavorite,
    this.onFavoriteTap,
    this.onEditPlace,
    this.onDeletePlace,
    this.isProtected = false,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => onFavoriteTap?.call(place),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                if (!isProtected) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CardActionButton(
                        icon: Icons.edit,
                        backgroundColor: const Color(0xFF22B07D),
                        iconColor: Colors.white,
                        tooltip: 'Editar',
                        onTap: () => onEditPlace?.call(place),
                      ),
                      const SizedBox(width: 6),
                      _CardActionButton(
                        icon: Icons.delete_outline,
                        backgroundColor: Colors.white,
                        iconColor: Colors.red,
                        tooltip: 'Eliminar',
                        onTap: () => onDeletePlace?.call(place),
                      ),
                    ],
                  ),
                ],
              ],
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


class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String tooltip;
  final VoidCallback? onTap;

  const _CardActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.95),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
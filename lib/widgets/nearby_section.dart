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
        const _SectionTitle('Nearby residence'),
        SizedBox(
          height: 280,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: nearbyPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final place = nearbyPlaces[i];
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onPlaceTap?.call(place),
                child: NearbyCard(
                  place: place,
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

class NearbyCard extends StatefulWidget {
  final Place place;
  final Function(Place)? onFavoriteTap;

  const NearbyCard({
    super.key,
    required this.place,
    this.onFavoriteTap,
  });

  @override
  State<NearbyCard> createState() => _NearbyCardState();
}

class _NearbyCardState extends State<NearbyCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.place.isFavorite;
  }

  @override
  void didUpdateWidget(NearbyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.isFavorite != widget.place.isFavorite) {
      isFavorite = widget.place.isFavorite;
    }
  }

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
                    widget.place.imageAsset,
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
                      setState(() => isFavorite = !isFavorite);
                      widget.onFavoriteTap?.call(widget.place);
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
              widget.place.title,
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
                    widget.place.subtitle,
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
                          text: widget.place.price,
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
                        widget.place.rating.toStringAsFixed(1),
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
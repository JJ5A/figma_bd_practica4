import 'package:flutter/material.dart';
import '../models/category.dart';

class CategorySection extends StatelessWidget {
  final List<Category> categories;
  final Function(Category)? onCategoryTap;

  const CategorySection({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Category'),
        SizedBox(
          height: 120,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) => CategoryChip(
              category: categories[i],
              onTap: onCategoryTap,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final Category category;
  final Function(Category)? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(category),
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F9F4),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  category.imageAsset,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.category,
                      size: 30,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
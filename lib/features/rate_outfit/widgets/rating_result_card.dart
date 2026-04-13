import 'package:flutter/material.dart';

class RatingResultCard extends StatelessWidget {
  final double rating;
  final String feedback;

  const RatingResultCard({
    super.key,
    required this.rating,
    required this.feedback,
  });

  Color _getRatingColor(double score) {
    if (score >= 8.0) return Colors.greenAccent;
    if (score >= 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor(rating);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: ratingColor.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Outfit Score',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${rating.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: ratingColor,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Text(
            feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

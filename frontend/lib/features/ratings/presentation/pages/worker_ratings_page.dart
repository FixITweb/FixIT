import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/datasources/rating_api.dart';
import '../../../../core/network/api_client.dart';

class WorkerRatingsPage extends StatelessWidget {
  final int workerId;
  final String workerName;
  final double? averageRating;

  const WorkerRatingsPage({
    super.key,
    required this.workerId,
    required this.workerName,
    this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RatingBloc(
        RatingRepository(RatingApi(ApiClient())),
      )..add(LoadWorkerRatings(workerId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Worker Ratings'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF14B8A6),
        ),
        body: BlocBuilder<RatingBloc, RatingState>(
          builder: (context, state) {
            if (state is RatingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RatingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(state.message),
                  ],
                ),
              );
            }

            if (state is RatingsLoaded) {
              if (state.ratings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 80,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Ratings Yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "This worker hasn't received any ratings yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with average rating
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            workerName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                averageRating?.toStringAsFixed(1) ?? '0.0',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (averageRating?.toInt() ?? 0)
                                            ? Icons.star
                                            : Icons.star_outline,
                                        color: Colors.white,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${state.ratings.length} rating${state.ratings.length != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Rating Distribution
                    _RatingDistribution(ratings: state.ratings),

                    // Ratings list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.ratings.length,
                      itemBuilder: (context, index) {
                        final rating = state.ratings[index];
                        return _RatingCard(rating: rating);
                      },
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  final List<dynamic> ratings;

  const _RatingDistribution({required this.ratings});

  @override
  Widget build(BuildContext context) {
    // Calculate distribution
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var rating in ratings) {
      final stars = rating.rating.toInt();
      if (distribution.containsKey(stars)) {
        distribution[stars] = distribution[stars]! + 1;
      }
    }

    final total = ratings.length;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            final count = distribution[stars] ?? 0;
            final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        Text(
                          '$stars',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.star, size: 14, color: Color(0xFFF97316)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? count / total : 0,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForRating(stars),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$percentage%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getColorForRating(int stars) {
    if (stars >= 4) return Colors.green;
    if (stars == 3) return Colors.amber;
    return Colors.red;
  }
}

class _RatingCard extends StatelessWidget {
  final dynamic rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.rating.toInt()
                          ? Icons.star
                          : Icons.star_outline,
                      color: const Color(0xFFF97316),
                      size: 18,
                    );
                  }),
                ),
                Text(
                  '${rating.rating.toStringAsFixed(1)}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14B8A6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rating.customerName != null && rating.customerName != 'Anonymous')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      rating.customerName ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (rating.review.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating.review,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            Text(
              _formatDate(rating.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/datasources/rating_api.dart';
import '../../../../core/network/api_client.dart';

class RatingPage extends StatefulWidget {
  final int workerId;
  final String workerName;
  final String serviceName;

  const RatingPage({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.serviceName,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RatingBloc(
        RatingRepository(RatingApi(ApiClient())),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Worker'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF14B8A6),
        ),
        body: BlocListener<RatingBloc, RatingState>(
          listener: (context, state) {
            if (state is RatingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rating submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is RatingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Completed',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${widget.workerName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Rating Section
                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Star Rating
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = (index + 1).toDouble();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                index < _rating ? Icons.star : Icons.star_outline,
                                size: 48,
                                color: const Color(0xFFF97316),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      if (_rating > 0)
                        Text(
                          _getRatingLabel(_rating.toInt()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Review Text
                const Text(
                  'Share your feedback (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Tell us about your experience...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF14B8A6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<RatingBloc, RatingState>(
                  builder: (context, state) {
                    final isLoading = state is RatingLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _rating == 0 || isLoading
                            ? null
                            : () {
                                context.read<RatingBloc>().add(
                                      SubmitRating(
                                        workerId: widget.workerId,
                                        rating: _rating,
                                        review: _reviewController.text,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

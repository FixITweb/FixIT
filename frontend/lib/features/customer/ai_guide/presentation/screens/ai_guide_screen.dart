import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../../../home/presentation/widgets/bottom_nav.dart';

class AIGuideScreen extends StatefulWidget {
  const AIGuideScreen({super.key});

  @override
  State<AIGuideScreen> createState() => _AIGuideScreenState();
}

class _AIGuideScreenState extends State<AIGuideScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  final PageController _pageController = PageController();

  bool _isLoading = false;
  List<dynamic>? _guideSteps;

  Future<void> _getAIGuide() async {
    if (_promptController.text.trim().isEmpty) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _guideSteps = null;
    });

    try {
      final response = await _apiClient.post(
        'ai-guide/',
        data: {'user_prompt': _promptController.text.trim()},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        setState(() {
          _guideSteps = response.data['guide'];
        });
      } else {
        _showError('Failed to get guide. Please try again.');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _nextStep() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Guide'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText:
                          'Describe what you need to fix (e.g., Leaking sink pipe)...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isLoading ? null : _getAIGuide,
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Get AI Fix Guide'),
                ),
              ],
            ),
          ),
          if (_guideSteps != null && _guideSteps!.isNotEmpty)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _guideSteps!.length,
                itemBuilder: (context, index) {
                  final step = _guideSteps![index];
                  final isFirst = index == 0;
                  final isLast = index == _guideSteps!.length - 1;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Step ${index + 1} of ${_guideSteps!.length}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              step['title'] ?? 'Action',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  step['description'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(height: 1.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: isFirst ? null : _prevStep,
                                  icon: const Icon(Icons.arrow_back_ios,
                                      size: 16),
                                  label: const Text("Previous"),
                                ),
                                FilledButton.icon(
                                  onPressed: isLast ? null : _nextStep,
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                  label: const Text("Next"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}

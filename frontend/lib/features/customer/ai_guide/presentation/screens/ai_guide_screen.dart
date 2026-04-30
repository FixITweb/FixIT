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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AI Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                    color: Colors.white,
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
                      hintText: 'Describe what you need to fix (e.g., Leaking sink pipe)...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _getAIGuide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4DB), // Primary teal/blue color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: const Color(0xFF00B4DB).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Get AI Fix Guide',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Step ${index + 1} of ${_guideSteps!.length}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              step['title'] ?? 'Action',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0083B0),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  step['description'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isFirst ? null : _prevStep,
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                                  label: const Text("Previous"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: const Color(0xFF00B4DB),
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    disabledForegroundColor: Colors.grey.shade400,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: isLast ? null : _nextStep,
                                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                  label: const Text("Next"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF00B4DB),
                                    elevation: 2,
                                    disabledBackgroundColor: Colors.grey.shade200,
                                    disabledForegroundColor: Colors.grey.shade400,
                                  ),
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

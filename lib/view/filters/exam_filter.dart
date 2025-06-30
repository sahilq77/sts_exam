import 'package:flutter/material.dart';

import '../../app_colors.dart';


class FilterBottomSheet extends StatefulWidget {
  final String? initialFilter;
  final Function(String?) onFilterApplied;
  final int totalQuestions;
  final List<int> attemptedQuestions; // List of 1-based question numbers

  const FilterBottomSheet({
    super.key,
    this.initialFilter,
    required this.onFilterApplied,
    required this.totalQuestions,
    required this.attemptedQuestions,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedFilter;
  List<int> _selectedQuestions = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    // Parse initial filter if it's in "Questions: 1,2,3" format
    if (_selectedFilter != null && _selectedFilter!.startsWith('Questions:')) {
      _selectedQuestions = _selectedFilter!
          .substring('Questions:'.length)
          .split(',')
          .map((num) => int.tryParse(num.trim()) ?? 0)
          .where((num) => num > 0)
          .toList();
      // Ensure only one question is selected (take the first one if multiple)
      if (_selectedQuestions.length > 1) {
        _selectedQuestions = [_selectedQuestions.first];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFDADADA),
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Attempted and Unattempted labels with dots
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text('Attempted'),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text('Unattempted'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: widget.totalQuestions,
                itemBuilder: (context, index) {
                  final questionNumber = index + 1;
                  final isSelected =
                      _selectedQuestions.contains(questionNumber);
                  final isAttempted =
                      widget.attemptedQuestions.contains(questionNumber);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Clear previous selections and select only the tapped question
                        _selectedQuestions.clear();
                        _selectedQuestions.add(questionNumber);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : isAttempted
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          questionNumber.toString(),
                          style: TextStyle(
                            color: isSelected || isAttempted
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x14000000),
                  offset: const Offset(0, -5),
                  blurRadius: 8.7,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedQuestions.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.textColor!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Clear Filter',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          String? filterResult;
                          if (_selectedQuestions.isNotEmpty) {
                            _selectedQuestions
                                .sort(); // Sort for consistency (though only one item)
                            filterResult =
                                'Questions: ${_selectedQuestions.join(",")}';
                          }
                          widget.onFilterApplied(filterResult);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final HomeLoaded state;
  const FilterBottomSheet({super.key, required this.state});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late RangeValues _priceRange;
  late double _radius;
  late String? _sort;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.state.selectedCategory;
    _priceRange = RangeValues(
      widget.state.minPrice ?? 0,
      widget.state.maxPrice ?? 500,
    );
    _radius = widget.state.radius ?? 50;
    _sort = widget.state.sort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _priceRange = const RangeValues(0, 500);
                    _radius = 50;
                    _sort = null;
                  });
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.state.categories.length + 1,
              itemBuilder: (context, index) {
                final cat = index == 0 ? 'All' : widget.state.categories[index - 1];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: const Color(0xFF14B8A6).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF14B8A6),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            divisions: 20,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            activeColor: const Color(0xFF14B8A6),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 24),

          // Radius
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search Radius',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_radius.round()} km',
                style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _radius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_radius.round()} km',
            activeColor: const Color(0xFF14B8A6),
            onChanged: (value) {
              setState(() {
                _radius = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Sort By
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              _SortChip(
                label: 'Distance',
                value: 'distance',
                groupValue: _sort,
                onSelected: (val) => setState(() => _sort = val),
              ),
              _SortChip(
                label: 'Price',
                value: 'price',
                groupValue: _sort,
                onSelected: (val) => setState(() => _sort = val),
              ),
              _SortChip(
                label: 'Rating',
                value: 'rating',
                groupValue: _sort,
                onSelected: (val) => setState(() => _sort = val),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(ApplyFilters(
                  category: _selectedCategory,
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  radius: _radius,
                  sort: _sort,
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final Function(String?) onSelected;

  const _SortChip({
    required this.label,
    required this.value,
    this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        onSelected(selected ? value : null);
      },
      selectedColor: const Color(0xFF14B8A6).withOpacity(0.2),
      checkmarkColor: const Color(0xFF14B8A6),
    );
  }
}

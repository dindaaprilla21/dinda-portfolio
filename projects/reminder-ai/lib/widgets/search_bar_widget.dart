import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onCategoryFilter;
  final Function(int?)? onPriorityFilter;
  final VoidCallback? onClearFilters;

  const SearchBarWidget({
    super.key,
    this.onSearch,
    this.onCategoryFilter,
    this.onPriorityFilter,
    this.onClearFilters,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  String _selectedCategory = 'all';
  int? _selectedPriority;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'all', 'label': 'Semua', 'icon': Icons.apps},
    {'value': 'akademik', 'label': 'Akademik', 'icon': Icons.school},
    {'value': 'personal', 'label': 'Personal', 'icon': Icons.person},
    {'value': 'kerja', 'label': 'Kerja', 'icon': Icons.work},
    {'value': 'kesehatan', 'label': 'Kesehatan', 'icon': Icons.favorite},
    {'value': 'lainnya', 'label': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': null, 'label': 'Semua'},
    {'value': 3, 'label': 'Tinggi'},
    {'value': 2, 'label': 'Sedang'},
    {'value': 1, 'label': 'Rendah'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
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
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari tugas...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    onChanged: (value) {
                      widget.onSearch?.call(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                  icon: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.tune),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Filters Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFiltersSection(),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          
          // Category Filter
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['value'];
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'],
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(category['label']),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category['value'];
                  });
                  widget.onCategoryFilter?.call(
                    _selectedCategory == 'all' ? '' : _selectedCategory,
                  );
                },
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Priority Filter
          const Text(
            'Prioritas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _priorities.map((priority) {
              final isSelected = _selectedPriority == priority['value'];
              return FilterChip(
                label: Text(priority['label']),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? priority['value'] : null;
                  });
                  widget.onPriorityFilter?.call(_selectedPriority);
                },
                selectedColor: _selectedPriority != null
                    ? AppTheme.getPriorityColor(_selectedPriority!)
                    : AppTheme.primaryColor,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = 'all';
                  _selectedPriority = null;
                });
                widget.onSearch?.call('');
                widget.onCategoryFilter?.call('');
                widget.onPriorityFilter?.call(null);
                widget.onClearFilters?.call();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
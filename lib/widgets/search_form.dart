import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  final List? categories;
  final Function(String?, Map?)? onChange;

  const SearchForm({
    super.key,
    this.categories,
    this.onChange,
  });

  @override
  State<SearchForm> createState() => _SearchFormState();
}


class _SearchFormState extends State<SearchForm> {
  Map<dynamic, bool> categories = {};
  String query = "";

  void _onSearchChange(String? query, Map? categories) {
    widget.onChange?.call(query, categories);
  }

  @override
  void initState() {
    super.initState();
    for (var category in widget.categories ?? []) {
      categories[category] = true;
    }
    // categories = Map.fromIterable(widget.categories ?? [], key: (value) => value, value: (_) => true);
  }

  bool _isFilterOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Search anything...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) => {
                      query = value,
                      _onSearchChange(value, categories),
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFilterOpen ? Icons.close : Icons.filter_list,
                    color: _isFilterOpen ? Colors.redAccent : Colors.blueAccent,
                  ),
                  onPressed: () => setState(() => _isFilterOpen = !_isFilterOpen),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Collapsible Filter Section
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  for (var category in widget.categories ?? [])
                    FilterChip(
                      label: Text(category),
                      selected: categories[category] ?? false,
                      onSelected: (bool value) {
                        setState(() {
                          categories[category] = value;
                          _onSearchChange(query, categories);
                        });
                      },
                      selectedColor: Colors.blueAccent.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blueAccent,
                    ),
                ],
              ),
            ),
            crossFadeState: _isFilterOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  double _minPrice = 10;
  double _maxPrice = 100;
  double _rating = 0;

  String _selectedBrand = "All";
  String _selectedCategory = "All";

  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  final List<String> _brands = ["All", "Nike", "Adidas", "Puma"];
  final List<String> _categories = ["All", "Giày", "Áo", "Quần"];

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(text: _minPrice.toStringAsFixed(0));
    _maxController = TextEditingController(text: _maxPrice.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Widget _buildChoiceChip({
    required String label,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final bool isSelected = selectedValue == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? const Color.fromARGB(255, 238, 240, 141)
                  : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelected(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 216, 235, 243),
      child: SafeArea(
        top: false,
        left: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Tiêu đề ---
                const Text(
                  "Bộ lọc",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // --- Theo thương hiệu ---
                const Text(
                  "Thương hiệu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      _brands
                          .map(
                            (brand) => _buildChoiceChip(
                              label: brand,
                              selectedValue: _selectedBrand,
                              onSelected:
                                  (value) =>
                                      setState(() => _selectedBrand = value),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 20),

                // --- Theo loại sản phẩm ---
                const Text(
                  "Loại sản phẩm",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      _categories
                          .map(
                            (cat) => _buildChoiceChip(
                              label: cat,
                              selectedValue: _selectedCategory,
                              onSelected:
                                  (value) =>
                                      setState(() => _selectedCategory = value),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 20),

                // --- Khoảng giá ---
                const Text(
                  "Khoảng giá",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 200,
                  divisions: 20,
                  labels: RangeLabels(
                    '${_minPrice.round()}k',
                    '${_maxPrice.round()}k',
                  ),
                  activeColor: Colors.blueAccent,
                  onChanged: (values) {
                    setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                      _minController.text = _minPrice.toStringAsFixed(0);
                      _maxController.text = _maxPrice.toStringAsFixed(0);
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tối thiểu',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          final val = double.tryParse(value);
                          if (val != null && val <= _maxPrice) {
                            setState(() => _minPrice = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tối đa',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          final val = double.tryParse(value);
                          if (val != null && val >= _minPrice) {
                            setState(() => _maxPrice = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Phần chọn sao ---
                const Text(
                  "Đánh giá",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final ratingValue = 5 - index; // 5 → 1
                    final isSelected = _rating == ratingValue.toDouble();

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = ratingValue.toDouble();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ratingValue == 5 ? '5' : '≥$ratingValue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected ? Colors.blue : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // --- Nút hành động ---
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context, {
                            'brand': _selectedBrand,
                            'category': _selectedCategory,
                            'minPrice': _minPrice,
                            'maxPrice': _maxPrice,
                            'rating': _rating,
                          });
                        },
                        child: const Text(
                          "Áp dụng",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedBrand = "All";
                            _selectedCategory = "All";
                            _minPrice = 10;
                            _maxPrice = 100;
                            _rating = 0;
                            _minController.text = _minPrice.toStringAsFixed(0);
                            _maxController.text = _maxPrice.toStringAsFixed(0);
                          });
                        },
                        child: const Text(
                          "Xóa lọc",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

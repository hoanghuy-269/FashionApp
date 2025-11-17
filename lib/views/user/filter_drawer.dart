import 'package:fashion_app/views/user/category.dart';
import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const FilterDrawer({super.key, this.initialFilters = const {}});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  double _minPrice = 10;
  double _maxPrice = 10000000.0;
  double _rating = 0;

  String _selectedBrand = "All";
  String _selectedCategory = "All";

  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  // Cache data để tránh load lại
  List<Map<String, dynamic>> _cachedBrands = [];
  List<Map<String, dynamic>> _cachedCategories = [];
  final CategoriesRepository _categoriesRepo = CategoriesRepository();
  final BrandsRepository _brandsRepo = BrandsRepository();

  bool _brandsLoaded = false;
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeFromFilters();
    _minController = TextEditingController(text: _minPrice.toStringAsFixed(0));
    _maxController = TextEditingController(text: _maxPrice.toStringAsFixed(0));

    // Load data một lần duy nhất
    _loadBrands();
    _loadCategories();
  }

  void _initializeFromFilters() {
    _minPrice = (widget.initialFilters['minPrice'] as double?) ?? 0.0;
    _maxPrice = (widget.initialFilters['maxPrice'] as double?) ?? 10000000.0;
    _rating = (widget.initialFilters['rating'] as double?) ?? 0.0;
    _selectedBrand = (widget.initialFilters['brand'] as String?) ?? "All";
    _selectedCategory = (widget.initialFilters['category'] as String?) ?? "All";
  }

  void _loadBrands() {
    _brandsRepo.getBrands().first.then((brands) {
      if (mounted) {
        setState(() {
          _cachedBrands = brands;
          _brandsLoaded = true;
        });
      }
    });
  }

  void _loadCategories() {
    _categoriesRepo.getCategories().first.then((categories) {
      if (mounted) {
        setState(() {
          _cachedCategories = categories;
          _categoriesLoaded = true;
        });
      }
    });
  }

  Widget _buildChoiceChip({
    required String label,
    required String value,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final bool isSelected = selectedValue == value;
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
      onSelected: (_) => onSelected(value),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
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
                _buildBrandsSection(),

                const SizedBox(height: 20),

                // --- Theo loại sản phẩm ---
                const Text(
                  "Loại sản phẩm",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildCategoriesSection(),

                const SizedBox(height: 20),

                // --- Khoảng giá ---
                _buildPriceSection(),

                const SizedBox(height: 30),

                // --- Đánh giá ---
                _buildRatingSection(),

                const SizedBox(height: 30),

                // --- Nút hành động ---
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsSection() {
    if (!_brandsLoaded) {
      return const CircularProgressIndicator();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildChoiceChip(
          label: "All",
          value: "All",
          selectedValue: _selectedBrand,
          onSelected: (value) => setState(() => _selectedBrand = value),
        ),
        ..._cachedBrands.map(
          (brand) => _buildChoiceChip(
            label: brand['name'] ?? 'Unknown',
            value: brand['brandID'] ?? brand['id'],
            selectedValue: _selectedBrand,
            onSelected: (value) => setState(() => _selectedBrand = value),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    if (!_categoriesLoaded) {
      return const CircularProgressIndicator();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildChoiceChip(
          label: "All",
          value: "All",
          selectedValue: _selectedCategory,
          onSelected: (value) => setState(() => _selectedCategory = value),
        ),
        ..._cachedCategories.map(
          (category) => _buildChoiceChip(
            label: category['categoryName'] ?? 'Unknown',
            value: category['categoryID'] ?? category['id'],
            selectedValue: _selectedCategory,
            onSelected: (value) => setState(() => _selectedCategory = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Khoảng giá",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 10000000.0,
          divisions: 20,
          labels: RangeLabels('${_minPrice.round()}k', '${_maxPrice.round()}k'),
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
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Đánh giá",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final ratingValue = 5 - index;
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
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
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
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
                _minPrice = 0.0;
                _maxPrice = 10000000.0;
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
    );
  }
}

import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Form Controllers
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _storyController = TextEditingController();

  // State Variables
  String _selectedCategory = 'Vegetables';
  String _selectedUnitType = 'per lb';
  bool _isAvailableForPickup = true;
  bool _isCertifiedOrganic = false;

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Herbs & Spices',
    'Dairy & Eggs',
    'Grains'
  ];

  final List<String> _unitTypes = [
    'per lb',
    'per kg',
    'per crate',
    'per bunch',
    'per item'
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Submit Form Logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'List Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Photo Header & Upload Card
            const Text(
              'PRODUCT PHOTO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF616161),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _buildPhotoUploadCard(),
            const SizedBox(height: 20),

            // Product Name Field
            _buildFieldLabel('Product Name'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _productNameController,
              hintText: 'e.g. Heirloom Tomatoes',
            ),
            const SizedBox(height: 16),

            // Category Field
            _buildFieldLabel('Category'),
            const SizedBox(height: 6),
            _buildDropdownField(
              value: _selectedCategory,
              items: _categories,
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // Price & Unit Type Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Price per unit'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _priceController,
                        hintText: '\$ 0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Unit Type'),
                      const SizedBox(height: 6),
                      _buildDropdownField(
                        value: _selectedUnitType,
                        items: _unitTypes,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnitType = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Initial Stock Level Field
            _buildFieldLabel('Initial Stock Level'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _stockController,
              hintText: 'Enter quantity',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Product Story & Quality Notes Field
            _buildFieldLabel('Product Story & Quality Notes'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _storyController,
              hintText: 'Describe the flavor, harvest date, or special qualities...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),

            // Toggle 1: Available for Pickup
            _buildSwitchTile(
              title: 'Available for Pickup',
              subtitle: 'Allow restaurants to collect directly',
              value: _isAvailableForPickup,
              onChanged: (val) => setState(() => _isAvailableForPickup = val),
            ),
            const SizedBox(height: 12),

            // Toggle 2: Certified Organic
            _buildSwitchTile(
              title: 'Certified Organic',
              subtitle: 'Displays organic badge to buyers',
              value: _isCertifiedOrganic,
              onChanged: (val) => setState(() => _isCertifiedOrganic = val),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Label Widget Helper
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
    );
  }

  // Text Input Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
      ),
    );
  }

  // Dropdown Field Builder
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Switch Tile Builder
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF2E7D32),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }

  // Dashed Photo Upload Box
  Widget _buildPhotoUploadCard() {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        height: 180,
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            // Add image picker logic
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.add_a_photo_outlined,
                size: 36,
                color: Color(0xFF2E7D32),
              ),
              SizedBox(height: 8),
              Text(
                'Tap to upload product photo',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter for exact Dashed Border Box around Photo Upload
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);
    final Path metricsPath = Path();

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = (distance + dashWidth < pathMetric.length)
            ? dashWidth
            : pathMetric.length - distance;
        metricsPath.addPath(
          pathMetric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(metricsPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
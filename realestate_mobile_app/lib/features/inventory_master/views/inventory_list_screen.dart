import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models/inventory_entity.dart';
import 'add_edit_inventory_dialog.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  String _selectedStatusFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryEntity> _getFilteredInventories() {
    var list = AppDatabase.instance.getAllInventories();

    if (_selectedStatusFilter != 'ALL') {
      list = list.where((i) => i.status == _selectedStatusFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) =>
        i.projectName.toLowerCase().contains(q) ||
        i.unitNumber.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.unitType.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else {
      return '₹${(price / 100000).toStringAsFixed(0)} Lakh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventories = _getFilteredInventories();
    final all = AppDatabase.instance.getAllInventories();
    final totalValue = all.fold<double>(0, (sum, item) => sum + item.askingPriceInr);

    return Scaffold(
      body: Column(
        children: [
          // Search & Summary Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by project, society, or unit #...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Total Value Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C81).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${all.length} Units in Master',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                ),
                Text(
                  'Total Master Value: ${_formatPrice(totalValue)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                ),
              ],
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildStatusChip('ALL', 'All Units', all.length, Colors.blueGrey),
                _buildStatusChip('AVAILABLE', 'Available', all.where((i) => i.status == 'AVAILABLE').length, Colors.green),
                _buildStatusChip('BLOCKED', 'Blocked / Token', all.where((i) => i.status == 'BLOCKED').length, Colors.amber.shade800),
                _buildStatusChip('SOLD', 'Sold Out', all.where((i) => i.status == 'SOLD').length, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Inventories List
          Expanded(
            child: inventories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No inventory items found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: inventories.length,
                    itemBuilder: (ctx, index) {
                      final item = inventories[index];
                      return _buildInventoryCard(item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditInventoryDialog.show(context, onSaved: () {
            setState(() {});
          });
        },
        backgroundColor: const Color(0xFF0F4C81),
        icon: const Icon(Icons.add_home_work, color: Colors.white),
        label: const Text('Add Inventory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusChip(String key, String label, int count, Color color) {
    final isSelected = _selectedStatusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : color.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        onSelected: (_) => setState(() => _selectedStatusFilter = key),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryEntity item) {
    Color statusColor = Colors.green;
    String statusText = 'Available';

    if (item.status == 'BLOCKED') {
      statusColor = Colors.amber.shade800;
      statusText = 'Blocked / Token';
    } else if (item.status == 'SOLD') {
      statusColor = Colors.red;
      statusText = 'Sold';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Project Name + Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.projectName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.unitNumber,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price & Area & Location
            Row(
              children: [
                Text(
                  _formatPrice(item.askingPriceInr),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F4C81)),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Text(
                  '${item.superAreaSqft.toStringAsFixed(0)} sqft (${item.unitType})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),

            // Custom Dynamic Specs Chips
            if (item.customSpecs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.customSpecs.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Card Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added ${DateTime.now().difference(item.createdAt).inDays}d ago',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Story link generated for ${item.projectName} - ${item.unitNumber} (Ready to WhatsApp!)'),
                            backgroundColor: const Color(0xFF0F4C81),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share, size: 15),
                      label: const Text('Story Link', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        AddEditInventoryDialog.show(
                          context,
                          item: item,
                          onSaved: () => setState(() {}),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 15),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

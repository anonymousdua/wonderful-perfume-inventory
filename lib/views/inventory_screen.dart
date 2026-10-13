import 'package:flutter/material.dart';

import '../models/perfume.dart';
import '../routes/route_generator.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/inventory_viewmodel.dart';
import 'widgets/common.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryViewModel _vm;

  static const _flexes = [3, 3, 3, 2, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _vm = InventoryViewModel(SupabaseService())..addListener(_onChanged);
    _vm.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    super.dispose();
  }

  Future<void> _addStock(Perfume p) async {
    final controller = TextEditingController();
    final qty = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add stock', style: AppTheme.heading(22)),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.name} · ${p.size}  (currently ${p.units})'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Units to add'),
                onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('Add stock'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (qty == null || !mounted) return;
    final err = await _vm.addStock(p, qty);
    if (!mounted) return;
    showMessage(context, err ?? 'Added $qty unit(s) to ${p.name}.', error: err != null);
  }

  Future<void> _edit(Perfume p) async {
    final name = TextEditingController(text: p.name);
    final brand = TextEditingController(text: p.brand);
    final size = TextEditingController(text: p.size);
    final reorder = TextEditingController(text: p.reorderLevel.toString());
    String category = InventoryViewModel.categories.contains(p.category)
        ? p.category
        : InventoryViewModel.categories.first;

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Edit perfume', style: AppTheme.heading(22)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Perfume name')),
                  const SizedBox(height: 12),
                  TextField(controller: brand, decoration: const InputDecoration(labelText: 'Brand')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final c in InventoryViewModel.categories)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setLocal(() => category = v ?? category),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: size, decoration: const InputDecoration(labelText: 'Bottle size')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reorder,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reorder level'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    final values = (
      name: name.text,
      brand: brand.text,
      size: size.text,
      reorder: int.tryParse(reorder.text) ?? p.reorderLevel,
    );
    name.dispose();
    brand.dispose();
    size.dispose();
    reorder.dispose();
    if (save != true || !mounted) return;

    final err = await _vm.updatePerfume(
      perfume: p,
      name: values.name,
      brand: values.brand,
      category: category,
      size: values.size,
      reorderLevel: values.reorder,
    );
    if (!mounted) return;
    showMessage(context, err ?? 'Saved ${values.name}.', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _vm.visible;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(64, 40, 64, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            eyebrow: 'Wonderful Perfumes · Operations',
            title: 'Inventory',
            action: FilledButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed(RouteGenerator.addPerfume),
              icon: const Icon(Icons.add),
              label: const Text('Add perfume'),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: StatCard(label: 'Perfume types', value: '${_vm.perfumeTypes}')),
              const SizedBox(width: 20),
              Expanded(child: StatCard(label: 'Total units', value: '${_vm.totalUnits}')),
              const SizedBox(width: 20),
              Expanded(child: StatCard(label: 'Need attention', value: '${_vm.needAttention}')),
            ],
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: LabeledField(
                        label: 'Search inventory',
                        child: TextField(onChanged: _vm.setSearch),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: LabeledField(
                        label: 'Category',
                        child: DropdownButtonFormField<String>(
                          initialValue: _vm.category,
                          items: [
                            for (final c in ['All categories', ...InventoryViewModel.categories])
                              DropdownMenuItem(value: c, child: Text(c)),
                          ],
                          onChanged: (v) => _vm.setCategory(v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: LabeledField(
                        label: 'Stock status',
                        child: DropdownButtonFormField<String>(
                          initialValue: _vm.stockFilter,
                          items: [
                            for (final s in ['All stock levels', ...InventoryViewModel.stockLevels])
                              DropdownMenuItem(value: s, child: Text(s)),
                          ],
                          onChanged: (v) => _vm.setStockFilter(v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TableHeaderRow(
                  flexes: _flexes,
                  cells: [
                    _sortHeader('Perfume', InventorySort.name),
                    headerText('Brand'),
                    headerText('Category'),
                    headerText('Size'),
                    _sortHeader('Units', InventorySort.units),
                    headerText('Status'),
                    headerText('Actions'),
                  ],
                ),
                if (_vm.loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_vm.error != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_vm.error!, style: const TextStyle(color: AppColors.red)),
                  )
                else if (rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No perfumes match your filters.')),
                  )
                else
                  for (final p in rows) _row(p),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortHeader(String label, InventorySort column) {
    final active = _vm.sortBy == column;
    return InkWell(
      onTap: () => _vm.toggleSort(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          headerText(label),
          const SizedBox(width: 4),
          Icon(
            active
                ? (_vm.ascending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 14,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _row(Perfume p) {
    return TableBodyRow(
      flexes: _flexes,
      cells: [
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(p.brand),
        Text(p.category),
        Text(p.size),
        Text('${p.units}', style: const TextStyle(fontWeight: FontWeight.w700)),
        Align(alignment: Alignment.centerLeft, child: _statusChip(p.status)),
        Row(
          children: [
            OutlinedButton(onPressed: () => _addStock(p), child: const Text('Add stock')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _edit(p), child: const Text('Edit')),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(StockStatus s) {
    switch (s) {
      case StockStatus.inStock:
        return const StatusChip(label: 'In Stock', fg: AppColors.green, bg: AppColors.greenBg);
      case StockStatus.lowStock:
        return const StatusChip(label: 'Low Stock', fg: AppColors.amber, bg: AppColors.amberBg);
      case StockStatus.outOfStock:
        return const StatusChip(label: 'Out of Stock', fg: AppColors.red, bg: AppColors.redBg);
    }
  }
}

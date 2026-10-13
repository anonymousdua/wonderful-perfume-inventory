import 'package:flutter/material.dart';

import '../models/perfume.dart';
import '../models/seller.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/sales_viewmodel.dart';
import 'widgets/common.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late final SalesViewModel _vm;
  final _qty = TextEditingController();

  bool _showForm = false;
  Perfume? _perfume;
  Seller? _seller;
  String _payment = SalesViewModel.paymentMethods.first;

  static const _flexes = [2, 2, 3, 3, 1, 2, 2];

  @override
  void initState() {
    super.initState();
    _vm = SalesViewModel(SupabaseService())..addListener(_onChanged);
    _vm.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _qty.clear();
    });
  }

  Future<void> _confirmSale() async {
    final err = await _vm.sell(
      perfume: _perfume,
      seller: _seller,
      quantity: int.tryParse(_qty.text.trim()) ?? 0,
      paymentMethod: _payment,
    );
    if (!mounted) return;
    if (err != null) {
      showMessage(context, err, error: true);
      return;
    }
    showMessage(context, 'Sale recorded.');
    _perfume = null;
    _closeForm();
  }

  @override
  Widget build(BuildContext context) {
    final sellable = _vm.sellablePerfumes;
    // Keep selections valid after reloads.
    _perfume = sellable.where((p) => p.id == _perfume?.id).firstOrNull ??
        (sellable.isNotEmpty ? sellable.first : null);
    _seller = _vm.sellers.where((s) => s.id == _seller?.id).firstOrNull ??
        (_vm.sellers.isNotEmpty ? _vm.sellers.first : null);

    final rows = _vm.visible;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(64, 40, 64, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(eyebrow: 'Wonderful Perfumes · Sales ledger', title: 'Sales'),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Sell from Inventory'),
            ),
          ),
          if (_showForm) ...[
            const SizedBox(height: 24),
            _sellForm(sellable),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: StatCard(label: 'Units sold', value: '${_vm.unitsSold}')),
              const SizedBox(width: 20),
              Expanded(child: StatCard(label: 'Completed orders', value: '${_vm.completedOrders}')),
              const SizedBox(width: 20),
              Expanded(child: StatCard(label: "Today's orders", value: '${_vm.todaysOrders}')),
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
                      flex: 4,
                      child: LabeledField(
                        label: 'Search sales',
                        child: TextField(onChanged: _vm.setSearch),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: LabeledField(
                        label: 'Date range',
                        child: DropdownButtonFormField<DateRangeFilter>(
                          initialValue: _vm.range,
                          items: const [
                            DropdownMenuItem(value: DateRangeFilter.all, child: Text('All dates')),
                            DropdownMenuItem(value: DateRangeFilter.today, child: Text('Today')),
                            DropdownMenuItem(value: DateRangeFilter.week, child: Text('Last 7 days')),
                          ],
                          onChanged: (v) => _vm.setRange(v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: LabeledField(
                        label: 'Order status',
                        child: DropdownButtonFormField<String>(
                          initialValue: _vm.statusFilter,
                          items: [
                            for (final s in ['All statuses', ...SalesViewModel.statuses])
                              DropdownMenuItem(value: s, child: Text(s)),
                          ],
                          onChanged: (v) => _vm.setStatus(v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TableHeaderRow(
                  flexes: _flexes,
                  cells: [
                    headerText('Sale ID'),
                    headerText('Date'),
                    headerText('Perfume'),
                    headerText('Seller'),
                    headerText('Qty'),
                    headerText('Payment'),
                    headerText('Status'),
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
                    child: Center(child: Text('No sales found.')),
                  )
                else
                  for (final s in rows)
                    TableBodyRow(
                      flexes: _flexes,
                      cells: [
                        Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(s.dateLabel),
                        Text(s.perfumeName),
                        Text(s.sellerName),
                        Text('${s.quantity}'),
                        Text(s.paymentMethod),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const StatusChip(
                            label: 'Completed',
                            fg: AppColors.green,
                            bg: AppColors.greenBg,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellForm(List<Perfume> sellable) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Sell from Inventory', style: AppTheme.heading(24))),
              IconButton(onPressed: _closeForm, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Perfume',
                  hint: _perfume == null ? 'No perfumes in stock' : 'Available: ${_perfume!.units}',
                  child: DropdownButtonFormField<String>(
                    initialValue: _perfume?.id,
                    items: [
                      for (final p in sellable)
                        DropdownMenuItem(value: p.id, child: Text('${p.name} · ${p.size}')),
                    ],
                    onChanged: (id) =>
                        setState(() => _perfume = sellable.firstWhere((p) => p.id == id)),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: LabeledField(
                  label: 'Quantity',
                  child: TextField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: LabeledField(
                  label: 'Seller',
                  hint: _vm.sellers.isEmpty ? 'Add a seller first' : null,
                  child: DropdownButtonFormField<String>(
                    initialValue: _seller?.id,
                    items: [
                      for (final s in _vm.sellers)
                        DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ],
                    onChanged: (id) =>
                        setState(() => _seller = _vm.sellers.firstWhere((s) => s.id == id)),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: LabeledField(
                  label: 'Payment method',
                  child: DropdownButtonFormField<String>(
                    initialValue: _payment,
                    items: [
                      for (final m in SalesViewModel.paymentMethods)
                        DropdownMenuItem(value: m, child: Text(m)),
                    ],
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              FilledButton(onPressed: _confirmSale, child: const Text('Confirm sale')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _closeForm, child: const Text('Cancel')),
            ],
          ),
        ],
      ),
    );
  }
}

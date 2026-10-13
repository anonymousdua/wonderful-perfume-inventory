import 'package:flutter/material.dart';

import '../routes/route_generator.dart';
import '../services/supabase_service.dart';
import '../viewmodels/add_perfume_viewmodel.dart';
import 'widgets/common.dart';

class AddPerfumeScreen extends StatefulWidget {
  const AddPerfumeScreen({super.key});

  @override
  State<AddPerfumeScreen> createState() => _AddPerfumeScreenState();
}

class _AddPerfumeScreenState extends State<AddPerfumeScreen> {
  late final AddPerfumeViewModel _vm;

  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _size = TextEditingController();
  final _quantity = TextEditingController();
  final _reorder = TextEditingController();
  final _notes = TextEditingController();
  String? _category;
  int _formKey = 0; // bumped to reset the dropdown

  @override
  void initState() {
    super.initState();
    _vm = AddPerfumeViewModel(SupabaseService())..addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    for (final c in [_name, _brand, _size, _quantity, _reorder, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clear() {
    for (final c in [_name, _brand, _size, _quantity, _reorder, _notes]) {
      c.clear();
    }
    setState(() {
      _category = null;
      _formKey++;
    });
  }

  Future<void> _save() async {
    final err = await _vm.save(
      name: _name.text,
      brand: _brand.text,
      category: _category,
      size: _size.text,
      quantity: _quantity.text.trim().isEmpty ? '0' : _quantity.text,
      reorderLevel: _reorder.text,
      notes: _notes.text,
    );
    if (!mounted) return;
    if (err != null) {
      showMessage(context, err, error: true);
      return;
    }
    showMessage(context, 'Perfume added to inventory.');
    Navigator.of(context).pushReplacementNamed(RouteGenerator.inventory);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(64, 40, 64, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'Wonderful Perfumes · Stock intake',
            title: 'Add Perfume to Inventory',
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledField(label: 'Perfume name', child: TextField(controller: _name)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: LabeledField(label: 'Brand', child: TextField(controller: _brand)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: LabeledField(
                        label: 'Category',
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_formKey),
                          initialValue: _category,
                          hint: const Text('Choose category'),
                          items: [
                            for (final c in AddPerfumeViewModel.categories)
                              DropdownMenuItem(value: c, child: Text(c)),
                          ],
                          onChanged: (v) => setState(() => _category = v),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'Bottle size',
                        child: TextField(
                          controller: _size,
                          decoration: const InputDecoration(hintText: 'e.g. 100 ml'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: LabeledField(
                        label: 'Initial quantity',
                        child: TextField(controller: _quantity, keyboardType: TextInputType.number),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: LabeledField(
                        label: 'Reorder level',
                        hint: 'Defaults to 5 if left blank',
                        child: TextField(controller: _reorder, keyboardType: TextInputType.number),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LabeledField(
                  label: 'Notes (optional)',
                  child: TextField(controller: _notes, maxLines: 4),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    FilledButton(
                      onPressed: _vm.saving ? null : _save,
                      child: Text(_vm.saving ? 'Saving…' : 'Add to Inventory'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: _clear, child: const Text('Cancel')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

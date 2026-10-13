import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/seller_viewmodel.dart';
import 'widgets/common.dart';

class AddSellerScreen extends StatefulWidget {
  const AddSellerScreen({super.key});

  @override
  State<AddSellerScreen> createState() => _AddSellerScreenState();
}

class _AddSellerScreenState extends State<AddSellerScreen> {
  late final SellerViewModel _vm;
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = SellerViewModel(SupabaseService())..addListener(_onChanged);
    _vm.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _clear() {
    _name.clear();
    _email.clear();
  }

  Future<void> _save() async {
    final err = await _vm.save(name: _name.text, email: _email.text);
    if (!mounted) return;
    if (err != null) {
      showMessage(context, err, error: true);
      return;
    }
    showMessage(context, 'Seller saved.');
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(64, 40, 64, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(eyebrow: 'Wonderful Perfumes · Team', title: 'Add New Seller'),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledField(
                        label: 'Seller name',
                        child: TextField(controller: _name),
                      ),
                      const SizedBox(height: 24),
                      LabeledField(
                        label: 'Email address (optional)',
                        child: TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: _vm.saving ? null : _save,
                            child: Text(_vm.saving ? 'Saving…' : 'Save Seller'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(onPressed: _clear, child: const Text('Cancel')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                flex: 2,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent sellers', style: AppTheme.heading(24)),
                      const SizedBox(height: 12),
                      if (_vm.loading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_vm.recent.isEmpty)
                        const Text('No sellers yet.')
                      else
                        for (final s in _vm.recent)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.border)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                if (s.email != null)
                                  Text(s.email!,
                                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

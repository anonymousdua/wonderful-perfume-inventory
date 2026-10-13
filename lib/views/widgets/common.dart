import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.action,
  });

  final String eyebrow;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(title, style: AppTheme.heading(34)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0F2E1228), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTheme.heading(36)),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

/// Label above a form control.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ],
    );
  }
}

/// Table header cell / body helpers share the same flex layout.
class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({super.key, required this.cells, required this.flexes});

  final List<Widget> cells;
  final List<int> flexes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(flex: flexes[i], child: cells[i]),
        ],
      ),
    );
  }
}

class TableBodyRow extends StatelessWidget {
  const TableBodyRow({super.key, required this.cells, required this.flexes});

  final List<Widget> cells;
  final List<int> flexes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(flex: flexes[i], child: cells[i]),
        ],
      ),
    );
  }
}

Text headerText(String s) => Text(
      s.toUpperCase(),
      style: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        fontSize: 12,
      ),
    );

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.red : AppColors.plum,
      behavior: SnackBarBehavior.floating,
    ));
}

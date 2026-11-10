import 'package:flutter/material.dart';

import '../common/format.dart';
import '../theme/palette.dart';

/// A labelled date button: opens the date picker; × clears it.
class DateChip extends StatelessWidget {
  const DateChip({super.key, required this.label, required this.date, required this.onChanged});
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(DateTime.utc(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _pick(context),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          decoration: BoxDecoration(
            color: date == null ? p.text.withValues(alpha: .05) : p.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_rounded, size: 14, color: date == null ? p.textSecondary : p.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  date == null ? label : '$label · ${shortDate(date!)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: date == null ? p.textSecondary : p.text,
                  ),
                ),
              ),
              if (date != null)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.close_rounded, size: 14, color: p.textSecondary),
                  ),
                )
              else
                const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

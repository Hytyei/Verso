import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../common/glass_menu.dart';
import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Palette swatches (theme-mapped slots), optional "None", and a custom
/// HSV picker with a hex field.
class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key, required this.value, required this.onChanged, this.allowNone = false});
  final VColor? value;
  final ValueChanged<VColor?> onChanged;
  final bool allowNone;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late bool _custom = widget.value?.custom ?? false;
  late HSVColor _hsv = HSVColor.fromColor(
    widget.value?.custom == true ? Color(widget.value!.value) : const Color(0xFF3B82D6),
  );
  late final _hex = TextEditingController(text: _hexOf(_hsv.toColor()));

  static String _hexOf(Color c) => (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _emitCustom(HSVColor hsv, {bool updateHex = true}) {
    setState(() => _hsv = hsv);
    if (updateHex) _hex.text = _hexOf(hsv.toColor());
    widget.onChanged(VColor(hsv.toColor().toARGB32(), custom: true));
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final v = widget.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.allowNone)
              _Swatch(
                color: Colors.transparent,
                selected: v == null,
                none: true,
                onTap: () {
                  setState(() => _custom = false);
                  widget.onChanged(null);
                },
              ),
            for (var i = 0; i < 4; i++)
              _Swatch(
                key: Key('swatch-$i'),
                color: p.accents[i],
                selected: v != null && !v.custom && v.value == i,
                onTap: () {
                  setState(() => _custom = false);
                  widget.onChanged(VColor.slot(i));
                },
              ),
            GestureDetector(
              onTap: () {
                setState(() => _custom = !_custom);
                if (_custom) _emitCustom(_hsv);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _custom ? p.primary.withValues(alpha: .14) : p.text.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Custom',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _custom ? p.primary : p.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: Motion.dur(context),
          curve: Curves.easeOutCubic,
          child: !_custom
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SvSquare(hsv: _hsv, onChanged: _emitCustom),
                      const SizedBox(height: 10),
                      _HueSlider(hsv: _hsv, onChanged: _emitCustom),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: _hsv.toColor(), borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#',
                            style: TextStyle(fontFamily: 'Inter', color: p.textSecondary),
                          ),
                          Expanded(
                            child: TextField(
                              key: const Key('hex-field'),
                              controller: _hex,
                              maxLength: 6,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
                              decoration: const InputDecoration(
                                isDense: true,
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (s) {
                                final n = int.tryParse(s.trim(), radix: 16);
                                if (n != null && s.trim().length == 6) {
                                  _emitCustom(HSVColor.fromColor(Color(0xFF000000 | n)), updateHex: false);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({super.key, required this.color, required this.selected, required this.onTap, this.none = false});
  final Color color;
  final bool selected;
  final bool none;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Motion.smoothDur(context),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? p.text : (none ? p.separator : Colors.transparent),
              width: selected ? 2.2 : 1.2,
            ),
          ),
          child: none ? Icon(Icons.block_rounded, size: 14, color: p.textSecondary) : null,
        ),
      ),
    );
  }
}

class _SvSquare extends StatelessWidget {
  const _SvSquare({required this.hsv, required this.onChanged});
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = 120.0;
        void set(Offset o) =>
            onChanged(hsv.withSaturation((o.dx / w).clamp(0, 1)).withValue(1 - (o.dy / h).clamp(0, 1)));
        return GestureDetector(
          onPanDown: (d) => set(d.localPosition),
          onPanUpdate: (d) => set(d.localPosition),
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(colors: [Colors.white, HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor()]),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Colors.black],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: hsv.saturation * w - 8,
                  top: (1 - hsv.value) * h - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hsv, required this.onChanged});
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        void set(double x) => onChanged(hsv.withHue((x / w).clamp(0, 1) * 359.9));
        return GestureDetector(
          onPanDown: (d) => set(d.localPosition.dx),
          onPanUpdate: (d) => set(d.localPosition.dx),
          child: SizedBox(
            height: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          for (var h = 0; h <= 360; h += 60) HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: hsv.hue / 360 * w - 9,
                  top: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opens a [ColorPicker] in a glass popover at [anchor].
Future<void> showColorPopover(
  BuildContext context, {
  required Rect anchor,
  required VColor? value,
  required ValueChanged<VColor?> onChanged,
  bool allowNone = false,
}) {
  return showGlassPopover(
    context,
    anchor: anchor,
    width: 260,
    builder: (ctx, close) {
      final p = VersoPalette.of(ctx);
      VColor? current = value;
      return GlassSurface(
        radius: 16,
        tint: p.isDark ? const Color(0xF21E1A16) : const Color(0xF2FFFFFF),
        padding: const EdgeInsets.all(14),
        child: StatefulBuilder(
          builder: (ctx, set) => ColorPicker(
            value: current,
            allowNone: allowNone,
            onChanged: (c) {
              set(() => current = c);
              onChanged(c);
            },
          ),
        ),
      );
    },
  );
}

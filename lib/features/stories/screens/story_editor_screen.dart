import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/story_model.dart';
import '../providers/stories_provider.dart';

/// A draggable, scalable, rotatable text overlay.
class _TextOverlay {
  String   text;
  Offset   position;      // fraction of canvas (0–1)
  double   scale;
  double   rotation;      // radians
  Color    textColor;
  Color?   bgColor;       // null = no background
  double   fontSize;
  FontWeight fontWeight;

  _TextOverlay({
    required this.text,
    this.position   = const Offset(0.5, 0.5),
    this.scale      = 1.0,
    this.rotation   = 0.0,
    this.textColor  = Colors.white,
    this.bgColor,
    this.fontSize   = 28,
    this.fontWeight = FontWeight.w700,
  });

  _TextOverlay copy() => _TextOverlay(
    text:       text,
    position:   position,
    scale:      scale,
    rotation:   rotation,
    textColor:  textColor,
    bgColor:    bgColor,
    fontSize:   fontSize,
    fontWeight: fontWeight,
  );
}

/// Full-screen story editor – add text overlays on images before sharing.
class StoryEditorScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const StoryEditorScreen({super.key, required this.imageFile});

  @override
  ConsumerState<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends ConsumerState<StoryEditorScreen>
    with TickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();

  final List<_TextOverlay> _overlays = [];
  int? _selectedIndex;
  bool _isEditing    = false; // text input mode
  bool _isExporting  = false;
  bool _showToolbar  = true;
  BoxFit _fitMode    = BoxFit.contain; // contain = full image, cover = fill

  // ── Color palette ──────────────────────────────────────────
  static const _palette = <Color>[
    Colors.white,
    Colors.black,
    Color(0xFFFF4D6D),  // pink
    Color(0xFF6D28D9),  // violet
    Color(0xFF3B82F6),  // blue
    Color(0xFF10B981),  // green
    Color(0xFFF59E0B),  // amber
    Color(0xFFEF4444),  // red
    Color(0xFFF97316),  // orange
    Color(0xFF06B6D4),  // cyan
    Color(0xFFEC4899),  // fuchsia
    Color(0xFF8B5CF6),  // purple
  ];

  // ── Background style cycle ─────────────────────────────────
  // 0 = no bg, 1 = semi-transparent, 2 = solid
  int _bgStyleIndex = 0;

  Color? _bgColorForStyle(Color textColor) {
    switch (_bgStyleIndex) {
      case 1:
        return textColor == Colors.black
            ? Colors.white.withOpacity(0.45)
            : Colors.black.withOpacity(0.45);
      case 2:
        return textColor == Colors.black
            ? Colors.white
            : Colors.black;
      default:
        return null;
    }
  }

  // ── Add text ───────────────────────────────────────────────
  void _addText() {
    setState(() {
      _overlays.add(_TextOverlay(text: ''));
      _selectedIndex = _overlays.length - 1;
      _isEditing = true;
      _showToolbar = false;
    });
  }

  // ── Delete selected ────────────────────────────────────────
  void _deleteSelected() {
    if (_selectedIndex == null) return;
    setState(() {
      _overlays.removeAt(_selectedIndex!);
      _selectedIndex = null;
    });
  }

  // ── Export (flatten) ───────────────────────────────────────
  Future<void> _export() async {
    // Deselect any overlay first
    setState(() {
      _selectedIndex = null;
      _isExporting = true;
      _showToolbar = false;
    });

    // Wait for frame to render without selection highlights
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir  = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/story_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // Upload via the existing create story provider
      final notifier = ref.read(createStoryProvider.notifier);
      notifier.setFile(file, StoryMediaType.image);
      await notifier.upload();

      if (mounted) Navigator.of(context).pop(true); // true = uploaded
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share story: $e'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Canvas (image + overlays) ───────────────────
          GestureDetector(
            onTap: () {
              // Tap on empty area — deselect
              if (_isEditing) return;
              setState(() {
                _selectedIndex = null;
                _showToolbar = true;
              });
            },
            child: RepaintBoundary(
              key: _repaintKey,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Blurred background fill (for non-16:9 images)
                    ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                          sigmaX: 30, sigmaY: 30),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),

                    // Main image — zoomable and pannable
                    InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.file(
                          widget.imageFile,
                          fit: _fitMode,
                        ),
                      ),
                    ),

                    // Text overlays
                    ..._overlays.asMap().entries.map((entry) {
                      final i       = entry.key;
                      final overlay = entry.value;
                      final isSelected = i == _selectedIndex && !_isExporting;

                      return _DraggableTextOverlay(
                        overlay:    overlay,
                        canvasSize: size,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedIndex = i;
                            _showToolbar = false;
                          });
                        },
                        onDoubleTap: () {
                          setState(() {
                            _selectedIndex = i;
                            _isEditing = true;
                            _showToolbar = false;
                          });
                        },
                        onPositionUpdate: (newPos) {
                          setState(() => overlay.position = newPos);
                        },
                        onScaleUpdate: (newScale) {
                          setState(() => overlay.scale = newScale);
                        },
                        onRotationUpdate: (newRot) {
                          setState(() => overlay.rotation = newRot);
                        },
                        onScaleStart: () {
                          // Child widget handles its own base values
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────
          if (_showToolbar && !_isExporting)
            Positioned(
              top: topPad + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _CircleButton(
                    icon: _fitMode == BoxFit.contain
                        ? Icons.fullscreen_rounded
                        : Icons.fullscreen_exit_rounded,
                    onTap: () => setState(() {
                      _fitMode = _fitMode == BoxFit.contain
                          ? BoxFit.cover
                          : BoxFit.contain;
                    }),
                  ),
                  const SizedBox(width: 10),
                  _CircleButton(
                    icon: Icons.text_fields_rounded,
                    onTap: _addText,
                    gradient: true,
                  ),
                ],
              ),
            ),

          // ── Selected overlay toolbar ───────────────────
          if (_selectedIndex != null && !_isEditing && !_isExporting)
            Positioned(
              top: topPad + 8,
              left: 12,
              right: 12,
              child: _SelectedToolbar(
                overlay:  _overlays[_selectedIndex!],
                palette:  _palette,
                bgStyleIndex: _bgStyleIndex,
                onClose: () => setState(() {
                  _selectedIndex = null;
                  _showToolbar = true;
                }),
                onDelete:    _deleteSelected,
                onEdit: () => setState(() => _isEditing = true),
                onColorChanged: (c) => setState(() {
                  _overlays[_selectedIndex!].textColor = c;
                  _overlays[_selectedIndex!].bgColor =
                      _bgColorForStyle(c);
                }),
                onBgStyleToggle: () => setState(() {
                  _bgStyleIndex = (_bgStyleIndex + 1) % 3;
                  final ov = _overlays[_selectedIndex!];
                  ov.bgColor = _bgColorForStyle(ov.textColor);
                }),
                onFontSizeChanged: (v) => setState(() {
                  _overlays[_selectedIndex!].fontSize = v;
                }),
              ),
            ),

          // ── Text input overlay ─────────────────────────
          if (_isEditing && _selectedIndex != null)
            _TextInputOverlay(
              overlay: _overlays[_selectedIndex!],
              onDone: (text) {
                setState(() {
                  if (text.isEmpty) {
                    _overlays.removeAt(_selectedIndex!);
                    _selectedIndex = null;
                    _showToolbar = true;
                  } else {
                    _overlays[_selectedIndex!].text = text;
                  }
                  _isEditing = false;
                });
              },
            ),

          // ── Bottom share button ────────────────────────
          if (_showToolbar && !_isExporting && !_isEditing)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _isExporting ? null : _export,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Share Story',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ),

          // ── Loading overlay ────────────────────────────
          if (_isExporting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                    SizedBox(height: 16),
                    Text('Sharing your story…',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DRAGGABLE TEXT OVERLAY WIDGET
// ══════════════════════════════════════════════════════════════

class _DraggableTextOverlay extends StatefulWidget {
  final _TextOverlay     overlay;
  final Size             canvasSize;
  final bool             isSelected;
  final VoidCallback     onTap;
  final VoidCallback     onDoubleTap;
  final ValueChanged<Offset> onPositionUpdate;
  final ValueChanged<double> onScaleUpdate;
  final ValueChanged<double> onRotationUpdate;
  final VoidCallback         onScaleStart;

  const _DraggableTextOverlay({
    required this.overlay,
    required this.canvasSize,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    required this.onPositionUpdate,
    required this.onScaleUpdate,
    required this.onRotationUpdate,
    required this.onScaleStart,
  });

  @override
  State<_DraggableTextOverlay> createState() => _DraggableTextOverlayState();
}

class _DraggableTextOverlayState extends State<_DraggableTextOverlay> {
  late double _baseScale;
  late double _baseRotation;
  late Offset _startFocalPoint;

  @override
  Widget build(BuildContext context) {
    final ov = widget.overlay;
    if (ov.text.isEmpty) return const SizedBox.shrink();

    final dx = ov.position.dx * widget.canvasSize.width;
    final dy = ov.position.dy * widget.canvasSize.height;

    return Positioned(
      left: dx,
      top:  dy,
      child: GestureDetector(
        onTap:       widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onScaleStart: (d) {
          widget.onScaleStart();
          _baseScale      = ov.scale;
          _baseRotation   = ov.rotation;
          _startFocalPoint = d.focalPoint;
        },
        onScaleUpdate: (d) {
          // Translate
          final delta = d.focalPoint - _startFocalPoint;
          _startFocalPoint = d.focalPoint;
          final newPos = Offset(
            ov.position.dx + delta.dx / widget.canvasSize.width,
            ov.position.dy + delta.dy / widget.canvasSize.height,
          );
          widget.onPositionUpdate(newPos);

          // Scale & rotate (only when 2+ pointers)
          if (d.pointerCount >= 2) {
            widget.onScaleUpdate(_baseScale * d.scale);
            widget.onRotationUpdate(_baseRotation + d.rotation);
          }
        },
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(ov.scale)
              ..rotateZ(ov.rotation),
            child: Container(
              padding: ov.bgColor != null
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                  : EdgeInsets.zero,
              decoration: ov.bgColor != null
                  ? BoxDecoration(
                      color: ov.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Text(
                ov.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:      ov.textColor,
                  fontSize:   ov.fontSize,
                  fontWeight: ov.fontWeight,
                  height:     1.3,
                  shadows: ov.bgColor == null
                      ? const [
                          Shadow(blurRadius: 8, color: Colors.black87),
                          Shadow(blurRadius: 16, color: Colors.black54),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SELECTED OVERLAY TOOLBAR
// ══════════════════════════════════════════════════════════════

class _SelectedToolbar extends StatelessWidget {
  final _TextOverlay  overlay;
  final List<Color>   palette;
  final int           bgStyleIndex;
  final VoidCallback  onClose;
  final VoidCallback  onDelete;
  final VoidCallback  onEdit;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback  onBgStyleToggle;
  final ValueChanged<double> onFontSizeChanged;

  const _SelectedToolbar({
    required this.overlay,
    required this.palette,
    required this.bgStyleIndex,
    required this.onClose,
    required this.onDelete,
    required this.onEdit,
    required this.onColorChanged,
    required this.onBgStyleToggle,
    required this.onFontSizeChanged,
  });

  String get _bgLabel {
    switch (bgStyleIndex) {
      case 1: return 'Semi';
      case 2: return 'Solid';
      default: return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top action row
        Row(
          children: [
            _CircleButton(icon: Icons.close_rounded, onTap: onClose),
            const Spacer(),
            _CircleButton(icon: Icons.edit_rounded, onTap: onEdit),
            const SizedBox(width: 8),
            _PillButton(
              icon: Icons.format_color_fill_rounded,
              label: _bgLabel,
              onTap: onBgStyleToggle,
            ),
            const SizedBox(width: 8),
            _CircleButton(
              icon: Icons.delete_outline_rounded,
              onTap: onDelete,
              color: AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Color palette row
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: palette.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = palette[i];
              final selected = c.value == overlay.textColor.value;
              return GestureDetector(
                onTap: () => onColorChanged(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width:  selected ? 36 : 30,
                  height: selected ? 36 : 30,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      width: selected ? 3 : 1.5,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(
                            color: c.withOpacity(0.5),
                            blurRadius: 8,
                          )]
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Font size slider
        Row(
          children: [
            const Icon(Icons.text_decrease_rounded,
                color: Colors.white54, size: 16),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withOpacity(0.15),
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: overlay.fontSize,
                  min: 14,
                  max: 72,
                  onChanged: onFontSizeChanged,
                ),
              ),
            ),
            const Icon(Icons.text_increase_rounded,
                color: Colors.white54, size: 16),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TEXT INPUT OVERLAY
// ══════════════════════════════════════════════════════════════

class _TextInputOverlay extends StatefulWidget {
  final _TextOverlay overlay;
  final ValueChanged<String> onDone;

  const _TextInputOverlay({
    required this.overlay,
    required this.onDone,
  });

  @override
  State<_TextInputOverlay> createState() => _TextInputOverlayState();
}

class _TextInputOverlayState extends State<_TextInputOverlay> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController(text: widget.overlay.text);
    _focus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onDone(_ctrl.text.trim()),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller:  _ctrl,
                  focusNode:   _focus,
                  textAlign:   TextAlign.center,
                  maxLines:    null,
                  style: TextStyle(
                    color:      widget.overlay.textColor,
                    fontSize:   widget.overlay.fontSize,
                    fontWeight: widget.overlay.fontWeight,
                    height:     1.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type something…',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: widget.overlay.fontSize,
                      fontWeight: widget.overlay.fontWeight,
                    ),
                    border:       InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onSubmitted: (t) => widget.onDone(t.trim()),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => widget.onDone(_ctrl.text.trim()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SMALL REUSABLE BUTTONS
// ══════════════════════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         gradient;
  final Color?       color;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.gradient = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient ? AppColors.primaryGradient : null,
          color: gradient ? null : Colors.black.withOpacity(0.45),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

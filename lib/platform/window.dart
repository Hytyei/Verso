import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Window chrome operations, behind an interface so widget tests need no
/// native window.
abstract class WindowApi {
  const WindowApi();
  Future<void> minimize();
  Future<void> toggleMaximize();
  Future<void> close();
  Future<void> startDrag();
}

class NoopWindowApi extends WindowApi {
  const NoopWindowApi();
  @override
  Future<void> minimize() async {}
  @override
  Future<void> toggleMaximize() async {}
  @override
  Future<void> close() async {}
  @override
  Future<void> startDrag() async {}
}

class DesktopWindowApi extends WindowApi {
  const DesktopWindowApi();
  @override
  Future<void> minimize() => windowManager.minimize();
  @override
  Future<void> toggleMaximize() async =>
      await windowManager.isMaximized() ? windowManager.unmaximize() : windowManager.maximize();
  @override
  Future<void> close() => windowManager.close();
  @override
  Future<void> startDrag() => windowManager.startDragging();
}

/// Frameless window, min 960×640, so the glass title bar reaches the top.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();
  // Fit the default size to the screen's work area (logical px).
  var size = const Size(1360, 860);
  try {
    final visible = (await screenRetriever.getPrimaryDisplay()).visibleSize;
    if (visible != null) {
      size = Size(size.width.clamp(960, visible.width * .94), size.height.clamp(640, visible.height * .94));
    }
  } catch (_) {}
  final options = WindowOptions(
    size: size,
    minimumSize: const Size(960, 640),
    center: true,
    title: 'Verso',
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: const Color(0x00000000),
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

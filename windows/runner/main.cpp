#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // Win32Window::Point origin(10, 10);
  // Win32Window::Size size(1280, 720);
  
  // set window size and location like a cellphone emulator
  int32_t screen_w = GetSystemMetrics(SM_CXSCREEN);
  int32_t screen_h = GetSystemMetrics(SM_CYSCREEN);
  int32_t size_w, size_h, origin_x, origin_y = 5, ratio_w = 9, ratio_h = 20;
  size_h = (screen_h > 1000) ? (int)(screen_h * 0.6) : size_h = (int)(screen_h * 0.9);
  size_w = (int)(size_h * ratio_w / ratio_h);
  origin_x = screen_w - size_w;
  Win32Window::Point origin(origin_x, origin_y);
  Win32Window::Size size(size_w, size_h);
  if (!window.Create(L"passenger_app", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

#include <windows.h>

#include <flutter_windows.h>

#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  ::AttachConsole(ATTACH_PARENT_PROCESS);
  ::freopen("CONIN$", "r", stdin);
  ::freopen("CONOUT$", "w", stderr);
  ::freopen("CONOUT$", "w", stdout);

  flutter::DartProject project(L"data");
  std::vector<std::string> arguments;
  project.set_dart_entrypoint_arguments(arguments);

  ::SetConsoleOutputCP(CP_UTF8);
  ::SetConsoleCP(CP_UTF8);

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"Tibb Klinika", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  return EXIT_SUCCESS;
}

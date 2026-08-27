#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

/// Window attribute that enables blur behind the window.
constexpr PWSTR kWindowClassName = L"FLUTTER_RUNNER_WIN32_WINDOW";

/// Registry key for app visibility and DPI awareness.
constexpr wchar_t kWindowStateKey[] = L"Software\\Tibb Klinika\\WindowState";
constexpr wchar_t kWindowStateWidthValueName[] = L"Width";
constexpr wchar_t kWindowStateHeightValueName[] = L"Height";

constexpr int kWindowInitialWidth = 1280;
constexpr int kWindowInitialHeight = 720;

}  // namespace

Win32Window::Win32Window() {}

Win32Window::~Win32Window() {}

bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  Destroy();
  const wchar_t* window_class =
      kWindowClassName;

  HINSTANCE instance = GetModuleHandle(nullptr);

  WNDCLASS window_class_definition = {};
  window_class_definition.hIcon =
      LoadIcon(instance, MAKEINTRESOURCE(IDI_APP_ICON));
  window_class_definition.lpszClassName = window_class;
  window_class_definition.style = CS_OWNDC;
  window_class_definition.lpfnWndProc = WndProc;
  RegisterClass(&window_class_definition);

  const DWORD window_style = WS_CAPTION | WS_MINIMIZEBOX | WS_MAXIMIZEBOX |
                             WS_SYSMENU | WS_THICKFRAME;

  HWND window = CreateWindowEx(
      WS_EX_APPWINDOW,
      window_class,
      title.c_str(),
      window_style,
      origin.x(), origin.y(),
      size.width(), size.height(),
      nullptr, nullptr, instance, this);

  if (!window) {
    return false;
  }

  // Allow non-client area to be rendered with Flutter.
  DwmExtendFrameIntoClientArea(window, new MARGINS{1, 1, 1, 1});

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}

LRESULT CALLBACK Win32Window::WndProc(HWND hwnd, unsigned int message,
                                      WPARAM wparam, LPARAM lparam) {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(hwnd, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));
    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    that->window_handle_ = hwnd;
  } else if (Win32Window* that = GetThisFromHandle(hwnd)) {
    return that->MessageHandler(message, wparam, lparam);
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

LRESULT Win32Window::MessageHandler(unsigned int message,
                                    WPARAM wparam,
                                    LPARAM lparam) {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      PostQuitMessage(0);
      return 0;
    case WM_DPICHANGED: {
      // DPI change handling
      return 0;
    }
    default:
      return DefWindowProc(window_handle_, message, wparam, lparam);
  }
}

Win32Window* Win32Window::GetThisFromHandle(HWND window) {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

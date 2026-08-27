#include <windows.h>

void RegisterFlutterWindow() {
  HINSTANCE instance = GetModuleHandle(nullptr);
  RegisterClassEx(&registerClass(instance));
}

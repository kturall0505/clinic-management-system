#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <windows.h>

namespace flutter {
  HWND CreateFlutterWindow(HINSTANCE hInst, const wchar_t* title, int w, int h);
}

#endif

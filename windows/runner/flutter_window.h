#ifndef FLUTTER_WINDOW_H_
#define FLUTTER_WINDOW_H_

#include <windows.h>

#include <memory>
#include <string>
#include <vector>

#include "flutter/dart_project.h"

namespace flutter {
  class FlutterViewController;
}

class FlutterWindow {
 public:
  struct Point {
    int x() const { return x_; }
    int y() const { return y_; }
    int x_, y_;
  };

  struct Size {
    int width() const { return width_; }
    int height() const { return height_; }
    int width_, height_;
  };

  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  bool CreateAndShow(const std::wstring& title,
                     const Point& origin,
                     const Size& size);

  void SetQuitOnClose(bool quit_on_close);

 protected:
  HWND GetWindowHandle() const;

 private:
  HWND window_handle_;
};

#endif

#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <string>
#include <vector>

class Win32Window {
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

  Win32Window();
  virtual ~Win32Window();

  bool Create(const std::wstring& title, const Point& origin, const Size& size);
  bool Show();
  void Destroy();

  virtual void OnCreate() {}
  virtual void OnDestroy() {}

 private:
  HWND window_handle_ = nullptr;
  static LRESULT CALLBACK WndProc(HWND hwnd, unsigned int message,
                                  WPARAM wparam, LPARAM lparam);
  LRESULT MessageHandler(unsigned int message, WPARAM wparam, LPARAM lparam);
  static Win32Window* GetThisFromHandle(HWND window);
};

#endif

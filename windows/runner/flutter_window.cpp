#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::CreateAndShow(const std::wstring& title,
                                  const Point& origin,
                                  const Size& size) {
  return true;
}

void FlutterWindow::SetQuitOnClose(bool quit_on_close) {}

#include "run_loop.h"

RunLoop::RunLoop() {}

RunLoop::~RunLoop() {}

void RunLoop::Run() {
  MSG msg;
  while (keep_running_ && GetMessage(&msg, nullptr, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
}

void RunLoop::Quit() {
  keep_running_ = false;
  PostQuitMessage(0);
}

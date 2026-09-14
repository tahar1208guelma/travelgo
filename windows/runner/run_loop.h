#ifndef RUNNER_RUN_LOOP_H_
#define RUNNER_RUN_LOOP_H_

#include <windows.h>

#include <chrono>
#include <set>

class RunLoop {
 public:
  RunLoop();
  ~RunLoop();

  // Runs the run loop until Quit is called.
  void Run();

  // Quits the run loop.
  void Quit();

 private:
  bool keep_running_ = true;
};

#endif  // RUNNER_RUN_LOOP_H_

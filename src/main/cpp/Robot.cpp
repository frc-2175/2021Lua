// Copyright (c) FIRST and other WPILib contributors.
// Open Source Software; you can modify and/or share it under the terms of
// the WPILib BSD license file in the root directory of this project.

#include <frc/Joystick.h>
#include <frc/PWMSparkMax.h>
#include <frc/TimedRobot.h>
#include <frc/drive/DifferentialDrive.h>

#include <lua.hpp>

/**
 * This is a demo program showing the use of the DifferentialDrive class.
 * Runs the motors with arcade steering.
 */
class Robot : public frc::TimedRobot {
  frc::PWMSparkMax leftMotor{0};
  frc::PWMSparkMax rightMotor{1};
  frc::DifferentialDrive robotDrive{leftMotor, rightMotor};
  frc::Joystick stick{0};

  lua_State *L;

public:
  void RobotInit() override {
    printf("Hello from %s.\n", "C++");

    L = luaL_newstate();
    luaL_openlibs(L);
    int result = luaL_dostring(L,
      "print(\"Hello from Lua.\")\n"
      "local ffi = require(\"ffi\")\n"
      "ffi.cdef[[\n"
      "int printf(const char *fmt, ...);\n"
      "]]\n"
      "ffi.C.printf(\"Hello from %s via %s!\\n\", \"C++\", \"Lua\")\n"
    );
    if (result) {
      printf("Failed to run script: %s\n", lua_tostring(L, -1));
      return;
    }
  }

  void TeleopPeriodic() override {
    // Drive with arcade style
    robotDrive.ArcadeDrive(stick.GetY(), stick.GetX());
  }
};

#ifndef RUNNING_FRC_TESTS
int main() {
  return frc::StartRobot<Robot>();
}
#endif

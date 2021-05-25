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
      "ffi = require(\"ffi\")\n"
      "ffi.cdef[[\n"
      "int printf(const char *fmt, ...);\n"
      "void* PWMSparkMax_new(int channel);\n"
      "void PWMSparkMax_Set(void* m, double value);\n"
      "void* DifferentialDrive_new(void* leftMotor, void* rightMotor);\n"
      "void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs);\n"
      "void* Joystick_new(int port);\n"
      "double Joystick_GetX(void* j);\n"
      "double Joystick_GetY(void* j);\n"
      "]]\n"
      "ffi.C.printf(\"Hello from %s via %s!\\n\", \"C++\", \"Lua\")\n"
      "leftMotor = ffi.C.PWMSparkMax_new(2)\n"
      "rightMotor = ffi.C.PWMSparkMax_new(3)\n"
      "stick = ffi.C.Joystick_new(0)\n"
      "robotDrive = ffi.C.DifferentialDrive_new(leftMotor, rightMotor)\n"
    );
    if (result) {
      printf("Failed to run script: %s\n", lua_tostring(L, -1));
      return;
    }
  }

  void TeleopPeriodic() override {
    // Drive with arcade style
    robotDrive.ArcadeDrive(stick.GetY(), stick.GetX());

    int result = luaL_dostring(L,
      // "print(ffi.C.Joystick_GetX(stick), ffi.C.Joystick_GetY(stick))\n"
      // "ffi.C.PWMSparkMax_Set(leftMotor, ffi.C.Joystick_GetX(stick))\n"
      // "ffi.C.PWMSparkMax_Set(rightMotor, ffi.C.Joystick_GetY(stick))\n"
      "ffi.C.DifferentialDrive_ArcadeDrive(robotDrive, ffi.C.Joystick_GetY(stick), ffi.C.Joystick_GetX(stick), false)\n"
    );
    if (result) {
      printf("Failed to run script: %s\n", lua_tostring(L, -1));
      return;
    }
  }
};

#ifndef RUNNING_FRC_TESTS
int main() {
  return frc::StartRobot<Robot>();
}
#endif

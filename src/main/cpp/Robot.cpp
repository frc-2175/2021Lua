// Copyright (c) FIRST and other WPILib contributors.
// Open Source Software; you can modify and/or share it under the terms of
// the WPILib BSD license file in the root directory of this project.

#include <frc/TimedRobot.h>
#include <lua.hpp>

const char* luaSearchPaths[] = {
  ".\\src\\lua\\",
  "/home/lvuser/lua/"
};

int runLuaFile(lua_State* L, const char* filename) {
  int fileFindError = 0;
  for (auto searchpath : luaSearchPaths) {
    char filenamebuf[1024];
    sprintf(filenamebuf, "%s%s", searchpath, filename);
    printf("Trying to load file %s...\n", filenamebuf);

    fileFindError = luaL_loadfile(L, filenamebuf);
    if (fileFindError) {
      printf("Failed to load file %s: %s\n", filename, lua_tostring(L, -1));
    } else {
      break;
    }
  }

  if (fileFindError) {
    return fileFindError;
  }

  int result = lua_pcall(L, 0, LUA_MULTRET, 0);
  if (result) {
    printf("Failed to run %s: %s\n", filename, lua_tostring(L, -1));
  }
  return result;
}

int runLuaString(lua_State* L, const char* str) {
  int result = luaL_dostring(L, str);
  if (result) {
    printf("Failed to run script: %s\n", lua_tostring(L, -1));
  }

  return result;
}

class Robot : public frc::TimedRobot {
  lua_State *L;
  bool ok = false;

public:
  void RobotInit() override {
    L = luaL_newstate();
    luaL_openlibs(L);

    int initError = runLuaFile(L, "init.lua");
    if (!initError) {
      ok = true;
    }

    if (ok) {
      runLuaFile(L, "robot.lua");
      runLuaString(L, "robot.robotInit()");
    }
  }

  void RobotPeriodic() override {
    if (ok) runLuaString(L, "robot.robotPeriodic()");
  }

  void DisabledInit() override {
    if (ok) runLuaString(L, "robot.disabledInit()");
  }

  void DisabledPeriodic() override {
    if (ok) runLuaString(L, "robot.disabledPeriodic()");
  }

  void AutonomousInit() override {
    if (ok) runLuaString(L, "robot.autonomousInit()");
  }

  void AutonomousPeriodic() override {
    if (ok) runLuaString(L, "robot.autonomousPeriodic()");
  }

  void TeleopInit() override {
    if (ok) runLuaString(L, "robot.teleopInit()");
  }

  void TeleopPeriodic() override {
    if (ok) runLuaString(L, "robot.teleopPeriodic()");
  }

  void SimulationInit() override {
    if (ok) runLuaString(L, "robot.simulationInit()");
  }

  void SimulationPeriodic() override {
    if (ok) runLuaString(L, "robot.simulationPeriodic()");
  }
};

#ifndef RUNNING_FRC_TESTS
int main() {
  return frc::StartRobot<Robot>();
}
#endif

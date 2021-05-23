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
    // L = luaL_newstate();
    // int result = luaL_dostring(L, "return 'Hello from Lua!'");
    // if (result) {
    //   printf("Failed to run script: %s\n", lua_tostring(L, -1));
    //   return;
    // }

    // /* Get the returned value at the top of the stack (index -1) */
    // const char* ret = lua_tostring(L, -1);

    // printf("Script returned: %s\n", ret);

    // lua_pop(L, 1);  /* Take the returned value out of the stack */
  }

#if 0
  void RobotInit() override {
    L = luaL_newstate();
    luaL_openlibs(L); /* Load Lua libraries */

    /* Load the file containing the script we are going to run */
    // int status = luaL_loadfile(L, "script.lua");
    int status = luaL_loadstring(L,
      "-- script.lua"
      "-- Receives a table, returns the sum of its components."
      "io.write(\"The table the script received has:\\n\");"
      "x = 0"
      "for i = 1, #foo do"
      "  print(i, foo[i])"
      "  x = x + foo[i]"
      "end"
      "io.write(\"Returning data back to C\\n\");"
      "return x"
    );
    if (status) {
        /* If something went wrong, error message is at the top of */
        /* the stack */
        fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
        return;
    }

    /*
     * Ok, now here we go: We pass data to the lua script on the stack.
     * That is, we first have to prepare Lua's virtual stack the way we
     * want the script to receive it, then ask Lua to run it.
     */
    lua_newtable(L);    /* We will pass a table */

    /*
     * To put values into the table, we first push the index, then the
     * value, and then call lua_rawset() with the index of the table in the
     * stack. Let's see why it's -3: In Lua, the value -1 always refers to
     * the top of the stack. When you create the table with lua_newtable(),
     * the table gets pushed into the top of the stack. When you push the
     * index and then the cell value, the stack looks like:
     *
     * <- [stack bottom] -- table, index, value [top]
     *
     * So the -1 will refer to the cell value, thus -3 is used to refer to
     * the table itself. Note that lua_rawset() pops the two last elements
     * of the stack, so that after it has been called, the table is at the
     * top of the stack.
     */
    for (int i = 1; i <= 5; i++) {
        lua_pushnumber(L, i);   /* Push the table index */
        lua_pushnumber(L, i*2); /* Push the cell value */
        lua_rawset(L, -3);      /* Stores the pair in the table */
    }

    /* By what name is the script going to reference our table? */
    lua_setglobal(L, "foo");

    /* Ask Lua to run our little script */
    int result = lua_pcall(L, 0, LUA_MULTRET, 0);
    if (result) {
        fprintf(stderr, "Failed to run script: %s\n", lua_tostring(L, -1));
        return;
    }

    /* Get the returned value at the top of the stack (index -1) */
    double sum = lua_tonumber(L, -1);

    printf("Script returned: %.0f\n", sum);

    lua_pop(L, 1);  /* Take the returned value out of the stack */
  }
#endif

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

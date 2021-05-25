#include <frc/Joystick.h>

#include "luadef.h"

LUAFUNC void* Joystick_new(int port) {
    return new frc::Joystick{port};
}

LUAFUNC double Joystick_GetX(void* j) {
    return ((frc::Joystick*)j)->GetX();
}

LUAFUNC double Joystick_GetY(void* j) {
    return ((frc::Joystick*)j)->GetY();
}

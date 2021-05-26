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

LUAFUNC bool Joystick_GetRawButton(void* j, int button) {
    return ((frc::Joystick*)j)->GetRawButton(button);
}

LUAFUNC bool Joystick_GetRawButtonPressed(void* j, int button) {
    return ((frc::Joystick*)j)->GetRawButtonPressed(button);
}

LUAFUNC bool Joystick_GetRawButtonReleased(void* j, int button) {
    return ((frc::Joystick*)j)->GetRawButtonReleased(button);
}

LUAFUNC double Joystick_GetRawAxis(void* j, int axis) {
    return ((frc::Joystick*)j)->GetRawAxis(axis);
}

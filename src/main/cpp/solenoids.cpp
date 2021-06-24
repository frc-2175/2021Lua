#include <frc/Solenoid.h>
#include <frc/DoubleSolenoid.h>

#include "luadef.h"

LUAFUNC void* DoubleSolenoid_new(int forwardChannel, int reverseChannel) {
    return new frc::DoubleSolenoid(forwardChannel, reverseChannel);
}

LUAFUNC void DoubleSolenoid_set(void* s, int value) {
    ((frc::DoubleSolenoid*)s)->Set((frc::DoubleSolenoid::Value)value);
}

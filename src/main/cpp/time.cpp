#include "luadef.h"

#include <frc/Timer.h>

LUAFUNC double GetFPGATimestamp() {
    return frc::Timer::GetFPGATimestamp();
}

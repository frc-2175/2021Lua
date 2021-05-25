#include <frc/PWMSparkMax.h>
#include <frc/TimedRobot.h>
#include <frc/drive/DifferentialDrive.h>

#include "luadef.h"

LUAFUNC void* PWMSparkMax_new(int channel) {
    return new frc::PWMSparkMax{channel};
}

LUAFUNC void* PWMSparkMax_toSpeedController(void* m) {
    frc::SpeedController* sc = (frc::PWMSparkMax*)m;
    return sc;
}

LUAFUNC void PWMSparkMax_Set(void* m, double value) {
    ((frc::PWMSparkMax*)m)->Set(value);
}

LUAFUNC void* DifferentialDrive_new(void* leftMotor, void* rightMotor) {
    auto l = (frc::SpeedController*)leftMotor;
    auto r = (frc::SpeedController*)rightMotor;
    return new frc::DifferentialDrive{*l, *r};
}

LUAFUNC void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs) {
    ((frc::DifferentialDrive*)d)->ArcadeDrive(xSpeed, zRotation, squareInputs);
}

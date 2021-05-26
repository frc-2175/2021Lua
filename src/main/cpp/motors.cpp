#include <ctre/phoenix/motorcontrol/can/WPI_TalonSRX.h>
#include <frc/PWMSparkMax.h>
#include <frc/TimedRobot.h>
#include <frc/drive/DifferentialDrive.h>

#include "luadef.h"


// PWM Spark Max

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


// Talon SRX

LUAFUNC void* TalonSRX_new(int deviceNumber) {
    return new ctre::phoenix::motorcontrol::can::WPI_TalonSRX{deviceNumber};
}

LUAFUNC void* TalonSRX_toSpeedController(void* m) {
    frc::SpeedController* sc = (ctre::phoenix::motorcontrol::can::WPI_TalonSRX*)m;
    return sc;
}

LUAFUNC double TalonSRX_Get(void* m) {
    return ((ctre::phoenix::motorcontrol::can::WPI_TalonSRX*)m)->Get();
}

LUAFUNC void TalonSRX_Set(void* m, double value) {
    ((ctre::phoenix::motorcontrol::can::WPI_TalonSRX*)m)->Set(value);
}

LUAFUNC void TalonSRX_SetInverted(void* m, int invertType) {
    ((ctre::phoenix::motorcontrol::can::WPI_TalonSRX*)m)
        ->SetInverted((ctre::phoenix::motorcontrol::InvertType)invertType);
}


// Differential Drive

LUAFUNC void* DifferentialDrive_new(void* leftMotor, void* rightMotor) {
    auto l = (frc::SpeedController*)leftMotor;
    auto r = (frc::SpeedController*)rightMotor;
    return new frc::DifferentialDrive{*l, *r};
}

LUAFUNC void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs) {
    ((frc::DifferentialDrive*)d)->ArcadeDrive(xSpeed, zRotation, squareInputs);
}

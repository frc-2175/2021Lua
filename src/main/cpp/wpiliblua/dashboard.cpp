// Automatically generated by bindings.c. DO NOT EDIT.

#include <string>
#include <wpi/StringRef.h>
#include <wpi/ArrayRef.h>
#include <frc/smartdashboard/SmartDashboard.h>

#include "luadef.h"

LUAFUNC void PutNumber( const char* keyName, double value) {
    frc::SmartDashboard::PutNumber((wpi::StringRef)keyName, value);
}

LUAFUNC void PutNumberArray( const char* keyName,  double* value, size_t size) {
    frc::SmartDashboard::PutNumberArray((wpi::StringRef)keyName, wpi::ArrayRef(value, size));
}

LUAFUNC void PutString( const char* keyName,  const char* value) {
    frc::SmartDashboard::PutString((wpi::StringRef)keyName, (wpi::StringRef)value);
}

LUAFUNC void PutStringArray( const char* keyName, const char * * value, size_t size) {
    frc::SmartDashboard::PutStringArray((wpi::StringRef)keyName, wpi::ArrayRef(std::vector<std::string>(value, value + size)));
}

LUAFUNC void PutBoolean( const char* keyName, bool value) {
    frc::SmartDashboard::PutBoolean((wpi::StringRef)keyName, value);
}

LUAFUNC void PutBooleanArray( const char* keyName,  int* value, size_t size) {
    frc::SmartDashboard::PutBooleanArray((wpi::StringRef)keyName, wpi::ArrayRef(value, size));
}
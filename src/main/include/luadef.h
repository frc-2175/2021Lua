#pragma once

#ifdef _MSC_VER // Windows (for simulator)
#define LUAFUNC extern "C" __declspec(dllexport)
#else
#define LUAFUNC extern "C"
#endif

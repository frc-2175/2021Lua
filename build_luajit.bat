@echo off
setlocal

@REM Heads up. Building LuaJIT for the RIO is touchy and you need to make sure things
@REM are in order.

@REM Make sure you have a version of Mingw on your system that actually includes
@REM 32-bit libraries. The default from Chocolatey does not. I used the
@REM MingW-Win64-builds downloads from the link below, and installed version 8.1.0
@REM for x86-64 with win32 threads and SJLJ exceptions.

@REM http://mingw-w64.org/doku.php/download#mingw-builds

@REM Then make sure that you have a recent copy of Visual Studio installed. You MUST
@REM run this script from a Visual Studio command prompt, and you MUST make sure that
@REM it will compile as x64 instead of x86.

@REM You then may also need to modify the src/Makefile in LuaJIT to remove
@REM `2>/dev/null` from `TARGET_AR`. I believe that due to a bug in the target and
@REM host detection - it should never be applied when the host is Windows, but it
@REM is. I found this thanks to Demetri Spanos pointing me to this bug and the
@REM corresponding fix commit (which did not fix it):

@REM https://github.com/LuaJIT/LuaJIT/issues/336
@REM https://github.com/LuaJIT/LuaJIT/commit/82151a4514e6538086f3f5e01cb8d4b22287b14f

@REM Removing `2>/dev/null` is not portable but it does work for this specific case,
@REM and I think it just shuts up a warning.

set LUAJIT_PATH=LuaJIT-2.1
set YEAR=2021
set PATH=%PATH%;%USERPROFILE%\.gradle\toolchains\frc\%YEAR%\roborio\bin

set ATHENA_MAKE=frc%YEAR%-make
set ATHENA_FLAGS=HOST_CC="gcc -m32" CROSS=arm-frc%YEAR%-linux-gnueabi- TARGET_CFLAGS="-mcpu=cortex-a9 -mfloat-abi=softfp" TARGET_SYS="Linux"

pushd %LUAJIT_PATH%
    pushd src
        rmdir /Q /S dist
        mkdir dist
        mkdir dist\include
        copy *.h dist\include
        copy *.hpp dist\include
    popd

    @REM Windows build
    pushd src
        call msvcbuild.bat
        copy *.lib dist
        copy *.dll dist
    popd
    
    @REM roboRIO build
    %ATHENA_MAKE% clean %ATHENA_FLAGS%
    %ATHENA_MAKE% %ATHENA_FLAGS%
    pushd src
        copy *.a dist
        copy *.so dist
    popd

    @REM Make zip
    pushd src\dist
        tar -acf luajit.zip include *.lib *.dll *.a *.so
    popd
popd

move %LUAJIT_PATH%\src\dist\luajit.zip lib

endlocal

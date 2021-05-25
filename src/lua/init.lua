--[[
    This file will always be run before any other robot code is run.
    It provides the basic structure needed for the robot's Lua code
    to run.
--]]

package.path = package.path .. ";.\\src\\lua\\?.lua;.\\src\\lua\\?\\init.lua"

robot = {
    robotInit = function() end,
    robotPeriodic = function() end,
    disabledInit = function() end,
    disabledPeriodic = function() end,
    autonomousInit = function() end,
    autonomousPeriodic = function() end,
    teleopInit = function() end,
    teleopPeriodic = function() end,
    simulationInit = function() end,
    simulationPeriodic = function() end,
}
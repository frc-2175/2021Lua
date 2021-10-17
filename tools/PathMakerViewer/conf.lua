-- this fixes using lua's print() function on windows.

function love.conf(t)
	t.console = true
end
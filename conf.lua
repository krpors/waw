-- Configuration for all things etc. Invoked by Love2D automatically.
-- See https://love2d.org/wiki/Config_Files for more info.
function love.conf(t)
	t.version = "0.9.2"
	t.window.title = "Love2D Prototyping."
	t.window.width = 800
	t.window.height = 600 
	t.window.fsaa = 0
	t.window.display = 1

	-- for debugging on windows...
	t.console = true
end

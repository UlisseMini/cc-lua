-- Debug
local args = { ... }
if args[1] == "1" then
	term.clear()
	term.setCursorPos(1, 1)
	print("Listening...")
	serial.analogReceive("bottom", 15)
else
	serial.analogSend("top", "Hello World!", 15)
end

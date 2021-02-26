local term = require("term")
local os = require("os")
local event = require("event")
local gpu = require("component").gpu

local pwd = ""
local function filter(name, ...)
	if name == "key_down" then
		char = select(2, ...)
		if char == 13 then
			return true
		end
		pwd = pwd .. string.char(char)
		return false
	else
		return false
	end
end

event.listen("init", function()
	repeat
		term.clear()
		gpu.setForeground(0xFF0000)
		print("LOGIN\n")
		gpu.setForeground(0xFFFF00)
		io.write("Username: ")
		gpu.setForeground(0xFFFFFF)
		user = io.read()
		gpu.setForeground(0xFFFF00)
		print("Password: ")
		event.pullFiltered(filter)
	until(user=="user" and pwd=="password")
	gpu.setForeground(0x00FF00)
	print("Welcome back!")
	os.sleep(1)
	gpu.setForeground(0xFFFFFF)
end)

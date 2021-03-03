local modem = require("component").modem
local gpu = require("component").gpu
local event = require("event")
local os = require("os")
local term = require("term")
local shell = require("shell")
local fs = require("filesystem")

local version = "1.0.1"
local port = 22
local state = 0
local address = 0
local _, ops = shell.parse(...)

if ops["c"] == nil and ops["r"] == nil then
	gpu.setForeground(0xFF0000)
	print("Error: not enough parameters")
	gpu.setForeground(0xFFFFFF)
elseif ops["c"] and ops["r"] == nil then
	modem.open(port)
	
	local function receive(name, ...)
		local msg = select(5, ...)
		if name == "interrupted" then
			return true
		elseif name == "modem_message" then
			if state == 0 then
				if msg == "0" then
					state = 1
					gpu.setForeground(0x00FF00)
					print("Connection accepted from " .. select(2, ...))
					os.sleep(1)
					gpu.setForeground(0xFFFFFF)
					address = select(2, ...)
					term.clear()
					gpu.setForeground(0xFF0000)
					print("SSH Version " .. version)
					gpu.setForeground(0xFFFFFF)
				end
			elseif state == 1 then
				while true do
					io.write("> ")
					cmd = io.read()
					if cmd == "quit" or cmd == "exit" then
						print("Connection closed")
						os.sleep(2)
						return true
					elseif cmd == "file" then
						io.write("Type path: ")
						path = io.read()
						file = io.open(path, "r")
						if string.sub(path, 1, 1) == "/" then
							size = fs.size(path)
						else
							size = fs.size(shell.resolve(path))
						end
						if file == nil then
							gpu.setForeground(0xFF0000)
							print("Error: file not found.")
							gpu.setForeground(0xFFFFFF)
						else
							modem.send(address, port, fs.name(path))
							event.pull("modem_message")
							n = 0
							c = 0
							io.write("Progress:")
							while n ~= nil do
								n = file:read(1)
								c = c + 1
								term.clearLine()
								perc = (math.floor((c / size) * 100) / 10)
								if perc > 100 then
									perc = 100
								end
								io.write("Progress: " .. perc .. "%")
								modem.send(address, port, n)
								event.pull("modem_message")
							end
							file:close()
							print("\nTransfer completed")
						end
					elseif cmd == "clear" then
						term.clear()
					else
						print("Unknown command")
					end
				end
			end
		end
		return false
	end
	
	print("Waiting for connection...")
	event.pullFiltered(receive)
	modem.close(port)
	term.clear()
elseif ops["c"] == nil and ops["r"] then
	modem.open(port)
	modem.broadcast(port, "0")
	os.sleep(1.1)
	modem.broadcast(port, "0")
	file = nil
	address = nil
	i = false
	
	local function receive(name, ...)
		if name == "interrupted" then
			return true
		elseif name = "modem_message" then
			recv = select(5, ...)
			if recv == nil then
				return true
			elseif file == nil then
				address = select(2, ...)
				file = io.open(revc, "w")
				modem.send(address, port, "")
			elseif not i then
				file:write(recv)
				modem.send(address, port, "")
				i = true
			else
				i = false
			end
		end
	end
	
	event.pullFiltered(receive)
	modem.send(address, port, "")
	modem.close(port)
	term.clear()
end

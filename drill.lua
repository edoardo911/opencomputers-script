local robot = require("robot")

while robot.durability ~= nil do
	space = 0
	for i = 1, robot.inventorySize() do
		space = space + robot.space(i)
	end
	
	if space == 0 then
		break
	end
	
	if robot.detect() then
		robot.swing()
	end
	robot.up()
	if robot.detect() then
		robot.swing()
	end
	robot.down()
	robot.forward()
end

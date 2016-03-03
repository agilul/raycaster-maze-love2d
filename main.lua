-- Copyright 2016 Yat Hin Wong

player = {}
map = {}
raycast = require "raycast"
maze = require "maze"


function love.load()
	imgWidth, imgHeight = 800, 600
	love.window.setMode(imgWidth, imgHeight)
	love.mouse.setPosition(imgWidth/2, imgHeight/2)
	love.mouse.setVisible(false)
	
	raycast.init(imgWidth, imgHeight, 200, 0.8, 14)

	player.x = -1
	player.y = -1
	player.direction = math.pi/4
	
	map.create(30)
	--map.print()
	minimap = 0
	
	instructions = true
	instructionsTimeout = 10
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	local dx, dy = 0, 0

	-- go forward or backward
	local forward = 0
	if love.keyboard.isDown("w") then
		forward = 3
	elseif love.keyboard.isDown("s") then
		forward = -3
	end
	
	if math.abs(forward) > 0 then
		dx = math.cos(player.direction) * forward * dt
		dy = math.sin(player.direction) * forward * dt
	end
	
	-- strafe left or right
	local strafe = 0
	if love.keyboard.isDown("a") then
		strafe = -2
	elseif love.keyboard.isDown("d") then
		strafe = 2
	end
	
	if math.abs(strafe) > 0 then
		dx = dx + math.cos(player.direction + math.pi/2) * strafe * dt
		dy = dy + math.sin(player.direction + math.pi/2) * strafe * dt
	end
	
	-- checks if movement is allowed by the map
	if map.get(player.x + dx, player.y) <= 0 then
		player.x = player.x + dx
	end
	if map.get(player.x, player.y + dy) <= 0 then
		player.y = player.y + dy
	end
	
	-- turn left or right with mouse
	local turn = (love.mouse.getX() - imgWidth/2)*0.05
	love.mouse.setPosition(imgWidth/2, imgHeight/2)
	
	if math.abs(turn) > 0 then
		player.direction = (player.direction + turn*dt + 2*math.pi)%(2*math.pi)
	end
	
	if instructions then
		if instructionsTimeout < 0 then
			instructions = false
		end
		instructionsTimeout = instructionsTimeout - dt
	end
end

function love.draw()
	raycast.draw()
	
	if minimap == 1 then
		-- minimap maze top-down view
		love.graphics.setColor(255, 255, 255, 50)
		for i,v in ipairs(map.grid) do
			for j,w in ipairs(v) do
				if w == 1 then
					love.graphics.rectangle("fill", map.offsetX + (i-1)*map.blockSize, map.offsetY + (j-1)*map.blockSize, map.blockSize, map.blockSize)
				end
			end
		end
		
		-- minimap player's position
		love.graphics.setColor(255, 0, 0, 200)
		local cos1, sin1 = math.cos(player.direction)*map.blockSize*0.4, math.sin(player.direction)*map.blockSize*0.4
		local cos2, sin2 = math.cos(player.direction + math.pi/2)*map.blockSize*0.2, math.sin(player.direction + math.pi/2)*map.blockSize*0.2
		local pX, pY = map.offsetX + (player.x-1)*map.blockSize, map.offsetY + (player.y-1)*map.blockSize
		love.graphics.polygon("fill",
			pX + cos1, pY + sin1,
			pX - cos1 + cos2, pY - sin1 + sin2,
			pX - cos1 - cos2, pY - sin1 - sin2)
	end
	
	if instructions then
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("WASD to move\nMouse to turn\nTAB to toggle overlay map\nESC to exit", 0, 0, imgWidth, "left", 0, 4)
	end
end

function love.keypressed(key)
	if key == "tab" then
		minimap = 1 - minimap
	end
end

-- creates a new map and initializes variables for minimap rendering
function map.create(size)
	map.grid = maze.create(size)
	map.size = 2*size+1
	map.grid[2][1] = 0
	map.grid[map.size-1][map.size] = 0
	
	map.padding = 50
	map.blockSize = (imgHeight-map.padding)/map.size
	map.offsetX = (imgWidth - map.blockSize*map.size)/2
	map.offsetY = map.padding/2
end

function map.get(x, y)
	local x = math.floor(x)
	local y = math.floor(y)
	if x < 1 or x > map.size or y < 1 or y > map.size then
		return -1
	end
	return map.grid[x][y]
end
	
function map.print()
	for i,v in ipairs(map.grid) do
		for j,w in ipairs(v) do
			io.write(w == 1 and "X" or " ")
		end
		io.write("\n")
	end
end

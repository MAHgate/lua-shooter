function love.load()

new_game = false
game_play = true
game_over = false

-- Store info about our screen

screen_w , screen_h = 800 , 600

-- Create a table to hold the ship's details

ship = {}

ship.x = 400
ship.y = 550
ship.w = 10
ship.h = 10
ship.spd = 100
ship.vx = 0

-- Create a table to store our bullets

b_list = {}

-- Bullet info

b_gap = 0
b_rep = 1
b_vel = -200
b_w = 4
b_h = 4

-- Create a table to store our aliens

a_list = {}

grid_w , grid_h = 6 , 3

a_rep = 0.5

bx , by = 100 , 100
tx , ty = screen_w - bx , 300

gap_x = ( tx - bx ) / ( grid_w - 1 )
gap_y = ( ty - by ) / ( grid_h - 1 )

x_spd , y_spd = 40 , 10

n = 1

for j = 0 , grid_h - 1 do
	for i = 0 , grid_w - 1 do
		new_a = {}
		new_a.x = bx + gap_x * i
		new_a.y = by + gap_y * j
		new_a.w , new_a.h = 10 , 10
		new_a.vx , new_a.vy = x_spd , y_spd
		new_a.rep = a_rep
		new_a.gap = a_rep
		a_list[ #a_list + 1 ] = new_a
	end
end

end

-- Lots going on here, as it should be!

function love.update( dt )

if game_play then
	game_update( dt )
end

end

-- The usual draw routine

function love.draw()

if new_game then
	new_game_screen()
end

if game_over then
	game_over_screen()
end

if game_play then
	game_play_screen()
end

end

-- Draw game play screen

function game_play_screen()
	-- Draw the ship


	love.graphics.circle( "fill" , ship.x , ship.y , 10 )


	-- This iterator is weird: it is pulling out the index and the value in sequence

	for index , b in pairs( b_list ) do

		-- Draw a circle where the bullet is

		love.graphics.circle( "fill" , b.x , b.y , b.w )
	end

	-- Draw a circle where the alien is

	for index , a in pairs( a_list ) do
		love.graphics.circle( "fill" , a.x , a.y , a.w )
	end

end

-- Routine to run when game is playing

function game_update( dt )
	-- Trap the left and right key-presses and move ship

	ship.vx = 0

	if love.keyboard.isDown( "z") and ship.x>ship.w then
		ship.vx = -ship.spd
	end

	if love.keyboard.isDown( "x" ) and ship.x<screen_w-ship.w then
		ship.vx = ship.spd
	end

	ship.x = ship.x + ship.vx * dt

	-- Trap the space bar for firing bullets

	if b_gap>0 then
		b_gap = b_gap - dt
	end

	if love.keyboard.isDown( " " ) and b_gap <= 0 then
		b_gap = b_rep
		new_b = {}
		new_b.x , new_b.y  = ship.x , ship.y
		new_b.vy = b_vel
		new_b.w = b_w
		new_b.h = b_h

		b_list[ #b_list + 1 ] = new_b
	end

	-- Move the bullets that we have and delete if off screen

	for i = #b_list , 1 , -1 do
		b = b_list[ i ]
		b.y = b.y + b.vy * dt

		if b.y < b.w then
			table.remove( b_list , i )
		end
	end

	-- Move the aliens

	for i = #a_list , 1 , -1 do
		a =a_list[ i ]
		a.x = a.x + a.vx * dt
		a.y = a.y + a.vy * dt
		a.gap = a.gap - dt
		if a.gap <= 0 then
			a.gap = a.rep
			a.vx = -a.vx
		end
		if a.y+a.h > ship.y-ship.h then
			game_play = false
			game_over = true
		end
	end

	-- Check whether aliens and bullets have collided and react if so

	for i = #a_list , 1 , -1 do
		a = a_list[ i ]
		for j = #b_list , 1 , -1 do
			b = b_list[ j ]
			if math.abs( a.x - b.x ) < ( a.w + b.w ) then
				if math.abs( a.y - b.y ) < ( a.h + b.h ) then
					table.remove( a_list , i )
					table.remove( b_list , j )
					break
				end
			end
		end

	end
end


-- Screen to display at the end of a game
function game_over_screen()
-- First draw the game play as it finished
game_play_screen()

love.graphics.print( "Game Over" , 100 , 100 )

end


-- Reset the counter when the space bar is released

function love.keyreleased( key )
	if key == " " then
		b_gap = 0
	end
end

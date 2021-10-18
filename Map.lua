
require 'Util'

require 'Player'


Map = Class {}

ROCK = 6
GRASS1 = 2
GRASS2 = 3
GRASS3 = 4
GRASS4 = 5
TRAP = 1

local SCROLL_SPEED = 60

function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/map.png')
    self.tileWidth= 64
    self.tileHeight = 64
    self.mapWidth = 15
    self.mapHeight = 15
    self.tiles = {}
    self.camX = 0
    self.camY = 0

    self.trapCounter = 0
    self.trapTimer = 0
    self.trapLimit = 1

    self.music = love.audio.newSource('sounds/run.mp3', 'static')
    self.player = Player(self)
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    local x = 1
    local y = 1

    while x <= self.mapWidth + 1 do
        
        if x == self.mapWidth + 1 then              -- if the end of map is reached go to next row
            if y ~= self.mapHeight + 1 then         -- only if its not already the last row
                x = 1
                y = y + 1
            else
                x = x + 1                           -- if its the last row, break from while loop
            end
        end

        if (x == 1 and y == 1) or math.random(5) == 1 then             -- 20% chance of grass1

            self:setTile(x, y, GRASS1)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 2 then         -- 20% chance of grass2

            self:setTile(x, y, GRASS2)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 3 then         -- 20% chance of grass3

            self:setTile(x, y, GRASS3)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 4 then         -- 20% chance of grass4

            self:setTile(x, y, GRASS4)
            
            x = x + 1 --go to next column
            
        elseif x ~= 1 and math.random(5) == 5 then        -- 20% chance of rock

            self:setTile(x, y, ROCK)
            x = x + 1 --go to next columnn

        end

    end

    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()
end

function Map:setTile(x, y, tile)
    self.tiles[(y-1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y-1) * self.mapWidth + x]
end

function Map:update(dt)

    self.camX = math.max(0, -- buffer that doesnt allow the camera to move left of the screen
    math.min(self.player.x - VIRTUAL_WIDTH / 2, -- allows the player to have half of screen size to its left
    math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x))) -- buffer that doesnt allow the camera to move right of the screen

    self.camY = math.min(0,
    math.max(self.player.y - VIRTUAL_HEIGHT / 2,
    math.max(self.mapHeightPixels - VIRTUAL_HEIGHT, self.player.y)))

    if gameState == 'play' or gameState == 'win' then
        self.trapTimer = self.trapTimer + dt
    end

    if self.trapTimer > self.trapLimit then

        self.trapTimer = 0
        self.trapLimit = self.trapLimit * 0.97

        local randomX = math.random(self.mapWidth)
        local randomY = math.random(self.mapHeight)
        local randomTile = self:getTile(randomX, randomY)
        
        if randomTile == GRASS1 or randomTile == GRASS2 or randomTile == GRASS3 or randomTile == GRASS4 then
            self:setTile(randomX, randomY, TRAP)
            self.trapCounter = self.trapCounter + 1
        end
    end

    if self.trapCounter == 60 then
        gameState = 'win'
        self.player.dx = 0
        self.player.dy = 0
    elseif self.trapCounter >= 61 then
        self.trapLimit = 60
        self.player.dx = 0
        self.player.dy = 0
    end

    self.player:update(dt)
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:collides(tile)
    
    local collidables = {
        ROCK
    }

    for i,v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false

end

function Map:steps(tile)
    
    local steppables = {
        TRAP
    }

    for i,v in ipairs(steppables) do
        if tile.id == v then
            return true
        end
    end

    return false

end


function Map:render()

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do

            local tile = self:getTile(x, y)
            local Quad = self.tileSprites[tile]
               
            love.graphics.draw(self.spritesheet, Quad,
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)

        end
    end

    self.player:render()

end

function Map:reset()

    self.camX = 0
    self.camY = 0
    self.player = Player(self)

    self.trapCounter = 0
    self.trapTimer = 0
    self.trapLimit = 0.7

    local x = 1
    local y = 1

    while x <= self.mapWidth + 1 do
        
        if x == self.mapWidth + 1 then              -- if the end of map is reached go to next row
            if y ~= self.mapHeight + 1 then         -- only if its not already the last row
                x = 1
                y = y + 1
            else
                x = x + 1                           -- if its the last row, break from while loop
            end
        end

        if (x == 1 and y == 1) or math.random(5) == 1 then             -- 20% chance of grass1

            self:setTile(x, y, GRASS1)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 2 then         -- 20% chance of grass2

            self:setTile(x, y, GRASS2)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 3 then         -- 20% chance of grass3

            self:setTile(x, y, GRASS3)
            
            x = x + 1 --go to next column

        elseif math.random(5) == 4 then         -- 20% chance of grass4

            self:setTile(x, y, GRASS4)
            
            x = x + 1 --go to next column
            
        elseif x ~= 1 and math.random(5) == 5 then        -- 20% chance of rock

            self:setTile(x, y, ROCK)
            x = x + 1 --go to next columnn

        end

    end

end
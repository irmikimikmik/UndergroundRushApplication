require 'Animation'

Player = Class{}

local MOVE_SPEED = 70

function Player:init(map)
    self.map = map
    self.width = 32
    self.height = 51

    self.x = 0
    self.y = map.tileHeight - self.height

    self.texture = love.graphics.newImage('graphics/animation.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

    self.state = 'idle'
    self.direction = 'down'

    self.dx = 0
    self.dy = 0

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture ,
            frames = {
                self.frames[19]
            },
            interval = 1
        },
        ['up'] = Animation {
            texture = self.texture ,
            frames = {
                self.frames[1], self.frames[2], self.frames[3], self.frames[4], self.frames[5], self.frames[6],
                self.frames[7], self.frames[8], self.frames[9]
            },
            interval = 0.10
        },
        ['left'] = Animation {
            texture = self.texture ,
            frames = {
                self.frames[10], self.frames[11], self.frames[12], self.frames[13], self.frames[14], self.frames[15],
                self.frames[16], self.frames[17], self.frames[18]
            },
            interval = 0.10
        },
        ['down'] = Animation {
            texture = self.texture ,
            frames = {
                self.frames[20], self.frames[21], self.frames[22], self.frames[23], self.frames[24], self.frames[25], 
                self.frames[26], self.frames[27]
            },
            interval = 0.10
        },
        ['right'] = Animation {
            texture = self.texture ,
            frames = {
                self.frames[28], self.frames[29], self.frames[30], self.frames[31], self.frames[32], self.frames[33],
                self.frames[34], self.frames[35], self.frames[36]
            },
            interval = 0.10
        },
    }

    self.animation = self.animations['idle']

    self.behaviors = {
    
        ['idle'] = function(dt)

            if love.keyboard.isDown('w') then --moves up
                self.dy = -MOVE_SPEED
                self.animation = self.animations['up']
                self.direction = 'up'
                self.animations['up']:restart()
                self.state = 'walking'
            elseif love.keyboard.isDown('a') then --moves left
                self.dx = -MOVE_SPEED
                self.animation = self.animations['left']
                self.direction = 'left'
                self.animations['left']:restart()
                self.state = 'walking'
            elseif love.keyboard.isDown('s') then --moves down
                self.dy = MOVE_SPEED
                self.animation = self.animations['down']
                self.direction = 'down'
                self.animations['down']:restart()
                self.state = 'walking'
            elseif love.keyboard.isDown('d') then --moves right
                self.dx = MOVE_SPEED
                self.animation = self.animations['right']
                self.direction = 'right'
                self.animations['right']:restart()
                self.state = 'walking'
            else
                self.dx = 0
                self.dy = 0
                self.animation = self.animations['idle']
            end
        end,

        ['walking'] = function(dt)
            if love.keyboard.isDown('w') then --moves up
                self.dy = -MOVE_SPEED
                self.dx = 0
                self.animation = self.animations['up']
                self.direction = 'up'
            elseif love.keyboard.isDown('a') then --moves left
                self.dx = -MOVE_SPEED
                self.dy = 0
                self.animation = self.animations['left']
                self.direction = 'left'
            elseif love.keyboard.isDown('s') then --moves down
                self.dy = MOVE_SPEED
                self.dx = 0
                self.animation = self.animations['down']
                self.direction = 'down'
            elseif love.keyboard.isDown('d') then --moves right
                self.dx = MOVE_SPEED
                self.dy = 0
                self.animation = self.animations['right']
                self.direction = 'right'
            else
                self.dx = 0
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkUpCollision()
            self:checkDownCollision()
            self:checkSteppingOnTrap()

        end
    }
end

function Player:update(dt)

    self.behaviors[self.state](dt)
    self.animation:update(dt)

    if self.x >= 960 - self.width then
        self.x = math.min(self.x + (self.dx * dt), 960 - self.width)
    elseif self.x <= 0 then
        self.x = math.max(self.x + (self.dx * dt), 0)
    else 
        self.x = self.x + (self.dx * dt)
    end

    if self.y >= 640 - self.height then
        self.y = math.min(self.y + (self.dy * dt), 640 - self.height)
    elseif self.y <= 0 then
        self.y = math.max(self.y + (self.dy * dt), 0)
    else 
        self.y = self.y + (self.dy * dt)
    end
    
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y - 1)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y - 1).x * self.map.tileWidth + 7
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y - 1)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width - 7
        end
    end
end

-- checks two tiles to our upper side to see if a collision occurred
function Player:checkUpCollision()
    if self.dy < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y - 1)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y - 1)) then
            
            -- if so, reset velocity and position
            self.dy = 0
            self.y = self.map:tileAt(self.x - 1, self.y - 1).y * self.map.tileHeight + 7
        end
    end
end

-- checks two tiles to our lower side to see if a collision occurred
function Player:checkDownCollision()
    if self.dy > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position
            self.dy = 0
            self.y = (self.map:tileAt(self.x, self.y + self.height - 1).y - 1) * self.map.tileHeight - self.height - 7
        end
    end
end

function Player:checkSteppingOnTrap()

    if self.map:steps(self.map:tileAt(self.x + (self.width / 2) - 1, self.y + (self.height / 2) - 1)) then

        self.texture = love.graphics.newImage('graphics/emptyanimation.png')
        gameState = 'loose'
        self.dx = 0
        self.dy = 0
    end

end

function Player:render()

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), 0, 1, 1, self.width / 2, self.height / 2)
    
end

function Player:reset()
    
    self.x = 0
    self.y = map.tileHeight - self.height
    
    self.state = 'idle'
    self.direction = 'down'

    self.dx = 0
    self.dy = 0
    
end
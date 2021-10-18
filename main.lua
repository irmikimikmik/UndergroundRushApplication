
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 640

push = require 'push'
Class = require 'class'

require 'Util'
require 'Map'
require 'Animation'
require 'Player'

function love.load()

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle("underground rush")

    Font32 = love.graphics.newFont('font.ttf', 32)
    Font28 = love.graphics.newFont('font.ttf', 28)
    Font20 = love.graphics.newFont('font.ttf', 20)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fulllscreen = false ,
        resizable = false ,
        vsync = true
    })

    map = Map()

    player = Player(map)

    love.keyboard.keysPressed = {}

    gameState = 'start'

end

function love.update(dt)
    map:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'space' then
        gameState = 'start'
        map:reset()
        player:reset()
    end

    if gameState == 'start' then
        if key == 'w' or key == 'a' or key == 's' or key == 'd' then
            gameState = 'play'
        end
    end

    love.keyboard.keysPressed[key] = true
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))

    love.graphics.clear(108/255, 140/255, 1, 1)

    map:render()

    if gameState == 'start' then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', map.camX + 64, map.camY + 64, 512, 512, 60, 60)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(Font28)
        love.graphics.printf('Hello SPY041. Your goal is to run away from the traps that the underground spy is digging. No matter what happens, try not to fall into the traps!', map.camX + 90, map.camY + 94, 450, 'center')
        love.graphics.setFont(Font32)
        love.graphics.printf('If you survive even until the underground spy covers 50% of the map, you become the winner and the greates spy.', map.camX + 90, map.camY + 290, 450, 'center')
        love.graphics.setFont(Font20)
        love.graphics.printf('Press w, a, s or d to play...', map.camX + 90, map.camY + 500, 450, 'center')
    elseif gameState == 'win' then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', map.camX + 64, map.camY + 64, 512, 145, 60, 60)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(Font32)
        love.graphics.printf('CONGRADULATIONS! YOU WON, SPY041.', map.camX + 90, map.camY + 94, 450, 'center')
        love.graphics.setFont(Font20)
        love.graphics.printf('Press the space bar to start again...', map.camX + 90, map.camY + 170, 450, 'center')
    elseif gameState == 'loose' then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', map.camX + 64, map.camY + 64, 512, 145, 60, 60)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(Font32)
        love.graphics.printf('Sorry... You lost, SPY041. :(', map.camX + 90, map.camY + 94, 450, 'center')
        love.graphics.setFont(Font20)
        love.graphics.printf('Press the space bar to start again...', map.camX + 90, map.camY + 170, 450, 'center')
    end

    push:apply('end')
end
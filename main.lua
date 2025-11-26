function love.load()
    wW, wH = love.graphics.getDimensions()
    PADDLES = {
        {
            posKey = "s",
            negKey = "w",
            ranges = {
                {10, 10},
                {10, wH - 10}
            }
        }
    }
end

function love.update(dt)
    for i, v in ipairs(PADDLES) do
        if love.keyboard.isDown(v.posKey)
    end
end

function love.draw()
    
end


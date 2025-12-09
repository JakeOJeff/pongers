local ai = {
    error = 0,
    timer = 0,
    reactionTime = 0.1,
    targetY = 0
}

function ai:update(dt)
    
    self.timer = self.timer + dt
    if self.timer >= self.reactionTime then
        self.timer = 0
            self.targetY = math.max(10, math.min(wH - 10, BALL.y + math.tan(BALL.angle) * (BALL.x - PADDLES[2].x) + math.random(-self.error, self.error)))

    end
end

return ai
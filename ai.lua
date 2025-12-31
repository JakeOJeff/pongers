local ai = {
    targetY = 0,
    y = 0,
    paddleId = 2
}

function ai:update(dt)
        self.targetY = math.min(wH - PADDLES[self.paddleId].h - 10,math.max(10, BALL.y + math.tan(BALL.angle) * (BALL.x - PADDLES[self.paddleId].x)))
end

return ai

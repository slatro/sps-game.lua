-- game.lua

local players = {}
local choices = {"rock", "paper", "scissors"}

local function getRandomChoice()
    return choices[math.random(1, 3)]
end

local function compareChoices(choice1, choice2)
    if choice1 == choice2 then
        return "It's a tie!"
    elseif (choice1 == "rock" and choice2 == "scissors") or
           (choice1 == "paper" and choice2 == "rock") or
           (choice1 == "scissors" and choice2 == "paper") then
        return "Player 1 wins!"
    else
        return "Player 2 wins!"
    end
end

local function getPlayerChoice(playerId)
    return players[playerId]
end

local function setPlayerChoice(playerId, choice)
    players[playerId] = choice
end

local function clearPlayerChoice(playerId)
    players[playerId] = nil
end

local function joinGame(playerId)
    -- Burada oyuncunun katılımını işle
    -- Örneğin, oyuncuyu oyuncular listesine ekle
    -- veya başka bir işlem yap
    print("Player " .. playerId .. " joined the game.")
end

local function makeChoice(playerId)
    -- Burada oyuncunun seçim yapmasını sağla
    -- Örneğin, oyuncunun rastgele bir seçim yapmasını sağla
    local choice = getRandomChoice()
    setPlayerChoice(playerId, choice)
    print("Player " .. playerId .. " made a choice: " .. choice)
end

local function finishPoints(playerId)
    -- Burada puanları bitirme işlemini gerçekleştir
    -- Örneğin, oyuncunun seçimini karşılaştır ve sonucu belirle
    local playerChoice = getPlayerChoice(playerId)
    local opponentChoice = getRandomChoice() -- Rakip oyuncunun rastgele bir seçim yapması için
    local result = compareChoices(playerChoice, opponentChoice)
    print("Player " .. playerId .. " finished points. Result: " .. result)
end

return {
    joinGame = joinGame,
    makeChoice = makeChoice,
    finishPoints = finishPoints
}

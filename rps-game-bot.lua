-- Bot Variables
BotName = "RockPaperScissorsBot"
local stepNumber = 1
local stopNumber = 9
local runStatus = 'disable'
local currentNumber = 0
local GameTarget = 'io9gWQrlmyMeF3HS20GgbMkxokjJKAIeZMGa8180efw'

local function sendChoice()
    local choices = { "Rock", "Paper", "Scissor" }
    local choice = choices[math.random(1, #choices)]
    log("Sending choice: " .. choice)
    ao.send({
        Target = GameTarget,
        Action = "UserChoice",
        Data = choice
    })
end

local function finishGame()
    ao.send({
        Target = GameTarget,
        Action = "FinishPoints",
        Data = BotName
    })
    currentNumber = 0
end

local function log(message)
    print("[Bot Log] " .. message)
end

local function handleResult(Msg)
    currentNumber = currentNumber + 1
    log('Round Result: ' .. Msg.Data)
    if (currentNumber >= stepNumber) then
        stepNumber = stepNumber + 1
        finishGame()
    else
        sendChoice()
    end
end

local function handleFinish(Msg)
    log(Msg.Data)
    if stopNumber < stepNumber then
        stopPlaying()
        return
    end
    sendChoice()
end

function startPlaying()
    runStatus = 'enable'
    stepNumber = 1
    currentNumber = 0
    log('Bot started playing')
    sendChoice()
end

function stopPlaying()
    runStatus = 'disable'
    log('The bot has finished running')
end

-- User Choice Result Handler
Handlers.add(
    "HandlerUserChoiceResult",
    Handlers.utils.hasMatchingTag("Action", "UserChoiceResult"),
    function(Msg)
        if runStatus == 'disable' then
            log("HandlerUserChoiceResult ignored: Bot is disabled")
            return
        end
        log("HandlerUserChoiceResult called with Data: " .. Msg.Data)
        handleResult(Msg)
    end
)

-- Finish Points Result Handler
Handlers.add(
    "HandlerFinishPointsResult",
    Handlers.utils.hasMatchingTag("Action", "FinishPointsResult"),
    function(Msg)
        if runStatus == 'disable' then
            log("HandlerFinishPointsResult ignored: Bot is disabled")
            return
        end
        log("HandlerFinishPointsResult called with Data: " .. Msg.Data)
        handleFinish(Msg)
    end
)

-- Current Points Handler
Handlers.add(
    "HandlerCurrentPoints",
    Handlers.utils.hasMatchingTag("Action", "CurrentPoints"),
    function(Msg)
        log("Current Points: " .. Msg.Data)
    end
)

-- Rank List Handler
Handlers.add(
    "HandlerRankList",
    Handlers.utils.hasMatchingTag("Action", "RankList"),
    function(Msg)
        log("Rank List: " .. Msg.Data)
    end
)

-- Your Turn Handler for Bot

Handlers.add(
    "HandlerYourTurn",
    Handlers.utils.hasMatchingTag("Action", "YourTurn"),
    function(Msg)
        if runStatus == 'enable' then
            log("Bot's turn to play.")
            sendChoice()
        end
    end
)

Handlers.add(
    "HandlerJoinGameResult",
    Handlers.utils.hasMatchingTag("Action", "JoinGameResult"),
    function(Msg)
        log("HandlerJoinGameResult called")
        log(Msg.Data)  -- Gelen veriyi logla
        enableBot()  -- Botu etkinleştir
    end
)
Handlers.add(
    "HandlerUserChoice",
    Handlers.utils.hasMatchingTag("Action", "UserChoice"),
    function(Msg)
        log("HandlerUserChoice called")
        -- Kalan işlev kodları
    end
)

-- Bu işlev botun durumunu etkinleştirir
function enableBot()
    runStatus = 'enable'
    log("Bot is enabled.")
end

Handlers.add(
    "HandlerGetMembers",
    Handlers.utils.hasMatchingTag("Action", "MembersList"),
    function(Msg)
        log("Members List: " .. Msg.Data)
    end
)

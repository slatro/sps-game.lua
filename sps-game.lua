-- Game Variables
successText = 'Win'
failedText = "Lose"
drawText = "Draw"
rankList = rankList or {}
pointsList = pointsList or {}
members = members or {}
gameTimeTag = gameTimeTag or ""
turnOrder = turnOrder or {}  -- Oyuncuların sırası
currentTurnIndex = currentTurnIndex or 1  -- Şu anki oyuncunun sırası
timeout = 60  -- 60 saniye zaman aşımı
timer = nil  -- Zamanlayıcıyı saklamak için
options = { "Rock", "Paper", "Scissor" }

local function guid()
    local seed = { 'e', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
    local tb = {}
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    local sid = table.concat(tb)
    return string.format('%s-%s-%s-%s-%s',
            string.sub(sid, 1, 8),
            string.sub(sid, 9, 12),
            string.sub(sid, 13, 16),
            string.sub(sid, 17, 20),
            string.sub(sid, 21, 32)
    )
end

local function getComputerChoice()
    return options[math.random(1, #options)]
end

local function getMembers()
    local memberList = {}
    for id, _ in pairs(members) do
        table.insert(memberList, id)
    end
    return memberList
end

local function addMember(id)
    if not members[id] then
        members[id] = true
        table.insert(turnOrder, id)
    end
end

local function getNextTurn()
    currentTurnIndex = currentTurnIndex + 1
    if currentTurnIndex > #turnOrder then
        currentTurnIndex = 1
    end
    return turnOrder[currentTurnIndex]
end

local function getCurrentTurn()
    return turnOrder[currentTurnIndex]
end

local function joinStatistic(id)
    addMember(id)
end

local function getPersonPoints(id)
    return pointsList[id] or 0
end

local function sortRankList()
    table.sort(rankList, function(a, b)
        return a.points > b.points
    end)
end

local function getGameTimeTag()
    local currentTime = os.date("*t", os.time())
    return currentTime.year .. '-' .. currentTime.month
end

local function checkRankExpire()
    local currentTag = getGameTimeTag()
    if gameTimeTag ~= currentTag then
        for i = 1, 10 do
            if rankList[i] and rankList[i].pid then
                ao.send({ Target = ao.id, Action = "Transfer", Recipient = rankList[i].pid, Quantity = tostring(100 - (i - 1) * 10) })
            end
        end
        rankList = {}
        gameTimeTag = currentTag
    end
end

local function log(message)
    print("[LOG] " .. message)
end

local function determineWinner(UserChoice, computerChoice)
    if UserChoice == computerChoice then
        return drawText
    elseif (UserChoice == "Rock" and computerChoice == "Scissor") or
           (UserChoice == "Paper" and computerChoice == "Rock") or
           (UserChoice == "Scissor" and computerChoice == "Paper") then
        return successText
    else
        return failedText
    end
end

local function calculatePoints(result, points)
    if result == successText then
        points = points + 1
    elseif result == failedText then
        points = points - 1
    end
    return points
end

local function startTimer()
    if timer then
        timer:stop()
    end
    timer = uv.new_timer()
    timer:start(timeout * 1000, 0, function()
        log("Turn skipped due to timeout")
        skipTurn()
    end)
end

local function skipTurn()
    local nextTurn = getNextTurn()
    ao.send({
        Target = nextTurn,
        Action = "YourTurn",
        Data = "It's your turn now!"
    })
    startTimer()
end

-- Handler Functions

-- Get All Rank List
Handlers.add(
    "HandlerGetRank",
    Handlers.utils.hasMatchingTag("Action", "GetRank"),
    function(Msg)
        log("HandlerGetRank called")
        if #rankList == 0 then
            ao.send({
                Target = Msg.From,
                Action = "RankList",
                Data = "rankList : No Any Person"
            })
            return
        end

        checkRankExpire()
        local page = tonumber(Msg.Data)
        if (page == nil) then
            page = 1
        end
        local startPos = (page - 1) * 10 + 1
        if (startPos > #rankList) then
            startPos = 1
        end
        local endPos = startPos + 10
        local maxPos = math.min(endPos, #rankList)
        local retText = ''
        for i = startPos, maxPos do
            retText = retText .. 'Rank ' .. i .. " : " .. rankList[i].name .. " " .. rankList[i].points
            if startPos ~= maxPos then
                retText = retText .. '\n'
            end
        end
        ao.send({
            Target = Msg.From,
            Action = "RankList",
            Data = retText
        })
    end
)

-- Get Current Points
Handlers.add(
    "HandlerGetPoints",
    Handlers.utils.hasMatchingTag("Action", "GetPoints"),
    function(Msg)
        log("HandlerGetPoints called")
        local text = getPersonPoints(Msg.From)
        log(text .. " Points")
        ao.send({
            Target = Msg.From,
            Action = "CurrentPoints",
            Data = text .. ""
        })
    end
)

-- Finish Current Points
Handlers.add(
    "HandlerFinishPoints",
    Handlers.utils.hasMatchingTag("Action", "FinishPoints"),
    function(Msg)
        log("HandlerFinishPoints called")
        checkRankExpire()
        
        local uuid = guid()
        log("Generated UUID: " .. uuid)
        
        table.insert(rankList, {
            points = pointsList[Msg.From],
            name = Msg.Data,
            uuid = uuid,
            pid = Msg.From
        })
        log("Updated rankList with new entry")
        
        sortRankList()
        log("Sorted rankList")
        
        pointsList[Msg.From] = 0
        log("Reset points for: " .. Msg.From)
        
        local current = "Unknown"
        for index, obj in pairs(rankList) do
            if obj.uuid == uuid then
                current = index
                break
            end
        end
        log("Current rank: " .. current)

        ao.send({
            Target = Msg.From,
            Action = "FinishPointsResult",
            Data = "Hey! You ranked " .. current
        })
        log("FinishPointsResult sent to " .. Msg.From)
    end
)


-- User Makes a Choice
Handlers.add(
    "HandlerUserChoice",
    Handlers.utils.hasMatchingTag("Action", "UserChoice"),
    function(Msg)
        log("HandlerUserChoice called")
        
        local currentTurn = getCurrentTurn()
        log("Current Turn: " .. currentTurn .. ", Message From: " .. Msg.From)
        
        if Msg.From ~= currentTurn then
            ao.send({
                Target = Msg.From,
                Action = "Error",
                Data = "It's not your turn!"
            })
            log("Error: It's not your turn!")
            return
        end

        if timer then
            timer:stop()
        end
        
        local UserChoice = Msg.Data
        log("UserChoice: " .. UserChoice)
        
        local computerChoice = getComputerChoice()
        log("ComputerChoice: " .. computerChoice)
        
        local result = determineWinner(UserChoice, computerChoice)
        log("Result: " .. result)
        
        local points = getPersonPoints(Msg.From)
        log("Current Points: " .. points)
        
        points = calculatePoints(result, points)
        log("Updated Points: " .. points)
        
        pointsList[Msg.From] = points
        joinStatistic(Msg.From)
        
        ao.send({
            Target = Msg.From,
            Action = "UserChoiceResult",
            Data = "Your Choice: " .. UserChoice .. ", Computer's Choice: " .. computerChoice .. ", Result: " .. result .. ", Total Points: " .. points
        })
        log("UserChoiceResult sent")

        local nextTurn = getNextTurn()
        log("Next Turn: " .. nextTurn)
        
        ao.send({
            Target = nextTurn,
            Action = "YourTurn",
            Data = "It's your turn now!"
        })
        log("YourTurn sent to " .. nextTurn)
        
        startTimer()
    end
)


-- Join Game
Handlers.add(
    "HandlerJoinGame",
    Handlers.utils.hasMatchingTag("Action", "JoinGame"),
    function(Msg)
        log("HandlerJoinGame called")
        addMember(Msg.From)
        ao.send({
            Target = Msg.From,
            Action = "JoinGameResult",
            Data = "You have joined the game!"
        })
    end
)

-- Get All Members Handler
Handlers.add(
    "HandlerGetMembers",
    Handlers.utils.hasMatchingTag("Action", "GetMembers"),
    function(Msg)
        local membersList = getMembers()
        local retText = 'Members:\n'
        for i, member in ipairs(membersList) do
            retText = retText .. i .. ": " .. member .. "\n"
        end
        ao.send({
            Target = Msg.From,
            Action = "MembersList",
            Data = retText
        })
    end
)



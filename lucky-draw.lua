-- PID: 8oLvNsr45G4kFPYWIsyPU0EDHjPCcA_ywWo26E4Lgh4

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
        table.insert(rankList, {
            points = pointsList[Msg.From],
            name = Msg.Data,
            uuid = uuid,
            pid = Msg.From
        })
        sortRankList()
        pointsList[Msg.From] = 0
        local current = "Unknown"
        for index, obj in pairs(rankList) do
            if obj.uuid == uuid then
                current = index
                break
            end
        end

        ao.send({
            Target = Msg.From,
            Action = "FinishPointsResult",
            Data = "Hey! You ranked " .. current
        })
    end
)

-- Roll Dice and Draw Card
Handlers.add(
    "HandlerRollDiceAndDrawCard",
    Handlers.utils.hasMatchingTag("Action", "RollDiceAndDrawCard"),
    function(Msg)
        log("HandlerRollDiceAndDrawCard called")
        
        local currentTurn = getCurrentTurn()
        if Msg.From ~= currentTurn then
            ao.send({
                Target = Msg.From,
                Action = "Error",
                Data = "It's not your turn!"
            })
            return
        end

        if timer then
            timer:stop()
        end
        
        local diceNumber = getDiceNumber()
        local diceText = getDiceText(diceNumber)
        local cardText = getCard()
        
        local points = getPersonPoints(Msg.From)
        points = calculatePoints(diceNumber, cardText, points)
        
        pointsList[Msg.From] = points
        joinStatistic(Msg.From)
        
        ao.send({
            Target = Msg.From,
            Action = "RollDiceAndDrawCardResult",
            Data = "Dice: " .. diceText .. ", Card: " .. cardText .. ", Total Points: " .. points
        })
        
        local nextTurn = getNextTurn()
        ao.send({
            Target = nextTurn,
            Action = "YourTurn",
            Data = "It's your turn now!"
        })
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

-- Get All Members
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

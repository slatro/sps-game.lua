Start game with —>  

GameTarget = "3cNcrrATtW8GelRYGNL1UTrFM97mZxb2o1ppp91umik"


1. Joining the Game

To join the game, users need to send the `JoinGame` command.

Send({ Target = GameTarget, Action = "JoinGame" })

2. Player Turn

The game progresses sequentially, and each player must make a choice (Rock, Paper, or Scissors) when it's their turn.

3. Making a Choice

Players use the `UserChoice` command to make their choice.

Send({ Target = GameTarget, Action = "UserChoice", Data = "Rock" })

4. Result and Points

After the player makes a choice, the result is determined, and the player's total points are updated. The result and point information are sent to the player.

5. Querying Points

Players can query their current points using the `GetPoints` command.

Send({ Target = GameTarget, Action = "GetPoints" })

6. Finishing Points

Players can finish their current points and add them to the ranking by using the `FinishPoints` command. Player Name = PID

Send({ Target = GameTarget, Action = "FinishPoints", Data = "slatrobot" })

7. Viewing the Ranking List

Players can view the current ranking list using the `GetRank` command.

Send({ Target = GameTarget, Action = "GetRank" })

8. Viewing Members

Players can view the current members by using the `GetMembers` command.

Send({ Target = GameTarget, Action = "GetMembers" })

9. User Choice Result

Send({ Target = GameTarget, Action = "UserChoiceResult" })

function InitVars()
	--Config your tournament
	--Amount of players
	PlayerMax=5
	--Number of rounds to play
	RoundMax=5
	ActualRound=1
	--Scores for every player
	ScoreP1 = 0
	ScoreP2 = 0
	--Create leaderboards for every round
	CreateLeaderBoards();
end

function GetRoundSong(round)
	local Songs = {
		[1] = "Mayu",
		[2] = "Profession",
		[3] = "Blacksphere",
		[4] = "Ayakashi",
		[5] = "Pieces of a Dream"
	};
	return Songs[round] or "fallback"
end

function GetRoundDifficulty(round)
	local Difficulties = {
		[1] = "Difficulty_Challenge",
		[2] = "Difficulty_Challenge",
		[3] = "Difficulty_Challenge",
		[4] = "Difficulty_Challenge",
		[5] = "Difficulty_Challenge"
	};
	return Difficulties[round] or "Difficulty_Hard"
end

function CreateLeaderBoards()
	Rankings = {};
end

function PushScores()
	if GAMESTATE:IsHumanPlayer(0) then
        Rankings[table.getn(Rankings)+1]=ScoreP1
    end
    if GAMESTATE:IsHumanPlayer(1) then
        Rankings[table.getn(Rankings)+1]=ScoreP2
    end
end

function GetStyle(index)
	local Style = {
		[1] = "single",
		[2] = "versus",
		[3] = "double"
	};
	return Style[index] or "versus"
end

function NextStage()
	ActualRound = ActualRound + 1;
	PlayerMax = math.ceil(table.getn(Rankings)/2)
	ScoreP1 = 0
	ScoreP2 = 0
	Rankings = {};
end

function CodeStart()
	--Set song
	local newSong = SONGMAN:FindSong(GetRoundSong(ActualRound));
		
	if newSong then
	local newStep = newSong:GetAllSteps()[1]
		SOUND:PlayOnce(THEME:GetPath(4, '', 'POW.ogg'))
		GAMESTATE:SetCurrentSong(newSong)
		GAMESTATE:JoinPlayer(0)
		GAMESTATE:JoinPlayer(1)
		GAMESTATE:SetCurrentSteps(0, newStep)
		GAMESTATE:SetCurrentSteps(1, newStep)
		SCREENMAN:SystemMessage("Song found! Round "..ActualRound.." is chosen...");
		SCREENMAN:SetNewScreen("ScreenGameplay");
	else
		SCREENMAN:SystemMessage("No song found!");
	end
end;

function CodeContinue()
	SCREENMAN:SystemMessage("Next stage...");
	SCREENMAN:SetNewScreen('ScreenLobby');
	NextStage();
	PREFSMAN:SetPreference('DelayedScreenLoad', 1)
	
	if ActualRound > RoundMax then
		SCREENMAN:SystemMessage("End of tournament! Thanks for playing!");
		SCREENMAN:SetNewScreen('ScreenTitleMenu');
	end
end;
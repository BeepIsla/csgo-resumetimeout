#include <sourcemod>
#include <sdktools>
#include <cstrike>

float remainingTimeCT = -1.0; // Default value is -1.0
float remainingTimeT = -1.0; // To avoid issues
bool isVoteActive = false;
bool blockNewVotes = false;
bool alreadyVoted[MAXPLAYERS];
new Handle:voteTimeout = null;

public void OnPluginStart() {
	AddCommandListener(Listener_Vote, "vote");
	AddCommandListener(Listener_Callvote, "callvote");

	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("cs_intermission", Event_Intermission, EventHookMode_Post);

	HookUserMessage(GetUserMessageId("VotePass"), Msg_VotePass);
	HookUserMessage(GetUserMessageId("VoteFailed"), Msg_VoteFail);
	HookUserMessage(GetUserMessageId("VoteStart"), Msg_VoteStart);
}

// FIXME: Values do not reset when using "mp_restartgame"

public void OnMapStart() {
	remainingTimeCT = -1.0; // Default value is -1.0
	remainingTimeT = -1.0; // To avoid issues
	isVoteActive = false;
	blockNewVotes = false;

	for (int i = 0; i < MAXPLAYERS; i++) {
		alreadyVoted[i] = false;
	}

	if (voteTimeout != null) {
		KillTimer(voteTimeout);
		voteTimeout = null;
	}
}

public Action Event_Intermission(Event event, const char[] name, bool dontBroadcast) {
	remainingTimeCT = -1.0; // Default value is -1.0
	remainingTimeT = -1.0; // To avoid issues
	isVoteActive = false;
	blockNewVotes = false;

	for (int i = 0; i < MAXPLAYERS; i++) {
		alreadyVoted[i] = false;
	}

	if (voteTimeout != null) {
		KillTimer(voteTimeout);
		voteTimeout = null;
	}
}

public Action Msg_VotePass(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init) {
	CreateTimer(5.0, Timer_AllowVote);

	// If the vote type is not 13 then stop here
	int voteType = msg.ReadInt("vote_type");
	if (voteType != 13) {
		return Plugin_Continue;
	}

	// Wait "sv_vote_command_delay" before setting timeout time
	ConVar voteCommandDelay = FindConVar("sv_vote_command_delay");
	CreateTimer((voteCommandDelay.FloatValue + 0.5), Timer_SetTimeoutTime);
	return Plugin_Continue;
}

public Action:Timer_SetTimeoutTime(Handle timer) {
	// Set the timeout-time to the remaining duration
	if (GameRules_GetProp("m_bTerroristTimeOutActive") == 1) {
		if (FloatCompare(remainingTimeT, 0.01) == 1) { // Only do something if its above 0.01
			GameRules_SetPropFloat("m_flTerroristTimeOutRemaining", remainingTimeT)
		}
	} else {
		if (FloatCompare(remainingTimeCT, 0.01) == 1) { // Only do something if its above 0.01
			GameRules_SetPropFloat("m_flCTTimeOutRemaining", remainingTimeCT)
		}
	}
	return Plugin_Continue;
}

public Action Msg_VoteFail(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init) {
	CreateTimer(5.0, Timer_AllowVote);
	return Plugin_Continue;
}

public Action Msg_VoteStart(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init) {
	blockNewVotes = true;
	return Plugin_Continue;
}

public Action Timer_AllowVote(Handle:timer) {
	blockNewVotes = false;

	// Are we currently in freezetime?
	if (GameRules_GetProp("m_bFreezePeriod") != 1) {
		return Plugin_Continue;
	}

	// Are we currently paused?
	if (GameRules_GetProp("m_bMatchWaitingForResume") != 1) {
		return Plugin_Continue;
	}

	// Is the pause due to a timeout?
	if (GameRules_GetProp("m_bTerroristTimeOutActive") != 1 && GameRules_GetProp("m_bCTTimeOutActive") != 1) {
		return Plugin_Continue;
	}

	CreateResumeMatchVote();
	return Plugin_Continue;
}

public Action Listener_Callvote(client, const String:command[], int argc)
{
	// Block upcoming votes
	if (isVoteActive || blockNewVotes)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	// Are we currently paused?
	if (GameRules_GetProp("m_bMatchWaitingForResume") != 1) {
		return Plugin_Continue;
	}

	// Is the pause due to a timeout?
	if (GameRules_GetProp("m_bTerroristTimeOutActive") != 1 && GameRules_GetProp("m_bCTTimeOutActive") != 1) {
		return Plugin_Continue;
	}

	// Set the timeout-time to the remaining duration
	if (GameRules_GetProp("m_bTerroristTimeOutActive") == 1) {
		if (FloatCompare(remainingTimeT, 0.0) == 1) { // Only do something if its above 0.0
			GameRules_SetPropFloat("m_flTerroristTimeOutRemaining", remainingTimeT)
		}
	} else {
		if (FloatCompare(remainingTimeCT, 0.0) == 1) { // Only do something if its above 0.0
			GameRules_SetPropFloat("m_flCTTimeOutRemaining", remainingTimeCT)
		}
	}

	// We are currently not allowing new votes from coming up
	if (blockNewVotes) {
		return Plugin_Continue;
	}

	CreateResumeMatchVote();

	return Plugin_Continue;
}

CreateResumeMatchVote() {
	float remainingTimeoutTime = GameRules_GetProp("m_bTerroristTimeOutActive") == 1 ? GameRules_GetPropFloat("m_flTerroristTimeOutRemaining") : GameRules_GetPropFloat("m_flCTTimeOutRemaining");

	// Do not create a vote if the remaining timeout is less than 10 seconds
	if (FloatCompare(remainingTimeoutTime, 10.0) == -1) {
		return;
	}

	PrintCenterTextAll("You cannot vote No in this vote. No votes will count as Yes votes.");
	PrintToChatAll("You cannot vote No in this vote. No votes will count as Yes votes.");

	// Create vote
	new entity = FindEntityByClassname(-1, "vote_controller");
	if (entity < 0) {
		return;
	}

	SetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", 99);
	SetEntProp(entity, Prop_Send, "m_nPotentialVotes", RealPlayerCount(0, true, false, true));
	SetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1);
	SetEntProp(entity, Prop_Send, "m_bIsYesNoVote", true);
	for (new i = 0; i < 5; i++) SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", 0, _, i);

	new Handle:voteStart = voteStart = StartMessageAll("VoteStart", USERMSG_RELIABLE);
	PbSetInt(voteStart, "team", -1); // Everyone can vote
	PbSetInt(voteStart, "ent_idx", 0); // Vote caller: Server
	PbSetString(voteStart, "disp_str", "#SFUI_Vote_unpause_match"); // String to display (Example: "Change map to:") - Customs dont work?
	PbSetString(voteStart, "details_str", "#SFUI_vote_passed_unpause_match"); // Details to display (Example: "de_dust2") - Customs dont work?
	PbSetBool(voteStart, "is_yes_no_vote", true); // CSGO only supports Yes/No
	PbSetString(voteStart, "other_team_str", "#SFUI_otherteam_vote_unimplemented"); // What to display if we call the vote while being on the wrong team (Irrelevant)
	PbSetInt(voteStart, "vote_type", 99);
	EndMessage();

	isVoteActive = true;
	voteTimeout = CreateTimer((remainingTimeoutTime - 5), Timer_VoteTimeout);
}

#include "./listeners/vote.sp"

#include "./handlers/voteYes.sp"
#include "./handlers/getResult.sp"
#include "./handlers/votePass.sp"
#include "./handlers/voteFail.sp"
#include "./handlers/voteTimeout.sp"

#include "./functions/functions.sp"

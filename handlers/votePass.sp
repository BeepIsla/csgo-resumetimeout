public Action:Timer_VotePass(Handle:timer)
{
	new entity = FindEntityByClassname(-1, "vote_controller");
	if (entity < 0) {
		return Plugin_Continue;
	}

	new Handle:votePass = StartMessageAll("VotePass", USERMSG_RELIABLE);
	PbSetInt(votePass, "team", GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1));
	PbSetInt(votePass, "vote_type", GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1));
	PbSetString(votePass, "disp_str", "#SFUI_vote_passed_unpause_match");
	PbSetString(votePass, "details_str", "");
	EndMessage();

	CreateTimer(5.0, Timer_ResetData);
	return Plugin_Continue;
}
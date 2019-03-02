public Action Timer_VoteFail(Handle timer) {
	int entity = FindEntityByClassname(-1, "vote_controller");
	if (entity < 0) {
		return Plugin_Continue;
	}

	Handle voteFailed = StartMessageAll("VoteFailed", USERMSG_RELIABLE);
	PbSetInt(voteFailed, "team", GetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1));
	PbSetInt(voteFailed, "reason", 4);
	/*
	0 = Vote Failed.
	1 = *Empty*
	2 = *Empty*
	3 = Yes votes must exceed No votes.
	4 = Not enough players voted.
	*/
	EndMessage();

	CreateTimer(5.0, Timer_ResetData);
	return Plugin_Continue;
}
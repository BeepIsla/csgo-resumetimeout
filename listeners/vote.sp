public Action:Listener_Vote(client, const String:command[], int argc)
{
	if (!isVoteActive || argc < 1)
	{
		return Plugin_Continue;
	}

	if (alreadyVoted[client] == true) {
		return Plugin_Stop;
	}

	if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T) {
		return Plugin_Stop;
	}

	new String:option[512];
	GetCmdArg(1, option, sizeof(option));

	if (strcmp(option, "option1", false) == 0) {
		voteYes(client);
	} else if (strcmp(option, "option2", false) == 0) {
		// Do nothing if we vote no. You cannot vote no.
		// return Plugin_Stop;

		// Ghetto fix: A no vote, is a yes vote. Otherwise the player cannot vote anymore at all besides using console commands.
		voteYes(client);
	}

	return Plugin_Handled;
}

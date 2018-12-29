public Action:Timer_GetResults(Handle:timer)
{
	// Get stuff and check if we pass or fail or wait for more votes
	int entity = FindEntityByClassname(-1, "vote_controller");
	if (entity < 0) {
		return Plugin_Stop;
	}

	int activeIssue = GetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1); // Special index for each and every custom type - Compare it to a list to figure out what we voted
	int potentialVotes = GetEntProp(entity, Prop_Send, "m_nPotentialVotes", -1); // Max amount of votes
	int option1 = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 0); // Yes votes count
	int option2 = GetEntProp(entity, Prop_Send, "m_nVoteOptionCount", -1, 1); // No votes count

	if (activeIssue == 99) { // Our custom vote
		if ((option1 + option2) >= potentialVotes) {
			if (DidWePassQuorumRatio(option1, option2, 100)) {
				// Timeout vote so the vote doesn't last infinite
				if (voteTimeout != null) {
					KillTimer(voteTimeout);
					voteTimeout = null;
				}

				CreateTimer(0.5, Timer_VotePass);

				// Save the remaining timeout time and allow the team to make another timeout
				if (GameRules_GetProp("m_bTerroristTimeOutActive") == 1) {
					remainingTimeT = GameRules_GetPropFloat("m_flTerroristTimeOutRemaining");
					GameRules_SetProp("m_nTerroristTimeOuts", (GameRules_GetProp("m_nTerroristTimeOuts") + 1));
					GameRules_SetPropFloat("m_flTerroristTimeOutRemaining", 0.0);
				} else {
					remainingTimeCT = GameRules_GetPropFloat("m_flCTTimeOutRemaining");
					GameRules_SetProp("m_nCTTimeOuts", (GameRules_GetProp("m_nCTTimeOuts") + 1));
					GameRules_SetPropFloat("m_flCTTimeOutRemaining", 0.0);
				}
			} else {
				CreateTimer(0.5, Timer_VoteFail);
			}
		}
	}
	return Plugin_Handled;
}
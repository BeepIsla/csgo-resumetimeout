bool DidWePassQuorumRatio(int yesVotes, int noVotes, float quorum) {
	float resultQuorum = float(yesVotes / (yesVotes + noVotes)) * 100;
	
	if (FloatCompare(resultQuorum, quorum) >= 1 || FloatCompare(resultQuorum, quorum) == 0) {
		return true;
	} else {
		return false;
	}
}

int RealPlayerCount(int client, bool InGameOnly, bool teamOnly, bool noSpectators) {
	int clientTeam = CS_TEAM_NONE;

	if (client > 0) {
		clientTeam = GetClientTeam(client);
	}

	int players = 0;

	for(int i = 1; i <= MaxClients; i++) {
		if (InGameOnly == true) {
			if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) {
				if (teamOnly == true) {
					if (clientTeam == GetClientTeam(i)) {
						players += 1;
					}
				} else {
					if (noSpectators == true) {
						if (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T) {
							players += 1;
						}
					} else {
						players += 1;
					}
				}
			}
		} else {
			if (IsClientConnected(i) && !IsFakeClient(i)) {
				if (teamOnly == true) {
					if (clientTeam == GetClientTeam(i)) {
						players += 1;
					}
				} else {
					players += 1;
				}
			}
		}
	}

	return players;
}

public Action Timer_ResetData(Handle timer) {
	isVoteActive = false;

	for (int i = 0; i < MAXPLAYERS; i++) {
		alreadyVoted[i] = false;
	}

	int entity = FindEntityByClassname(-1, "vote_controller");
	if (entity > -1) {
		for (int i = 0; i < 5; i++) {
			SetEntProp(entity, Prop_Send, "m_nVoteOptionCount", 0, _, i);
		}
		SetEntProp(entity, Prop_Send, "m_iActiveIssueIndex", -1);
		SetEntProp(entity, Prop_Send, "m_nPotentialVotes", 0);
		SetEntProp(entity, Prop_Send, "m_iOnlyTeamToVote", -1);
		SetEntProp(entity, Prop_Send, "m_bIsYesNoVote", true);
	}
}

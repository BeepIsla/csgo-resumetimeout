public Action Timer_VoteTimeout(Handle timer, int userid) {
	int client = GetClientOfUserId(userid);
	if (client <= 0 && client > MaxClients) {
		return;
	}

	CreateTimer(1.0, Timer_VoteFail);
	voteTimeout = null;
}

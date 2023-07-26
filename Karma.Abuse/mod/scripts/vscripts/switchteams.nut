

global function STCommand
global function SwitchTeam
global function SwitchTeamCMD

void function STCommand()
{
	#if SERVER
	AddClientCommandCallback("switchteam", SwitchTeamCMD);
	AddClientCommandCallback("st", SwitchTeamCMD);
	#endif
}

bool function SwitchTeamCMD(entity player, array<string> args)
{
	#if SERVER
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "未檢測到管理員權限");
		return true;
	}

	// if player only typed "gift"
	if (args.len() == 0)
	{
		Kprint( player, "有效命令示例: switchteam/st <playerID> <playerID2> <playerID3> ... / all");
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			Kprint( player, "[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}

	CMDsender = player
	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					SwitchTeam(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					SwitchTeam(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					SwitchTeam(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    SwitchTeam(p)
		break;
	}
	if (args.len() > 1) {
		CMDsender = player
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    SwitchTeam(p)
		}
	}

	#endif
	return true;
}

void function SwitchTeam(entity player)
{
#if SERVER
	try {
		if (player.GetTeam() == TEAM_IMC)
			SetTeam( player, TEAM_MILITIA )
		else if (player.GetTeam() == TEAM_MILITIA)
			SetTeam( player, TEAM_IMC )
	} catch(e)
	{
		Kprint( CMDsender, "無法切換 " + player.GetPlayerName() + "的團隊可能是不真實的")
	}
#endif
}
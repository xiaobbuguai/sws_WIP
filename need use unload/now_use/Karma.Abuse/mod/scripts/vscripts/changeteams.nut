

global function CTCommand
global function ChangeTeam
global function ChangeTeamCMD

// basically for ffa
void function CTCommand()
{
	#if SERVER
	AddClientCommandCallback("changeteam", SwitchTeamCMD);
	AddClientCommandCallback("ct", SwitchTeamCMD);
	#endif
}

bool function ChangeTeamCMD(entity player, array<string> args)
{
	#if SERVER
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "Admin permission not detected.");
		return true;
	}

	// if player only typed "gift"
	if (args.len() < 2) // needs 2 or more arguments
	{
		Kprint( player, "Give a valid argument.");
		Kprint( player, "Example: changeteam/ct <teamNumber> <playerID> <playerID2> <playerID3> ... / all");
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
	int teamNum = int( args[0] )
	switch (args[1])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					ChangeTeam(p, teamNum)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					ChangeTeam(p, teamNum)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					ChangeTeam(p, teamNum)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    ChangeTeam(p, teamNum)
		break;
	}
	if (args.len() > 2) {
		CMDsender = player
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
            CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    ChangeTeam(p, teamNum)
		}
	}

	#endif
	return true;
}

void function ChangeTeam(entity player, int teamNum)
{
#if SERVER
	try {
		SetTeam( player, teamNum )
	} catch(e)
	{
		Kprint( CMDsender, "Unable to switch " + player.GetPlayerName() + "'s team. Could be unalive lol.")
	}
#endif
}
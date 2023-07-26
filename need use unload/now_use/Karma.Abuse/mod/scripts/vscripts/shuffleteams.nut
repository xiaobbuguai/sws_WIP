untyped

global function ShuffleTeamsCommand
global function ShuffleTeamsCMD

void function ShuffleTeamsCommand()
{
	#if SERVER
	AddClientCommandCallback("shuffleteam", ShuffleTeamsCMD);
	AddClientCommandCallback("shuffleteams", ShuffleTeamsCMD);
	#endif
}

bool function ShuffleTeamsCMD(entity player, array<string> args)
{
	#if SERVER
	entity weapon = null;
	string weaponId = ("");
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
		array<entity> picked = [];
        foreach (entity player in GetPlayerArray()) {
			if (picked.find(player) == -1 && player != null) {
       			int i = RandomInt(9)
            	if (i % 2 == 0)
                	SetTeam(player, TEAM_IMC)
            	else
                	SetTeam(player, TEAM_MILITIA)
				picked.append(player)
			}
        }
		return true;
	}

    if (args.len () > 0)
        Kprint( player, "不需要參數")
	#endif
	return true;
}

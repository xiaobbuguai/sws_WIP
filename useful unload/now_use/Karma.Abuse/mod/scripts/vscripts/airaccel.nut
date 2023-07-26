global function AirAccelCommand
global function AirAccel
global function AirAccelCMD

table<entity, int> airaccel

void function AirAccelCommand()
{
	#if SERVER
	AddClientCommandCallback("airaccel", AirAccelCMD);
	AddClientCommandCallback("aa", AirAccelCMD);
	AddCallback_OnPlayerRespawned( ApplyAirAccel )
	#endif
}

bool function AirAccelCMD(entity player, array<string> args)
{
	#if SERVER
	entity weapon = null;
	string weaponId = ("");
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		NSSendInfoMessageToPlayer(player, "未檢測到管理員權限");
		return true;
	}

	// if player only typed "airaccel"
	if (args.len() == 0)
	{
		NSSendInfoMessageToPlayer(player, "有效命令示例:airaccel/aa <playername/imc/militia/all> <value> [save]")
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			NSSendInfoMessageToPlayer(player, "[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}
    array<entity> sheep1
	// if player typed "fly somethinghere"
	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					sheep1.append(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					sheep1.append(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					sheep1.append(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
					sheep1.append(p)
		break;
	}
	if (args.len() > 1) // airaccel playername 500
	{
		int value = args[1].tointeger()
		CMDsender = player
        AirAccel(sheep1, value)
	}

    if(args.len() > 2 && args[2] == "save") // airaccel playername 500 save
    {
		int value = args[1].tointeger()
		foreach (entity p in sheep1)
        	airaccel[p] <- value

		CMDsender = player
		AirAccel(sheep1, value)
    }
	if (args.len() > 3)
	{
		NSSendInfoMessageToPlayer(player, Kprefix + "有效命令示例:airaccel/aa <playername> <value> [save]")
		return false;
	}
	#endif
	return true;
}

void function AirAccel( array<entity> players, int value )
{
	#if SERVER
	int successfulcount = 0
    foreach(entity player in players)
	{
		if ( IsAlive(player) && IsValid(player) )
		{
        	player.kv.airAcceleration = value
    	}
		successfulcount++
	}
	NSSendInfoMessageToPlayer(CMDsender, Kprefix + "成功修改 " + successfulcount.tostring() + " 玩家的空中加速")
	#endif
}

void function ApplyAirAccel(entity player)
{
	if (player in airaccel)
		ApplyAirAccelThreaded(player)
}

void function ApplyAirAccelThreaded(entity player)
{
	WaitFrame() // waitframe because sh_custom_air_accel fucks with it
	try
        player.kv.airAcceleration = airaccel[player]
    catch(e)
        print(e)
}

global function Sonar
global function SonarCommand
global function SonarCMD

void function SonarCommand()
{
	#if SERVER
	AddClientCommandCallback("sonar", SonarCMD);
	#endif
}

bool function SonarCMD(entity player, array<string> args)
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

	// if player only typed "sonar"
	if (args.len() == 0)
	{
		Kprint( player, "有效命令示例: sonar <playerID> <playerID2> <playerID3> ... / imc / militia / all");
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
    array<entity> sheep1
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

    if (args.len() == 1 )
    {
        Kprint( player, "請插入持續時間")
        return true;
    }
    int duration
    if (args.len() > 1)
    {
        duration = args[1].tointeger()
    }

	if (args.len() > 2) {
		Kprint( player, "只需要兩個參數")
        return true;
	}

    foreach (entity play in sheep1)
    {
        thread Sonar(play, duration)
    }
	#endif
	return true;
}

void function Sonar(entity player, int duration)
{
#if SERVER
    float dur = duration.tofloat()
	StatusEffect_AddTimed( player, eStatusEffect.sonar_detected, 1.0, dur, 0.0 )
    Highlight_SetEnemyHighlight( player, "enemy_sonar" )
    wait duration
    if (Hightlight_HasEnemyHighlight(player, "enemy_sonar"))
        Highlight_ClearEnemyHighlight( player )
#endif
}
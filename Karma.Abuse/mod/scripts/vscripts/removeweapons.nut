global function RemoveWeaponsCommand
global function RemoveWeapon
global function RemoveWeaponsCMD

void function RemoveWeaponsCommand()
{
	#if SERVER
	AddClientCommandCallback("removeweapon", RemoveWeaponsCMD);
	AddClientCommandCallback("rw", RemoveWeaponsCMD);
	#endif
}

bool function RemoveWeaponsCMD(entity player, array<string> args)
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
		Kprint( player, "這只會移除主要武器,有效命令示例: removeweapon/rw <playerId> <playerId2> ... / imc / militia / all");
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
	// if player typed "rw somethinghere"
	CMDsender = player
	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					RemoveWeapon(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					RemoveWeapon(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					RemoveWeapon(p)
			}
		break;

		default:
			CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    RemoveWeapon(p)
		break;
	}
	if (args.len() > 1) {
		CMDsender = player
		array<string> playersname = args.slice(1);
		foreach (string playerId in playersname)
		{
			CheckPlayerName(playerId)
				foreach (entity p in successfulnames)
                    RemoveWeapon(p)
		}
	}
	#endif
	return true;
}

void function RemoveWeapon( entity player )
{
	#if SERVER
	array<entity> weapons = player.GetMainWeapons()
	foreach (entity weapon in weapons)
	{
		if (weapon == null)
			break;
		string weaponId = weapon.GetWeaponClassName()
		if (weapon != player.GetOffhandWeapon( OFFHAND_MELEE) ) {
			try
			{
				player.TakeWeaponNow(weaponId)
				Kprint( CMDsender, "刪除 " + player.GetPlayerName() + " 的武器")
			} catch(exception)
			{
				Kprint( CMDsender, "無法刪除" + player.GetPlayerName() + "的武器，武器ID為 " + weaponId + "!")
			}
		}
	}

	/*weapons = player.GetOffhandWeapons()
	foreach (entity weapon in weapons)
	{
		if (weapon == null)
			break;
		string weaponId = weapon.GetWeaponClassName()
		try
		{
			player.TakeWeaponNow(weaponId)
		} catch(exception)
		{
			Kprint( player, "Can't take " + player.GetPlayerName() + "'s " + weaponId + "!")
		}
	}*/
#endif
}

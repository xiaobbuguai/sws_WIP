global function GetMod
global function GetWM
global function ForceGetWM

void function GetMod()
{
	#if SERVER
	AddClientCommandCallback("getmods", GetWM);
	AddClientCommandCallback("getmod", GetWM);
	AddClientCommandCallback("gm", GetWM);
	AddClientCommandCallback("fgm", ForceGetWM);
	AddClientCommandCallback("fgetmod", ForceGetWM);
	AddClientCommandCallback("fgetmods", ForceGetWM);
	#endif
}

bool function GetWM(entity player, array<string> args)
{
	#if SERVER
	if (player == null)
		return true;

	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "未檢測到管理員權限");
		return true;
	}
	string weaponId
	if (args.len() == 0)
	{
		Kprint( player, "getmod/getmods/gm <weaponId>")
		return true;
	}
	CheckWeaponName(args[0])
	if (successfulweapons.len() > 1)
	{
		print ("发现多件武器！")
		int i = 1;
		foreach (string weaponnames in successfulweapons)
		{
			print ("[" + i.tostring() + "] " + weaponnames)
			i++
		}
		return true;
	}
	else if (successfulweapons.len() == 1)
	{
		Kprint( player, "武器ID為 " + successfulweapons[0])
		weaponId = successfulweapons[0]
	}
	else if (successfulweapons.len() == 0)
	{
		Kprint( player, "無法檢測武器")
		return true;
	}

	array<string> amods = GetWeaponMods_Global( weaponId );
	string modId = "";

	if (args.len() == 1)
	{
		for( int i = 0; i < amods.len(); ++i )
		{
			string modId = amods[i]
			Kprint( player, "[" + i.tostring() + "] " + modId);
		}
		return true;
	}

	if (args.len() > 1)
	{
		Kprint( player, "只需要1個參數")
		return true;
	}
	return true;
	#endif
}

bool function ForceGetWM(entity player, array<string> args)
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

	// if player only typed "fgift"
	if (args.len() == 0)
	{
		Kprint( player, "有效命令示例: fgift/forcegift <weaponId> <playerId>");
		Kprint( player, "您可以通過鍵入give並按tab鍵滾動ID來檢查武器ID");
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
	// if player typed "fgift somethinghere"
	switch (args[0]) {
		case (""):
		Kprint( player, "Give a valid argument.");
		break;
		case ("pd"):
		weaponId = "mp_titanweapon_predator_cannon";
		break;
		case ("sword"):
		weaponId = "melee_titan_sword";
		break;
		case ("pr"):
		weaponId = "mp_titanweapon_sniper";
		break;
		case ("ld"):
		weaponId = "mp_titanweapon_leadwall";
		break;
		case ("40mm"):
		weaponId = "mp_titanweapon_sticky_40mm";
		break;
		case ("peacekraber"):
		weaponId = "mp_weapon_peacekraber";
		break;
		case ("kraber"):
		weaponId = "mp_weapon_sniper";
		break;

		default:
			weaponId = args[0]
			Kprint( player, "Weapon ID is " + weaponId)
		break;
	}

	string modId = "";

	if (args.len() == 1)
	{
		try
		{
			array<string> amods = GetWeaponMods_Global( weaponId );
			for( int i = 0; i < amods.len(); ++i )
			{
				string modId = amods[i]
				Kprint( player, "[" + i.tostring() + "] " + modId);
			}
			return true;
		} catch (exception)
		{
			Kprint( player,  "無法獲取的mods" + weaponId + ",你確定這是正確的ID嗎？" );
			return true;
		}
	}

	if (args.len() > 1)
	{
		Kprint( player, "只需要1個參數")
		return true;
	}
	#endif
	return true;
}
global function Mod
global function PrintWeaponMods
global function GiveWM
global function GiveWMWait
global function GiveWeaponMod
global bool bypassPerms = false;

void function Mod()
{
	#if SERVER
	AddClientCommandCallback("mod", GiveWMWait);
	#endif
}

void function PrintWeaponMods(entity weapon)
{
	#if SERVER
	array<string> amods = GetWeaponMods_Global( weapon.GetWeaponClassName() );
	for( int i = 0; i < amods.len(); ++i )
	{
		string modId = amods[i]
		Kprint( CMDsender, "[" + i.tostring() + "] " + modId);
	}
	#endif
}

bool function GiveWMWait(entity player, array<string> args)
{
	#if SERVER
	thread GiveWM(player, args)
	#endif
	return true;
}

bool function GiveWM(entity player, array<string> args)
{
	#if SERVER
	if (player == null)
		return true;

	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true && bypassPerms != true)
	{
		Kprint( player, "未檢測到管理員權限");
		return true;
	}
	entity weapon = player.GetActiveWeapon();

	if(weapon != null)
	{
		array<string> amods = GetWeaponMods_Global( weapon.GetWeaponClassName() );
		string modId = "";

		if (args.len() == 0)
		{
			if (CMDsender != player)
			{
				Kprint( CMDsender, "您可以通過鍵入相同的modId來刪除mod");
			}
			else
			{
				Kprint( player, "您可以通過鍵入相同的modId來刪除mod");
				CMDsender = player
			}
			PrintWeaponMods(weapon);
			return true;
		}

		string newString = "";

		foreach (string newmodId in args)
		{
			try
			{
				int a = newmodId.tointeger();
				modId = amods[a];
			} catch(exception2)
			{
				Kprint( player, "錯誤：未知ID，假設為modId");
			}
			weapon = player.GetActiveWeapon();
			GiveWeaponMod(player, modId, weapon)
			newString += (modId + " ");
		}
		if (CMDsender != player)
			Kprint( CMDsender, "Mods提供給 " + player.GetPlayerName() + " 是 " + newString);
		else
			Kprint( player, "Mods提供給 " + player.GetPlayerName() + " 是 " + newString);
		bypassPerms = false;
	} else {
		if (CMDsender != player)
			Kprint( CMDsender, "檢測到無效武器");
		else
			Kprint( player, "檢測到無效武器");
		return true;
	}
	return true;
	#endif
}

void function GiveWeaponMod(entity player, string modId, entity weapon)
{
	#if SERVER
		string weaponId = weapon.GetWeaponClassName();
		bool removed = false;
		array<string> mods = weapon.GetMods();

		// checks if the mods is already on the weapon
		for( int i = 0; i < mods.len(); ++i )
		{
			if( mods[i] == modId )
			{
				mods.remove( i );
				removed = true;
				break;
			}
		}
		player.TakeWeaponNow( weaponId );
		try
		{
			player.GiveWeapon( weaponId, mods )
		}
		catch(exception2)
		{
			if (CMDsender != player)
				Kprint( CMDsender, "錯誤：Mod相互沖突");
			else
				Kprint( player, "錯誤：Mod相互沖突");

			for( int i = 0; i < mods.len(); ++i )
			{
				if( mods[i] == modId )
				{
					mods.remove( i );
					removed = true;
					break;
				}
			}
			player.GiveWeapon( weaponId, mods);
		}
		player.SetActiveWeaponByName( weaponId );
	#endif
}

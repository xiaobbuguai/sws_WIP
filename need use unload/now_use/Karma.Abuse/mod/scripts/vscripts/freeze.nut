global function FreezeCommand
global function Freeze
global function FreezeCMD
global function unFreezeCMD

void function FreezeCommand() {
    #if SERVER
    AddClientCommandCallback("freeze", FreezeCMD);
    AddClientCommandCallback("unfreeze", unFreezeCMD);
    #endif
}

bool function FreezeCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        Kprint( player, "未檢測到管理員權限");
        return true;
    }

    // if player only typed "health"
    if (args.len() == 0) {
        Kprint( player, "有效命令示例: freeze <playerId>, playerId = imc / militia / all");
        // print every single player's name and their id
        int i = 0;
        foreach(entity p in GetPlayerArray()) {
            string playername = p.GetPlayerName();
            Kprint( player, "[" + i.tostring() + "] " + playername);
            i++
        }
        return true;
    }
	string playername = player.GetPlayerName()
    array < entity > sheep1 = [];
    // if player typed "health somethinghere"
    switch (args[0]) {
        case ("all"):
            foreach(entity p in GetPlayerArray()) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("imc"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_IMC)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("militia"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_MILITIA)) {
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

    // if player typed "gift correctId" with no further arguments

    if (args.len() > 1 )
	{
		Kprint( player, "只需要1個參數")
		return true;
	}
    CMDsender = player
    thread Freeze(sheep1)
    #endif
    return true;
}

bool function unFreezeCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        Kprint( player, "未檢測到管理員權限");
        return true;
    }

    // if player only typed "health"
    if (args.len() == 0) {
        Kprint( player, "有效命令示例: unfreeze <playerId>, playerId = imc / militia / all");
        // print every single player's name and their id
        int i = 0;
        foreach(entity p in GetPlayerArray()) {
            string playername = p.GetPlayerName();
            Kprint( player, "[" + i.tostring() + "] " + playername);
            i++
        }
        return true;
    }
	string playername = player.GetPlayerName()
    array < entity > sheep1 = [];
    // if player typed "health somethinghere"
    switch (args[0]) {
        case ("all"):
            foreach(entity p in GetPlayerArray()) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("imc"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_IMC)) {
                if (p != null)
                    sheep1.append(p)
            }
            break;

        case ("militia"):
            foreach(entity p in GetPlayerArrayOfTeam(TEAM_MILITIA)) {
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

    // if player typed "gift correctId" with no further arguments

    if (args.len() > 1 )
	{
		Kprint( player, "只需要1個參數")
		return true;
	}
    CMDsender = player
    thread unFreeze(sheep1)
    #endif
    return true;
}

void function Freeze(array < entity > player) {
    #if SERVER
    foreach(entity localPlayer in player)
	{
        localPlayer.MovementDisable()
        localPlayer.ConsumeDoubleJump()
        localPlayer.DisableWeaponViewModel()
    }
    if (player.len() == 1)
        Kprint( CMDsender, "凍結 " + player[0].GetPlayerName())
    else
        Kprint( CMDsender, "凍結 " + player.len() + " 玩家")
    #endif
}

void function unFreeze(array < entity > player) {
    #if SERVER
    foreach(entity localPlayer in player)
	{
        localPlayer.MovementEnable()
        localPlayer.EnableWeaponViewModel()
    }
    if (player.len() == 1)
        Kprint( CMDsender, "解凍 " + player[0].GetPlayerName() + "")
    else
        Kprint( CMDsender, "解凍 " + player.len() + " 玩家")
    #endif
}
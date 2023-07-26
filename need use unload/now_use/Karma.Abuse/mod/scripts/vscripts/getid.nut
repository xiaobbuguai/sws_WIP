global function getIDCommand;
global function getID;
global function getIDCMD;

void function getIDCommand() {
    #if SERVER
    AddClientCommandCallback("getid", getIDCMD);
    #endif
}

bool function getIDCMD(entity player, array < string > args) {
    #if SERVER
	array<entity> players = GetPlayerArray()
    hadGift_Admin = false;
    CheckAdmin(player);
    if (hadGift_Admin != true) {
        Kprint( player, "未檢測到管理員權限");
        return true;
    }

    // if player only typed "gift"
    if (args.len() == 0) {
        Kprint( player, "有效命令示例: getid <playername>");
        // print every single player's name and their id
        int i = 0;
        foreach(entity p in GetPlayerArray()) {
            string playername = p.GetPlayerName();
            Kprint( player, "[" + i.tostring() + "] " + playername);
            i++
        }
        return true;
    }
    array < entity > sheep1 = [];
    // if player typed "announce somethinghere"
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


    if (args.len() > 1 )
	{
		Kprint( player, "只需要1個參數")
		return true;
	}
    CMDsender = player
    thread getID(sheep1)
    #endif
    return true;
}

void function getID(array < entity > player) {
    #if SERVER
    int i = 0;
    foreach(entity localPlayer in player)
	{
        string playername = localPlayer.GetPlayerName()
        Kprint( CMDsender, "[" + i.tostring() + "] " + playername + ", " + localPlayer.GetUID() );
        print( "[" + i.tostring() + "] " + playername + ", " + localPlayer.GetUID() )
        i++
    }
    #endif
}
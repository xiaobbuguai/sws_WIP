global function getTeamCommand
global function getTeam
global function getTeamCMD

void function getTeamCommand() {
    #if SERVER
    AddClientCommandCallback("getteam", getTeamCMD);
    #endif
}

bool function getTeamCMD(entity player, array < string > args) {
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
        Kprint( player, "有效命令示例: getteam <playername> ,理想情況下,我做了它,所以它可以為您自動填充");
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
    thread getTeam(sheep1)
    #endif
    return true;
}

void function getTeam(array < entity > player) {
    #if SERVER
    int i = 0;
    foreach(entity localPlayer in player)
	{
        string playername = localPlayer.GetPlayerName()
        if (localPlayer.GetTeam() == TEAM_MILITIA)
            Kprint( CMDsender, "[" + i.tostring() + "] " + playername + " 是掠奪者反抗軍/Militia" );
        if (localPlayer.GetTeam() == TEAM_IMC)
            Kprint( CMDsender, "[" + i.tostring() + "] " + playername + " 是IMC雇傭兵/IMC" );

        i++
    }
    #endif
}
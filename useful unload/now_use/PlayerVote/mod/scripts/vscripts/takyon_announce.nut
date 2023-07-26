global function AnnounceInit
global function CommandAnnounce

bool announceEnabled = false // true: users can use !rules | false: users cant use !rules //CHANGE

void function AnnounceInit(){
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!announce", CommandAnnounce)
    AddClientCommandCallback("!ANNOUNCE", CommandAnnounce)
    AddClientCommandCallback("!Announce", CommandAnnounce)

    // ConVar
    announceEnabled = GetConVarBool( "pv_announce" )
}

/*
 *  COMMAND LOGIC
 */

bool function CommandAnnounce(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER USED ANNOUNCE")

        // check if !announce is enabled
        if(!announceEnabled){
            NSSendInfoMessageToPlayer(player, COMMAND_DISABLED)
            return false
        }

        // check if theres something after !announce
        if(args.len() < 1){
            NSSendInfoMessageToPlayer(player, NO_ANNOUNCEMENT_FOUND)
            return false
        }

        // Check if user is admin
        if(!IsPlayerAdmin(player)){
            NSSendInfoMessageToPlayer(player, MISSING_PRIVILEGES)
            return false
        }

        // build message
        string msg = ""
        for(int i = 0; i < args.len(); i++){
            msg += args[i] + " " // add space
        }

        // send message
        for(int j = 0; j < GetPlayerArray().len(); j++){
            SendHudMessageBuilder(GetPlayerArray()[j], msg, 255, 200, 200, 10)//管理员向玩家宣布信息
            NSSendInfoMessageToPlayer(GetPlayerArray()[j], MAP_VOTE_USAGE);
        }
        //Chat_ServerBroadcast("\x1b[38;2;220;220;0m[PlayerVote]\n\x1b[38;2;220;50;50mANNOUNCEMENT:\n\n\x1b[38;2;220;80;80m" + msg + "\n\n")
    }
    return true
}

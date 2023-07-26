global function PlayerVoteInit
global function SendHudMessageBuilder
global function CanFindPlayerFromSubstring
global function GetFullPlayerNameFromSubstring
global function PlayerHasVoted
global function IsPlayerAdmin
global function GetPlayerFromName
global function rndint
global function GetCommandIndex

global array<string> adminUIDs = []

void function PlayerVoteInit(){
    // chat callback
    AddCallback_OnReceivedSayTextMessage(ChatCallback)

    AddCallback_GameStateEnter(eGameState.Playing, Playing)
    AddCallback_GameStateEnter(eGameState.Postmatch, Postmatch)

    AddCallback_OnPlayerRespawned(OnPlayerSpawned)
    AddCallback_OnClientDisconnected(OnPlayerDisconnected)
    AddCallback_OnPilotBecomesTitan(OnPilotBecomesTitaned)

    UpdateAdminList()
}

/*
 *  CHAT LOGIC
 */

// x3Karma if you steal this istg i will break your legs
ClServer_MessageStruct function ChatCallback(ClServer_MessageStruct message) {
    string msg = message.message.tolower()
    // find first char -> gotta be ! to recognize command
    if (format("%c", msg[0]) == "!") {
        printl("Chat Command Found")
        // command
        msg = msg.slice(1) // remove !
        array<string> msgArr = split(msg, " ") // split at space, [0] = command
        string cmd

        try{
            cmd = msgArr[0] // save command
        }
        catch(e){
            return message
        }

        msgArr.remove(0) // remove command from args

        entity player = message.player

        // command logic
        for(int i = 0; i < commandArr.len(); i++){
            if(commandArr[i].names.contains(cmd)){
                message.shouldBlock  = commandArr[i].blockMessage
                commandArr[i].func(player, msgArr)
                break
            }
        }
    }
    return message
}

/*
 *  HELPER FUNCTIONS
 */

void function OnPlayerSpawned(entity player){
    printl("[PV] Triggered OnPlayerSpawned")
    OnPlayerSpawnedHelp(player)
    OnPlayerConnectedKick(player)
    OnPlayerSpawnedWelcome(player)
    OnPlayerSpawnedMap(player)
}
void function OnPilotBecomesTitaned(entity player, entity titan) {
    //NSSendInfoMessageToPlayer(player,"鍵盤左上角按下~鍵在控製臺輸入!help查看指令幫助")
    thread WelcomePlayerOnAboard(player)
    wait 2
    thread GuidePlayerUseEnhancedTitan(player)
    wait 2
    thread GuidePlayerToUseShip(player)
}

void function GuidePlayerUseEnhancedTitan(entity player){
    NSSendAnnouncementMessageToPlayer( player, "溫馨提示", "切換至至尊泰坦以獲得增幅", <255,255,255>, 2, 1 )
}

void function WelcomePlayerOnAboard(entity player){
    NSSendAnnouncementMessageToPlayer( player, "星願服歡迎您", HELP_MESSAGE, <255,255,255>, 2, 1 )
}

void function GuidePlayerToUseShip(entity player){
    NSSendAnnouncementMessageToPlayer( player, "請在游玩前鍵入/rule獲取駕駛飛船的幫助", <255,255,255>, 2, 1 )
}

void function OnPlayerDisconnected(entity player){
    printl("[PV] Triggered OnPlayerDisconnected")
    OnPlayerDisconnectedHelp(player)
    OnPlayerDisconnectedWelcome(player)
    OnPlayerDisconnectedMap(player)
}

void function Playing(){
    printl("[PV] Triggered Playing")
    thread PlayingMap()
}

void function Postmatch(){
    printl("[PV] Triggered Postmatch")
    PostmatchMap()
    BalanceMapEnd()
}

/*
 *  HELPER FUNCTIONS
 */

void function UpdateAdminList()
{
    string cvar = GetConVarString( "pv_admin_uids" )

    array<string> dirtyUIDs = split( cvar, "," )
    foreach ( string uid in dirtyUIDs )
        adminUIDs.append(strip(uid))
}

bool function CanFindPlayerFromSubstring(string substring){
    int found = 0
    foreach(entity player in GetPlayerArray()){ // shitty solution but cant do .find cause its not an entity
        if(player.GetPlayerName().tolower().find(substring.tolower()) != null && player.GetPlayerName().tolower().find(substring.tolower()) != -1)
            found++
    }

    if(found == 1){
        return true
    }
    return false
}

string function GetFullPlayerNameFromSubstring(string substring){
    foreach(entity player in GetPlayerArray()){ // shitty solution but cant do .find cause its not an entity
        if(player.GetPlayerName().tolower().find(substring.tolower()) != null)
            return player.GetPlayerName()
    }
    return "ERROR :(" // bad fix but this shouldnt even be possible to reach
}

bool function PlayerHasVoted(entity player, array<string> arr){
    if(arr.find(player.GetPlayerName()) == -1){  // not voted yet
        return false
    }
    return true
}

void function SendHudMessageBuilder(entity player, string message, int r, int g, int b, int holdTime = 6){
    // SendHudMessage(player, message, x_pos, y_pos, R, G, B, A, fade_in_time, hold_time, fade_out_time)
    // Alpha doesnt work properly and is dependant on the RGB values for whatever fucking reason
    SendHudMessage( player, message, -1, 0.2, r, g, b, 255, 0.15, holdTime, 1 )
}
bool function IsPlayerAdmin(entity player){
    if(adminUIDs.find(player.GetUID()) == -1)
        return false
    return true
}

entity function GetPlayerFromName(string name){
    entity target
    for(int i = 0; i < GetPlayerArray().len(); i++){
        if(name == GetPlayerArray()[i].GetPlayerName()){
            return GetPlayerArray()[i]
        }
    }
    return null
}

int function rndint(int max) {
    // Generate a pseudo-random integer between 0 and max-1, inclusive
    float roll = 1.0 * max * rand() / RAND_MAX;
    return roll.tointeger();
}

int function GetCommandIndex(string name){
    for(int i = 0; i < commandArr.len(); i++){
        if(commandArr[i].names.contains(name))
            return i
    }
    return -1
}

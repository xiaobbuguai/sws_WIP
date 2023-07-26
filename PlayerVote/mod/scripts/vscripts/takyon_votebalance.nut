global function BalanceInit
global function CommandBalance
global function BalanceMapEnd

bool balanceEnabled = true
bool balanceAtMapEnd = false
float balanceVotePercentage = 0.5 // percentage of how many people on the server need to have voted
array<string> playerBalanceVoteNames = [] // list of players who have voted, is used to see how many have voted

struct PlayerKDData{
    entity player
    float kd
}

void function BalanceInit(){
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!balance", CommandBalance)
    AddClientCommandCallback("!BALANCE", CommandBalance)
    AddClientCommandCallback("!Balance", CommandBalance)

    // ConVar
    balanceEnabled = GetConVarBool( "pv_balance_enabled" )
    balanceVotePercentage = GetConVarFloat( "pv_balance_percentage" )
    balanceAtMapEnd = GetConVarBool("pv_balance_at_map_end") // add callback if convar set for shuffle at end of map
}

/*
 *  COMMAND LOGIC
 */

bool function CommandBalance(entity player, array<string> args){
    if(!IsLobby() && !IsFFAGame()){
        printl("USER USED BALANCE")
        if(!balanceEnabled){
            NSSendInfoMessageToPlayer( player, COMMAND_DISABLED )
            return false
        }

        // admin force vote
        if(args.len() == 1 && args[0] == "force"){
            // Check if user is admin
            if(!IsPlayerAdmin(player)){
                NSSendInfoMessageToPlayer( player, MISSING_PRIVILEGES )
                return false
            }

            for(int i = 0; i < GetPlayerArray().len(); i++){
                NSSendInfoMessageToPlayer(GetPlayerArray()[i], ADMIN_BALANCED)
                CheckIfEnoughBalanceVotes(true)
            }
            return true
        }

        // check if player has already voted
        if(!PlayerHasVoted(player, playerBalanceVoteNames)){
            // add player to list of players who have voted
            playerBalanceVoteNames.append(player.GetPlayerName())

            // send message to everyone
            for(int i = 0; i < GetPlayerArray().len(); i++){
                if(playerBalanceVoteNames.len() > 1) // semantics
                    NSSendInfoMessageToPlayer(GetPlayerArray()[i], playerBalanceVoteNames.len() + MULTIPLE_BALANCD_VOTES)
                else
                    NSSendInfoMessageToPlayer(GetPlayerArray()[i], playerBalanceVoteNames.len() + ONE_BALANCE_VOTE)
			}
        }
        else {
            // Doesnt let the player vote twice, name is saved so even on reconnect they cannot vote twice
            // Future update might check if the player is actually online but right now i am too tired
            NSSendInfoMessageToPlayer(player, ALREADY_VOTED)
        }
    }
    CheckIfEnoughBalanceVotes()
    return true
}

/*
 *  HELPER FUNCTIONS
 */

void function CheckIfEnoughBalanceVotes(bool force = false){
    // check if enough have voted if it wasn't forced to begin with
    if(playerBalanceVoteNames.len() >= (1.0 * GetPlayerArray().len() * balanceVotePercentage) || force) {
        array<entity> _players = GetPlayerArray()
        if(_players.len() < 1)
            return
        Balance(_players)
        // message everyone
        for(int i = 0; i < GetPlayerArray().len(); i++){
            NSSendInfoMessageToPlayer(GetPlayerArray()[i], BALANCED)
        }
        playerBalanceVoteNames.clear()
    }
}

// Helper function to force a team balance
// Intended for use upon eGameState.Postmatch
void function BalanceMapEnd() {
    if(balanceAtMapEnd)
        CheckIfEnoughBalanceVotes(true)
}

void function Balance(array<entity> _players){
    // sort players based on kd
    array<PlayerKDData> playerRanks = GetPlayersSortedBySkill(_players)

    asset playerModel// = player.GetModelName()
    int playerSkin// = player.GetSkin()
    int playerCamo// = player.GetCamo()
    int playerDecal// = player.GetDecal()

    for(int i = 0; i < GetPlayerArray().len(); i++){
        playerModel= playerRanks[i].player.GetModelName()
        playerSkin = playerRanks[i].player.GetSkin()
        playerCamo = playerRanks[i].player.GetCamo()
        playerDecal = playerRanks[i].player.GetDecal()
        if(!IsEven(i)){
            SetTeam(playerRanks[i].player, TEAM_IMC)
        }else{
            SetTeam(playerRanks[i].player, TEAM_MILITIA)
        }
        SetPlayerModelAndSkins(playerRanks[i].player, playerModel, playerSkin, playerCamo, playerDecal)
    }
}

array<PlayerKDData> function GetPlayersSortedBySkill(array<entity> arr){
    array<PlayerKDData> pkdArr
    foreach (entity player in arr) {
        // get kd for player // TYSM Dinorush
        PlayerKDData temp
        temp.player = player
        int deaths =  player.GetPlayerGameStat(PGS_DEATHS)
        if(deaths == 0){
            temp.kd = 9999.0
        }
        else{
            temp.kd =  1.0 * player.GetPlayerGameStat(PGS_KILLS) / player.GetPlayerGameStat(PGS_DEATHS)
        }
        pkdArr.append(temp)
    }
    pkdArr.sort(PlayerKDDataSort)
    return pkdArr
}

int function PlayerKDDataSort(PlayerKDData data1, PlayerKDData data2)
{
  if ( data1.kd == data2.kd )
    return 0
  return data1.kd < data2.kd ? -1 : 1
}

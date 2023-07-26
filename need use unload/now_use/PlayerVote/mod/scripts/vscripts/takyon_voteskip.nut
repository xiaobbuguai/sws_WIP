global function VoteSkipInit
global function CommandSkip
global function CommandSkipCall

array<string> playerSkipVoteNames = [] // list of players who have voted, is used to see how many have voted
float skipVotePercentage = 0.8 // percentage of how many people on the server need to have voted
bool skipEnabled = true

void function VoteSkipInit(){
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!skip", CommandSkip) //!skip force will change the map if your name is in adminNames
    AddClientCommandCallback("!SKIP", CommandSkip)
    AddClientCommandCallback("!Skip", CommandSkip)

    AddClientCommandCallback("!rtv", CommandSkip) // rock the vote. requested by @Hedelma
    AddClientCommandCallback("!RTV", CommandSkip)

    // ConVar
    skipEnabled = GetConVarBool( "pv_skip_enabled" )
    skipVotePercentage = GetConVarFloat( "pv_skip_percentage" )
}

/*
 *  COMMAND LOGIC
 */

bool function CommandSkipCall(entity player = null, array<string> args = []){
    return true
}

bool function CommandSkip(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER TRIED SKIPPING")

        if(args.len() == 1 && args[0] == "force"){
            // Check if user is admin
            if(!IsPlayerAdmin(player)){
                NSSendInfoMessageToPlayer( player, MISSING_PRIVILEGES )
                return false
            }

            for(int i = 0; i < GetPlayerArray().len(); i++){
                NSSendInfoMessageToPlayer(GetPlayerArray()[i], ADMIN_SKIPPED)
            }
            CheckIfEnoughSkipVotes(true)
            return true
        }

        // check if skipping is enabled
        if(!skipEnabled){
            NSSendInfoMessageToPlayer( player, COMMAND_DISABLED )
            return false
        }

        // check if player has already voted //TODO fix this up
        if(!PlayerHasVoted(player, playerSkipVoteNames)){
            // add player to list of players who have voted
            playerSkipVoteNames.append(player.GetPlayerName())

            // send message to everyone
            for(int i = 0; i < GetPlayerArray().len(); i++){
                if(playerSkipVoteNames.len() > 1) // semantics
                    NSSendInfoMessageToPlayer(GetPlayerArray()[i], player.GetPlayerName() + MULTIPLE_SKIP_VOTES)
                else
                    NSSendInfoMessageToPlayer(GetPlayerArray()[i], player.GetPlayerName() + ONE_SKIP_VOTE)
			}
        }
        else {
            // Doesnt let the player vote twice, name is saved so even on reconnect they cannot vote twice
            // Future update might check if the player is actually online but right now i am too tired
            NSSendInfoMessageToPlayer(player, ALREADY_VOTED)
        }
    }
    CheckIfEnoughSkipVotes()
    return true
}

/*
 *  HELPER FUNCTIONS
 */

void function CheckIfEnoughSkipVotes(bool force = false){
    // check if enough have voted
    if(playerSkipVoteNames.len() >= (1.0 * GetPlayerArray().len() * skipVotePercentage) || force){
        if(mapsHaveBeenProposed){
            PVSetGameEndTime(Time() + 1.0)}
        else{
            PVSetGameEndTime(Time() + 30.0)
            FillProposedMaps()
        }
    }
}

void function PVSetGameEndTime(float seconds){
    SetServerVar("gameEndTime", seconds) // end this game
    playerSkipVoteNames.clear()
}
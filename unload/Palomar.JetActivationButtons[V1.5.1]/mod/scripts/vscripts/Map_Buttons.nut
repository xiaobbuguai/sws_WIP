untyped

global function Map_Buttons_Init

global function activatebuttons //need to fix: if this gets called multiple times , it doesnt error out , but the function the button calls gets called multiple times
global function createspawnconsole

array<entity> buttonlist
bool buttonstate = false
bool buttonsoncooldown = false
int selectedtypeid = 0;
string selectedtype = ""
int storedships = 14;
vector landingspot = <0,0,0>;
vector landingrotation = <0,0,0>;



void function Map_Buttons_Init(){
    if (GetMapName() == "mp_colony02") {
        createspawnconsole(<85.9315, 2766.91, 260.031>,<0, -110.942, 0>)
        createselectpanel(< -80, 2422.44, 320.031>, <0, -21.5 ,270>)
        landingspot = < -795.373, 3414.99,0>
        landingrotation = <0, -106.655, 0>
    }

    if (GetMapName() == "mp_forwardbase_kodai") {
        createspawnconsole(<2081.4, -1941.63, 985.958>, <0, -90, 0>)
        createselectpanel(<2075.58, -2112, 1044.03>, <0, 0 , 270>)
        landingspot = <2610.61, -2125.45, 799.351>
        landingrotation = <0, 90, 0>
    }

    if (GetMapName() == "mp_homestead") {
        createspawnconsole(< -2457.22, -1404.68, 13.0313>, <0, 60, 0>)
        createselectpanel( < -2390.74, -1457, 73.0313>, <0, -29 , 270>)
        landingspot = < -2808.71, -1703.25, -162.564>
        landingrotation =  <0, -45.7561, 0>
    }

    if (GetMapName() == "mp_black_water_canal") {
        createspawnconsole(<965.997, 355.228, 6.59738>, <0, 135.195, 0>)
        createselectpanel(<838.744, 510, 67.1138> ,  <0, -180 , 270>)
        landingspot = <1584.25, 5.14256, -384.334>
        landingrotation =  <0, 2.3696, 0>
    }

    if (GetMapName() == "mp_thaw") {
        createspawnconsole(< -931.822, 1973.69, -159.969>, <0, 180, 0>)
        createselectpanel(< -855.339, 2036.98, -110.785> ,  <0,-180,270>)
        landingspot = < -1465.68, 2078.6, -400.697>
        landingrotation =  <0, -119.227, 0>
    }

    if (GetMapName() == "mp_drydock") {
        createspawnconsole(<1896.52, -1843.74, 408.031>, <0, 0, 0>)
        createselectpanel(<1935.97, -1724.26, 408.031> ,  <0,0,270>)
        landingspot = <2183.22, -1861.41, 378.886>
        landingrotation =  <0, -119.227, 0>
    }
    thread buttonstatemanager()
    thread shipfactory()


    //AddClientCommandCallback("!createbutton",buttonspawnfunc) //dev
    //AddClientCommandCallback("!activatebuttons", buttonenablefunc) //dev
}
//bool function buttonspawnfunc (entity player , array<string> args) {thread createspawnconsole(<player.GetOrigin().x+50,player.GetOrigin().y,player.GetOrigin().z>,player.GetAngles());return true} //dev
//bool function buttonenablefunc (entity player , array<string> args) {thread activatebuttons();return true;} //dev



/////////////////////////////shiprequestbuttons///////////////////////////////////////////
void function createspawnconsole(vector origin, vector angles){
    entity button = CreateEntity( "prop_dynamic" )
    button.SetValueForModelKey( $"models/communication/terminal_usable_imc_01.mdl" )
    button.kv.solid = SOLID_VPHYSICS



	button.SetOrigin( origin )
	button.SetAngles( angles )
	DispatchSpawn( button )

    buttonlist.append(button)

    SetTeam( button, TEAM_BOTH )
}

void function activatebuttons(){
    if (buttonstate == false) { //buttonstate is just there to protect from activating buttons that already are
        foreach(button in buttonlist) {
            thread setbuttonactive(button)
        }
        buttonstate = true
    }

}

void function setbuttonactive(entity button) {

    button.SetUsePrompts( "按 %use% " + " 生成飛船 ", "按 %use%" + " 生成飛船 " )
    button.SetUsableByGroup( "pilot" )
    button.SetUsable()


    entity player = expect entity( button.WaitSignal( "OnPlayerUse" ).player )

    if (PlayerPosInSolid(player,<landingspot.x,landingspot.y,landingspot.z + 30>) == false &&  buttonsoncooldown == false) {


        storedships = storedships - 1

        if(storedships != 0){//if there are ships left
            //Chat_ServerBroadcast ("\x1b[94mA ship was Spawned! \x1b[92m"+string(storedships)+"\x1b[94m left in storage!\x1b[0m")
            foreach (player in GetPlayerArray()) {
                if (IsValid(player)) {
                    NSSendLargeMessageToPlayer( player, "一臺飛船已被呼叫",string(storedships)+" 臺飛船等待呼叫 ", 3.5, "rui/callsigns/callsign_74_col" )
                }
            }

        } else { //if it was the last one in storage
            //Chat_ServerBroadcast ("\x1b[94mSpawned the last ship! Wait for more to finish production!\x1b[0m")
            foreach (player in GetPlayerArray()) {
                if (IsValid(player)) {
                    NSSendLargeMessageToPlayer( player, "最後一臺飛船已被呼叫","等待下一臺飛船製造完成", 3.5, "rui/callsigns/callsign_74_col" )
                }
            }
        }

        NSDeleteStatusMessageOnPlayer(  player, "SHIPTYPESTATUS" ) //theyll overlap otherwise , looks kinda janky

        vector spawninpoint = landingspot + AnglesToForward(landingrotation) * -300 +<0,0,500> //spawn the ship slightly higher and back
        var s = Spaceship( selectedtype,spawninpoint , landingrotation )
        s.mover.NonPhysicsMoveTo( landingspot, 2 , 0, 0.5 ) //move it to the actual position , looks a bit cooler



        buttonstate = false
        thread setbuttonsoncooldown()
        buttonstatemanager()
        EmitSoundOnEntity( button, "Switch_Activate" )
    } else {
        //Chat_ServerPrivateMessage(player,"\x1b[33mLanding area is not clear!\x1b[0m",false)
        NSSendInfoMessageToPlayer( player, "飛船着陆处已有飛船！" )
        wait 5//wait out the duration of nssendinfomsg
        buttonstate = false
        buttonstatemanager()
    }

}

void function deactivateallbuttons(){
    foreach(button in buttonlist) {
        button.UnsetUsable()
    }
}

void function buttonstatemanager() {
    if (storedships > 0) {
        thread activatebuttons()
    } else {
        deactivateallbuttons()
    }

}

void function setbuttonsoncooldown(){
    buttonsoncooldown = true
    wait 2.5
    buttonsoncooldown = false
}

void function shipfactory() {
    while (true) {
        wait 10
        if (storedships < 15) {
            if (storedships == 0) {//only send this message when storage was empty before
                //Chat_ServerBroadcast ("\x1b[94mA ship has finished production and is now in storage!\x1b[0m")
                foreach (player in GetPlayerArray()) {
                    if (IsValid(player)) {
                        NSSendLargeMessageToPlayer( player, "一台飛船製造完成","可在終端呼叫", 3.5, "rui/callsigns/callsign_73_col" )
                    }
                }
            }
            storedships = storedships + 1
            buttonstatemanager()
        }

    }
}

/////////////////////////////selectpanels///////////////////////////////////////////
void function createselectpanel(vector origin, vector angles){
    entity button = CreateEntity( "prop_dynamic" )
    button.SetValueForModelKey( $"models/props/global_access_panel_button/global_access_panel_button_console.mdl"  )
    button.kv.solid = SOLID_VPHYSICS



	button.SetOrigin( origin )
	button.SetAngles( angles )
	DispatchSpawn( button )

    SetTeam( button, TEAM_BOTH )

    thread setselectpanelactive(button)

}

bool StatusMessageTimeOutInProg = false
bool selectedtypechanged = false

void function setselectpanelactive(entity button) {

    button.SetUsePrompts( "按 %use% " + "  以改變飛船種類", "按 %use%" + " 以改變飛船種類" )
    button.SetUsableByGroup( "pilot" )
    button.SetUsable()


    entity player = expect entity( button.WaitSignal( "OnPlayerUse" ).player )

    selectedtypeid = selectedtypeid + 1
    if ( selectedtypeid == 1) {selectedtype = "哥布林級雙人飛船"}
    if ( selectedtypeid == 2) {selectedtype = "烏鴉級火箭轟炸飛船"}
    if ( selectedtypeid == 3) {selectedtype = "高能層子激光攻擊飛船"; selectedtypeid = 0}


    EmitSoundOnEntity( button, "Switch_Activate" )

    //Chat_ServerPrivateMessage(player,"\x1b[33mSwitched shipclass to: \x1b[31"+selectedtype+"!\x1b[0m",false)

    selectedtypechanged = true
    NSDeleteStatusMessageOnPlayer(  player, "SHIPTYPESTATUS" )
    NSCreateStatusMessageOnPlayer(player,"Ship Type: "+selectedtype,"","SHIPTYPESTATUS")
    thread StatusMessageTimeOut(player)


    button.UnsetUsable()

    setselectpanelactive(button)

}

void function StatusMessageTimeOut(entity player) {
    if (StatusMessageTimeOutInProg == false ) {
        StatusMessageTimeOutInProg = true
        selectedtypechanged = false
        wait 3
        if (selectedtypechanged == false) {
            NSDeleteStatusMessageOnPlayer(  player, "SHIPTYPESTATUS" )
        }
        StatusMessageTimeOutInProg = false
    } else { //ensures that a statusmessage cant be stuck , by repeating this function until the statusmsg is deleted
        WaitFrame()
        StatusMessageTimeOut(player)
    }
}


/////////////////////////////utility///////////////////////////////////////////
bool function PlayerPosInSolid( entity player, vector targetPos ) //checks if a the player would be clipping if he were in targetpos
{
    int solidMask = TRACE_MASK_PLAYERSOLID
    vector mins
    vector maxs
    int collisionGroup = TRACE_COLLISION_GROUP_PLAYER
    array<entity> ignoreEnts = []
    ignoreEnts.append( player ) //in case we want to check player's current pos
    TraceResults result

    mins = player.GetPlayerMins()
    maxs = player.GetPlayerMaxs()
    result = TraceHull( targetPos, targetPos + Vector( 0, 0, 1), mins, maxs, ignoreEnts, solidMask, collisionGroup )
    if ( result.startSolid )
        return true

    return false

}


//NOTE TO SELF:
//Rn all buttons on a map act as 'one' , because they all use the same state varibales.
//That isnt a problem now because there arent multiple buttons on a map , but if I want to do that I need to use tables with <entity ,bool> to keep track of the states of the buttons

//changes in 1.1: added exoplanet bay , ships now have a fly in 'animation' (they just move down a bit)
//changes in 1.4: added text color
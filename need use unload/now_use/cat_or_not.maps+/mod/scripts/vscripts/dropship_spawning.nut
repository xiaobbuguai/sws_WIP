global function Init_DropShipSpawning

void function Init_DropShipSpawning()
{
    AddChatcommand( "!dropship", Callback_ValidateDropShipRequest )
    AddClientCommandCallback( "dropship", Callback_ValidateDropShipRequest )
    AddChatcommand( "!gunship", Callback_ValidateGunshipRequest )
    AddClientCommandCallback( "gunship", Callback_ValidateGunshipRequest )
}

bool function Callback_ValidateGunshipRequest( entity player, array<string> args )
{
    return Callback_ValidateDropShipRequest( player, ["2"] )
}

bool function Callback_ValidateDropShipRequest( entity player, array<string> args )
{
    if ( !IsValid( player ) || !IsAlive( player ) || IsValid( player.GetParent() ) || IsLobby() )
        return true

    if ( !GetConVarBool( "dropships_enabled" ) )
		return CancelRequest( player, "dropships are disabled by host" )

    if ( GetEntArrayByScriptName( "drivable_dropship" ).len() > 10 )
		return CancelRequest( player, "Too many dropships" )
    
    if ( PlayerEarnMeter_GetOwnedFrac( player ) < 0.5 )
		return CancelRequest( player, "You need 50%" )
    
    
    #if DROPSHIP_MOD
        vector origin = player.GetOrigin()
        origin.z += 4000 - origin.z

        string ShipType = "dropship"
        if ( args.len() > 0 && args[0] == "2" )
            ShipType = "gunship"

        DropShiptruct dropship = SpawnDrivableDropShip( origin, CONVOYDIR, player.GetTeam(), ShipType )
        
        EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "dropship_warpin" )

        entity fx = PlayFX( TURBO_WARP_FX, origin, player.GetAngles() + <0,90,0> )
        fx.FXEnableRenderAlways()
        fx.DisableHibernation()

        dropship.dropship.model.Signal( "OnPlayerUse", {player = player} )
    #else
        print("cat_or_not.DropshipDrivable isn't installed >:(")
    #endif

    float oldRewardFrac = PlayerEarnMeter_GetRewardFrac( player )
    PlayerEarnMeter_Reset( player )
    PlayerEarnMeter_SetRewardFrac( player, oldRewardFrac )
    PlayerEarnMeter_EnableReward( player )

    if ( PlayerEarnMeter_GetRewardFrac( player ) != 0 )
        PlayerEarnMeter_EnableReward( player )
    
    return true
}

bool function CancelRequest( entity player, string message )
{
    Chat_ServerPrivateMessage( player, message, false )
    return true
}
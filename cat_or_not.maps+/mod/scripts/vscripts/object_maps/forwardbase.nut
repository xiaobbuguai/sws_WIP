global function placeForwardBaseObjects
global function callback_ValidateVoperRequest

struct
{
    bool isthere = false
    bool teleporter_thinking = false
    bool voper_fight_started = false
} file

void function placeForwardBaseObjects()
{
    CreateSimpleButton( < -425, 220, 1000 >, <90, 0, 0>, "重力電梯", callback_ButtonTriggered, 5.0 )
    CreateSarahCoffeMaker( <2192.82, -1980.45, 1051.03>, <0,270,0> )
    //CreateAshPeaceKraberSeller( <1979.14, -1980.11, 1051.03>, <0,0,0> )

    InitKeyTracking()
    CraneCreate( < -2359, 1070, 1236 >, <0,0,0> )
    CraneCreate( <2049, -1222, 1136>, <0,0,0> )
    CraneCreate( <730, 4472, 877>, <0,0,0> )

    entity spinning_thing = CreateEntity( "prop_dynamic" )
    spinning_thing.SetValueForModelKey( $"models/props/generator_coop/generator_coop_rings_animated.mdl" )
    spinning_thing.SetAngles( <0,0,0> )
    spinning_thing.SetOrigin( < -69, 374, 800 > )
    spinning_thing.kv.modelscale = 2
    spinning_thing.kv.solid = 0

    SetTeam( spinning_thing, TEAM_ANY )
    DispatchSpawn( spinning_thing )
    spinning_thing.SetScriptName( "base_grav" )

    entity mover = CreateOwnedScriptMover( spinning_thing )
    spinning_thing.SetParent( mover )
    mover.SetScriptName( "base_grav_mover" )


    thread RemoveLift()

    CreateNessy( < -784, 476, 960 >, <0, 60, 0>, 3 )

    CreateSimpleButton( < 1185, 905, 1140 >, <0, 0, 30>, "傳送門3，啟動！", callback_ValidatePortalRequest, 120.0 )

    CreateSimpleButton( < 1185, 1105, 1340 >, <0, 0, 0>, "召喚來自小b的毒蛇", callback_ValidateVoperRequest, 1.0 )
}

void function callback_ButtonTriggered( entity button, entity player )
{
    if ( file.isthere )
    {
        thread RemoveLift()
    }
    else
    {
        thread Lift()
    }

    file.isthere = !file.isthere
}

void function RemoveLift()
{
    entity spinning_thing = GetEntArrayByScriptName( "base_grav" )[0]
    // spinning_thing.Anim_Play( "generator_fall" )

    entity mover = GetEntArrayByScriptName( "base_grav_mover" )[0]
    mover.NonPhysicsMoveTo( mover.GetOrigin() - <0,0,1000>, 2, 0.1, 0.1 )

    wait 3
    spinning_thing.Hide()
}

void function Lift()
{

    entity mover = GetEntArrayByScriptName( "base_grav_mover" )[0]
    mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,0,1000>, 2, 0.1, 0.1 )

    entity spinning_thing = GetEntArrayByScriptName( "base_grav" )[0]
    spinning_thing.Show()

    wait 3

    spinning_thing.Anim_Play( "generator_cycle_fast" )

    thread GravLiftthink( mover )
}

void function GravLiftthink( entity mover )
{
    vector origin = mover.GetOrigin()

    while( file.isthere )
    {
        wait 0.0001
        foreach( entity player in GetPlayerArray() )
        {
            if ( distance( player.GetOrigin(), origin ) < 200 && player.GetOrigin().z < 1500 )
            {
                player.kv.gravity = -0.6

                if ( player.IsOnGround() )
                    player.SetVelocity( player.GetVelocity() + <0,0,400> )
            }
            else
                player.kv.gravity = 0.0
        }

    }
}

float function distance( vector origin1, vector origin2 )
{
    float X1 = origin1.x
    float Y1 = origin1.y
    float X2 = origin2.x
    float Y2 = origin2.y

    return sqrt(pow(X1-X2, 2) + pow(Y1-Y2, 2) )
}

void function callback_ValidatePortalRequest( entity button, entity player )
{
    // hack
    button.UnsetUsable()
    EmitSoundOnEntity( button, "Switch_Activate" )
    button.SetSkin( 1 )

    //if ( GetDisabledElements().contains( "voper" ) )
    //{
    //    NSSendPopUpMessageToPlayer( player, "voper is disabled on this server D:" )
    //    return
    //}
//
    //if ( !HasAllNessies() )
    //{
    //    foreach( entity p in GetPlayerArray() )
    //        NSSendPopUpMessageToPlayer( p, "You don't have all the nessies [" + CountNessy() + " out of 4 ]")
//
    //    return
    //}
//
   // foreach( entity p in GetPlayerArray() )
    //    NSSendPopUpMessageToPlayer( p, "You Collected all the nessies [" + CountNessy() + " out of 4 ]" )
//
//
    // CreateLightSprite( <1050, 1361, 1000>, <0,0,0> )
    entity env_sprite = CreateEntity( "env_sprite" )
	// env_sprite.SetScriptName( UniqueString( "molotov_sprite" ) )
	env_sprite.kv.rendermode = 5
	env_sprite.kv.origin = <1118, 1361, 1116>
	env_sprite.kv.angles = <0,0,0>
	env_sprite.kv.rendercolor = < 0, 0, 255 >
	env_sprite.kv.renderamt = 255
	env_sprite.kv.framerate = "10.0"
	env_sprite.SetValueForModelKey( $"sprites/glow_05.vmt" )
	env_sprite.kv.scale = string( 8 )
	env_sprite.kv.spawnflags = 1
	env_sprite.kv.GlowProxySize = 16.0
	env_sprite.kv.HDRColorScale = 1.0
	DispatchSpawn( env_sprite )
	EntFireByHandle( env_sprite, "ShowSprite", "", 0, null, null )

    teleporterThink( env_sprite )
}

void function teleporterThink( entity env_sprite )
{
    if ( file.teleporter_thinking )
        return

    file.teleporter_thinking = !file.teleporter_thinking

    vector origin = env_sprite.GetOrigin()
    for(;;)
    {
        foreach( entity player in GetPlayerArray() )
        {
            if ( distance( player.GetOrigin(), origin ) < 200 && player.GetOrigin().z < 1100 )
            {
                thread MovePlayer( player, <776, 889, 960> )
            }
        }
        WaitFrame()
    }

}

void function callback_ValidateVoperRequest( entity button, entity player )
{
    //thread MovePlayer( player, < -151, 1091, 1472 > )

    //if ( GetDisabledElements().contains( "voper" ) )
    //{
    //    NSSendPopUpMessageToPlayer( player, "voper is disabled on this server D:" )
    //    return
    //}
//
    //if ( !HasAllNessies() )
    //{
    //    foreach( entity p in GetPlayerArray() )
    //        NSSendPopUpMessageToPlayer( p, "You don't have all the nessies [" + CountNessy() + " out of 4 ]" )
//
    //    return
    //}

    if ( file.voper_fight_started )
        return

    file.voper_fight_started = !file.voper_fight_started

    StartVoperBattle( 0 )

    //if ( GetMapName() != "mp_forwardbase_kodai" || ( GAMETYPE != "tdm" && GAMETYPE != "aitdm" ) )
    //{
    //    if ( GAMETYPE != "aitdm" )
    //    {
    //        foreach( entity p in GetPlayerArray() )
    //            NSSendPopUpMessageToPlayer( p, "gamemode is not skirmish, voper didn't arrive" )
    //    }
    //    else
    //    {
    //        GameRules_ChangeMap( "mp_forwardbase_kodai" , "tdm" )
    //    }
//
    //    return
    //}
//
    ResetNessy()
}

void function MovePlayer( entity player, vector origin )
{
    // why is this so bad
    ScreenFadeToBlack( player, 1, 1 )

    wait 1

    player.SetOrigin( origin )
}
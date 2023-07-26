global function placeBoxObjects

const vector weaponsSpawn = < -1730, -3060, 100 >

void function placeBoxObjects()
{
    if ( GetDisabledElements().contains( "box_test" ) )
        return

    entity button = CreateSimpleButton( weaponsSpawn, <90, 90, 0>, "to spawn weapons", callback_WeaponsButtonTriggered )
    entity button2 = CreateSimpleButton( weaponsSpawn - <1000,0,0>, <90, 90, 0>, "to spawn a dropship", callback_dropShipButtonTriggered, 10.0 )
    CreateSimpleButton( weaponsSpawn - <1100,0,0>, <90, 90, 0>, "to become a pilot", callback_pilotButtonTRiggered, 10.0 )
    CreateSimpleButton( weaponsSpawn - <1200,0,0>, <90, 90, 0>, "to become a titan", callback_titanButtonTRiggered, 10.0 )
    CreateNessyMessager( button2.GetOrigin() + <0,30,-300>, <0,180,0>, "" )
    CreateSimpleButton( < -5037, 3318 ,0 >, <0, 0, 0>, "to train you aim XD", callback_AimTrainner, 30.0 )

    CreateNessy( <0, 2214, 576>, <0, 60, 0>, 9 )

    SpawnWeapons()

    entity mover = CreateExpensiveScriptMoverModel( $"models/communication/terminal_usable_imc_01.mdl", <100, 2214, 576>, <0,0,0>, SOLID_VPHYSICS, 5000 )
    mover.kv.contents = ( int( mover.kv.contents ) | CONTENTS_MOVEABLE )

    // entity brush = CreateEntity( "func_brush" )
    // DispatchSpawn( brush )
    // brush.SetOrigin( <100, 2214, 600> )

    AddCallback_EntitiesDidLoad( EntitiesDidLoad )

    entity ref = CreateEntity( "script_ref" )
    DispatchSpawn( ref )
    ref.SetOrigin( <500, 2214, 576> )

    // SpawnPropGenerator( ref )
}

void function EntitiesDidLoad()
{
    thread RunRecordingLoop()
}

void function SpawnWeapons()
{
    array<string> weapons = GetAllWeaponsByType( [ eItemTypes.PILOT_PRIMARY, eItemTypes.PILOT_SECONDARY ] )

    for ( int x = 0; x < weapons.len(); x++ )
    {
        entity weapon = CreateWeaponEntityByNameConstrained( weapons[x], weaponsSpawn + < ( x + 1 )*-30, 0, 0 >, <90,90,0> )
        weapon.SetScriptName( "weapon_pickup" )
    }      
}

void function DestoryWeapons()
{
    foreach( entity weapon in GetEntArrayByScriptName( "weapon_pickup" ) )
    {
        if ( !IsValid( weapon.GetParent() ) )
            weapon.Destroy()
    }
}

void function callback_WeaponsButtonTriggered( entity button, entity player )
{
    DestoryWeapons()
    SpawnWeapons()
}

void function callback_pilotButtonTRiggered( entity button, entity player )
{
    if ( !player.IsTitan() )
        return
    
    entity t = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
		
    TitanBecomesPilot( player, t )
    t.Destroy()
}

void function callback_titanButtonTRiggered( entity button, entity player )
{
    if ( player.IsTitan() )
        return

    entity t = player.GetPetTitan()
    if ( !IsValid( player.GetPetTitan() ) )
    {
        t = CreateAutoTitanForPlayer_FromTitanLoadout( player, GetTitanLoadoutForPlayer( player ), player.GetOrigin(), <0,0,0> )
        DispatchSpawn( t )
    }

    PilotBecomesTitan( player, t )

    t.Destroy()
}

void function RunRecordingLoop()
{
    for(;;)
    {
        waitthread PlayRecoding_recording_loop()
    }
}

void function callback_AimTrainner( entity button, entity player )
{
    thread PlayRecoding_recording_aim()
}
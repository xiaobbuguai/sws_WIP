untyped

global function precache_needed_stuff_like_rn
global function CreateSmallElevator
global function CreateSimpleButton
global function CreateNessy
global function CountNessy
global function HasAllNessies
global function ResetNessy
global function CatPrint
global function CreatePhaseTeleporter
global function CreateHackPanel
global function SetMapMissionComple
global function GetDisabledElements

void function precache_needed_stuff_like_rn()
{
    PrecacheModel( $"models/props/turret_base/turret_base.mdl" )
    PrecacheModel( $"models/signs/flag_base_pole_ctf.mdl" )
    PrecacheModel( $"models/communication/terminal_usable_imc_01.mdl" )
    PrecacheModel( $"models/domestic/nessy_doll.mdl" )
    PrecacheModel( $"models/humans/heroes/mlt_hero_jack_helmet_static.mdl" )
    PrecacheModel( $"models/humans/heroes/imc_hero_blisk.mdl" )

    // prowler
    PrecacheModel( $"models/creatures/prowler/r2_prowler.mdl" )
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_01.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_02.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_05.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_06.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_07.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_08.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_09.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_10.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_corpse_static_12.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_dead_static_07.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_dead_static_08.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_dead_static_09.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_dead_static_10.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_dead_static_11.mdl")
    PrecacheModel($"models/creatures/prowler/prowler_death1_static.mdl")

    //turrets
    PrecacheModel($"models/robotics_r2/heavy_turret/mega_turret.mdl")
    PrecacheModel($"models/robotics_r2/turret_plasma/plasma_turret_pc_1.mdl")
    PrecacheModel($"models/robotics_r2/turret_plasma/plasma_turret_pc_2.mdl")
    PrecacheModel($"models/robotics_r2/turret_plasma/plasma_turret_pc_3.mdl")
    PrecacheModel($"models/robotics_r2/turret_rocket/rocket_turret_posed.mdl")

    // drones
    PrecacheModel($"models/robots/drone_air_attack/drone_air_attack_plasma.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_air_attack_rockets.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_air_attack_static.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_attack_pc_1.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_attack_pc_2.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_attack_pc_3.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_attack_pc_4.mdl")
    PrecacheModel($"models/robots/drone_air_attack/drone_attack_pc_5.mdl")

    PrecacheModel( $"models/communication/terminal_usable_imc_01.mdl" )
	// PrecacheModel( $"models/weapons/sentry_turret/sentry_turret.mdl" )
    PrecacheWeapon( "mp_turretweapon_blaster" )

    PrecacheParticleSystem( $"P_smokescreen_FD" )
    PrecacheParticleSystem( $"P_phase_shift_main" )
    // PrecacheModel( $"particle/water/bubble.vmt" )

    PrecacheModel( $"models/humans/pilots/pilot_medium_geist_m.mdl" )
    PrecacheModel( $"models/humans/pilots/pilot_light_jester_m.mdl" ) 
    PrecacheModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
    PrecacheModel( $"models/weapons/rspn101/w_rspn101.mdl" )

    PrecacheModel( $"models/vistas/planet_blue_sun.mdl" ) // should be removed soon, will cause massive errors
}

void function CreateSmallElevator( vector origin, vector origin2, int time )
{
    entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", origin, <0,0,0>, SOLID_VPHYSICS, 5000 )
    mover.SetPusher( true )
    thread ElevatorThink( mover, origin, origin2, time )
}

void function ElevatorThink( entity mover, vector origin, vector origin2, int time  )
{
    for(;;)
    {
        mover.NonPhysicsMoveTo( origin2, time - 2, 0.1, 0.1 )
        wait time

        mover.NonPhysicsMoveTo( origin, time - 2, 0.1, 0.1 )
        wait time
    }
}

entity function CreateSimpleButton( vector origin, vector angles, string text, void functionref( entity, entity ) callback, float WaitTime = 30.0 )
{
    entity button = CreateEntity( "prop_dynamic" )

    button.SetValueForModelKey( $"models/props/global_access_panel_button/global_access_panel_button_console.mdl" )
	button.kv.fadedist = 10000
	button.kv.renderamt = 255
	button.kv.rendercolor = "81 130 151"
	button.kv.solid = SOLID_VPHYSICS

    // button.kv.multiUseDelay = 30
    // button.kv.editorclass = "script_switch"

	SetTeam( button, TEAM_BOTH )
	button.SetOrigin( origin )
	button.SetAngles( angles )
	DispatchSpawn( button )

    button.SetUsable()
    button.SetUsableByGroup( "pilot" )
    button.SetUsePrompts( "Hold %use% " + text, "Press %use% " + text )
	thread ButtonThink( button, callback, WaitTime )

    return button

}

void function ButtonThink( entity button, void functionref( entity, entity ) callback, float WaitTime )
{
    while ( IsValid( button ) )
    {
        button.SetUsable()
        button.SetSkin( 0 )

        entity player = expect entity( button.WaitSignal( "OnPlayerUse" ).player )
        callback( button, player )

        button.UnsetUsable()
        EmitSoundOnEntity( button, "Switch_Activate" )
        button.SetSkin( 1 )
        wait WaitTime
    }
}

void function CreateNessy( vector origin, vector angles, int id )
{
    entity nessy = CreatePropDynamic( $"models/domestic/nessy_doll.mdl", origin, angles, SOLID_VPHYSICS, 1000 )
    nessy.SetScriptName( "Nessy" )
    thread NessyThink( nessy, id )

    nessy.SetUsable()
    nessy.SetUsableByGroup( "pilot" )
    nessy.SetUsePrompts( "Hold %use% to grab nessy", "Press %use% to grab nessy" )
}

void function NessyThink( entity nessy, int id )
{
    entity player = expect entity( nessy.WaitSignal( "OnPlayerUse" ).player )

    SetNessyFound( id )

    foreach( entity p in GetPlayerArray() )
        NSSendPopUpMessageToPlayer( p, player.GetPlayerName() + " found a nessy [" + CountNessy() + " out of 4 ]" )
    

    nessy.UnsetUsable()
    EmitSoundOnEntity( nessy, "pilot_collectible_pickup" )
    nessy.Dissolve( ENTITY_DISSOLVE_CORE, Vector( 0, 0, 0 ), 500 )
}

void function SetNessyFound( int nid )
{
    string nessies = GetConVarString("Nessy")
    string new_nessies
    for( int id = 0; id != nessies.len(); id++ )
    {
        if ( id == nid )
            new_nessies += "1"
        else
            new_nessies += format( "%c", nessies[id] )
    }

    SetConVarString( "Nessy", new_nessies )
}

int function CountNessy()
{
    string nessies = GetConVarString("Nessy")
    int nessy_count = 0
    for( int id = 0; id != nessies.len(); id++ )
    {
        if ( format( "%c", nessies[id] ) == "1" )
            nessy_count++
        
    }
    
    return nessy_count
}

void function ResetNessy()
{
    string nessies = GetConVarString("Nessy")
    string new_nessies
    for( int id = 0; id != nessies.len(); id++ )
    {
        new_nessies += "0"
    }

    SetConVarString( "Nessy", new_nessies )
}

bool function HasAllNessies()
{
    if ( CountNessy() >= 4 )
        return true

    return false
}

void function CatPrint( string text )
{
    print( "------------------------" )
    print( text )
    print( "------------------------" )
}

void function CreateLightSpriteCustom( vector origin, vector rendercolor, string scale )
{
    entity env_sprite = CreateEntity( "env_sprite" )
	// env_sprite.SetScriptName( UniqueString( "molotov_sprite" ) )
	env_sprite.kv.rendermode = 5
	env_sprite.kv.origin = origin
	env_sprite.kv.angles = <0,0,0>
	env_sprite.kv.rendercolor = rendercolor
	env_sprite.kv.renderamt = 255
	env_sprite.kv.framerate = "10.0"
	env_sprite.SetValueForModelKey( $"sprites/glow_05.vmt" )
	env_sprite.kv.scale = scale
	env_sprite.kv.spawnflags = 1
	env_sprite.kv.GlowProxySize = 16.0
	env_sprite.kv.HDRColorScale = 1.0
	DispatchSpawn( env_sprite )
	EntFireByHandle( env_sprite, "ShowSprite", "", 0, null, null )
}

void function CreatePhaseTeleporter( vector origin1, vector origin2, bool onlyPilots = true )
{
    if ( GetDisabledElements().contains( "phase_teleporter" ) )
        return

    array<entity> ents = []
	entity trigger1 = _CreateScriptCylinderTriggerInternal( origin1, 50.0, TRIG_FLAG_PLAYERONLY, ents, 50.0, 0.0 )
	AddCallback_ScriptTriggerEnter( trigger1, OnTeleportTriggered )
    
    entity light1 = CreateLightSpriteCustom( origin1 + <0,0,50>, < 255, 0, 0 >, "3" )

    entity trigger2 = _CreateScriptCylinderTriggerInternal( origin2, 50.0, TRIG_FLAG_PLAYERONLY, ents, 50.0, 0.0 )
	AddCallback_ScriptTriggerEnter( trigger2, OnTeleportTriggered )

    entity light2 = CreateLightSpriteCustom( origin2 + <0,0,50>, < 0, 0, 255 >, "3" )

    trigger1.SetOwner( trigger2 )
    trigger2.SetOwner( trigger1 )
} 

void function OnTeleportTriggered( entity trigger, entity player )
{

    if ( player.IsPhaseShifted() || player.IsTitan() || !IsValid( player ) || !IsAlive( player ) || IsValid( player.GetParent() ) )
        return

    // print( "player entered teleporter at " + player.GetOrigin() )

    // thread OnTeleportTriggeredThreaded( trigger, player )

    PhaseShift( player, 0, 3 )
    player.SetOrigin( trigger.GetOwner().GetOrigin() )
}

void function OnTeleportTriggeredThreaded( entity trigger, entity player )
{
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )
}

entity function CreateHackPanel( vector origin, vector angles, OnPanelHacked )
{
    entity panel = CreateEntity( "prop_control_panel" )
	panel.SetValueForModelKey( $"models/communication/terminal_usable_imc_01.mdl" )
	panel.SetOrigin( origin )
	panel.SetAngles( angles )
	panel.kv.solid = SOLID_VPHYSICS
	DispatchSpawn( panel )
	
	panel.SetModel( $"models/communication/terminal_usable_imc_01.mdl" )
	panel.s.scriptedPanel <- true
    
    panel.s.startOrigin <- < 0, 0, 0 >
    panel.useFunction = ControlPanel_CanUseFunction
    panel.s.useFuncArray <- []
	
	SetControlPanelUseFunc( panel, OnPanelHacked )

    return panel
}

void function SetMapMissionComple( entity player, int id )
{
    foreach( entity p in GetPlayerArray() )
        NSSendPopUpMessageToPlayer( p, player.GetPlayerName() + " completed a mission" )
}

array<string> function GetDisabledElements()
{
    string disabled_elements = GetConVarString("disabled_elements")

    return split( disabled_elements, " " )
}
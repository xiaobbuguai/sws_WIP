global function placeGlitchObjects

const array<string> reward_weapons = [ "mp_titanweapon_triplethreat", "mp_weapon_gunship_turret", "mp_weapon_arena3" ]

struct
{
    bool isthere = false
    entity spectre
    entity panel
} file

const int moveTime = 5

void function placeGlitchObjects()
{
    // PrecacheModel( $"models/training/sp_training_wood_gunrack_01.mdl" )

    thread CreateGambleZone()

    CreateSimpleButton( < -167, 97, -55 >, <0, 75, 0>, "to control the bridge barriers", callback_ButtonTriggered )
    CreateSimpleButton( <1438,1260,296>, <0, 0, 0>, "to spawn a cute pet :3", callback_ButtonPetTriggered )
    CreateSimpleButton( < -2754, -5606, 516 >, <0, 90, 0>, "to gamble", callback_ButtonGambleTriggered, 7.0 )
    CreateSimpleButton( < -4461, -5571, 480 >, <0, 90, 0>, "to leave", teleport_from, 1.0 )

    CreateSmallElevator( < -1336, 125, -888 >, < -1263, 125, 1025 >, 6 )
    CreateSmallElevator( < 1002, 125, -888 >, < 1002, 125, 1025 >, 6 )
    
    for( int x = 0; x < 350; x += 50 )
    {
        entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -30 - x, -10, 35 >, <90,0,0>, SOLID_VPHYSICS, 10000 )
        mover.SetPusher( true )
        mover.SetScriptName( "glitch_blocker1" )
    }

    for( int x = 0; x < 350; x += 50 )
    {
        entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -30 - x, 260, 35 >, <90,0,0>, SOLID_VPHYSICS, 10000 )
        mover.SetPusher( true )
        mover.SetScriptName( "glitch_blocker1" )
    }

    thread LowerBlocker()

    CreateNessy( <1387.47, -507.165, 147.031>, <0, -60, 0>, 4 )

    entity nessy = CreatePropDynamic( $"models/domestic/nessy_doll.mdl", < -1373, -309, 272>, <0,180,0>, SOLID_VPHYSICS )
    nessy.SetUsableByGroup( "pilot" )
    string message = "земля русская?"
    nessy.SetUsePrompts( message, message )
    nessy.SetUsable()

    nessy = CreatePropDynamic( $"models/domestic/nessy_doll.mdl", < -1257, -543, 272>, <0,0,0>, SOLID_VPHYSICS )
    nessy.SetUsableByGroup( "pilot" )
    message = "сила земли!"
    nessy.SetUsePrompts( message, message )
    nessy.SetUsable()

    AddCallback_EntitiesDidLoad( EntitiesDidLoad )

    AddChatcommand( "sim_sim_teleport_me", teleport_to )
    AddChatcommand( "sstm", teleport_to )
    AddClientCommandCallback( "sim_sim_teleport_me", teleport_to )
    AddClientCommandCallback( "sstm", teleport_to )

    entity panel = CreatePropDynamic( $"models/communication/terminal_usable_imc_01.mdl", < -3095, -1185, 128 >, <0,0,0>, SOLID_VPHYSICS )
    panel.SetUsableByGroup( "pilot" )
    message = "We moved to a safer location; to access it, say the magic words."
    panel.SetUsePrompts( message, message )
    panel.SetUsable()
    file.panel = panel

    thread RunRecordingLoop()
}

void function EntitiesDidLoad()
{
    entity spectre = CreateNPC( "npc_spectre", TEAM_UNASSIGNED, < -2852, -5598, 481 >, <0,0,0>)
    SetSpawnOption_AISettings( spectre, "npc_spectre" )
    DispatchSpawn( spectre )

    spectre.SetInvulnerable()
    spectre.AssaultPoint( spectre.GetOrigin() )
    spectre.TakeOffhandWeapon( OFFHAND_LEFT )
    spectre.GiveOffhandWeapon( "mp_weapon_frag_grenade", OFFHAND_LEFT )

    file.spectre = spectre

    if ( GetDisabledElements().contains( "kraber_grunt" ) )
        return

    entity grunt = CreateNPC( "npc_soldier", 10, <2526,2313,140>, <0,0,0>)
    DispatchSpawn( grunt )

    grunt.SetInvulnerable()
    grunt.AssaultPoint( grunt.GetOrigin() )
    TakeAllWeapons( grunt )
    grunt.GiveWeapon( "mp_weapon_sniper" )
}

void function callback_ButtonTriggered( entity button, entity player )
{
    if ( file.isthere )
    {
        thread LowerBlocker()
    }
    else
    {
        thread RaiseBlocker()
    }

    file.isthere = !file.isthere
}

void function RaiseBlocker()
{
    foreach( entity mover in GetEntArrayByScriptName( "glitch_blocker1" ) )
    {
        mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,0,2200>, moveTime, 0.1, 0.1 )
    }

    wait moveTime + 1

    foreach( entity mover in GetEntArrayByScriptName( "glitch_blocker1" ) )
    {
        mover.NonPhysicsRotateTo( <90,90,0>, 0.5, 0.1, 0.1 )
    }
}

void function LowerBlocker()
{
    foreach( entity mover in GetEntArrayByScriptName( "glitch_blocker1" ) )
    {
        mover.NonPhysicsRotateTo( <90,0,0>, 0.5, 0.1, 0.1 )
    }

    wait 0.8

    foreach( entity mover in GetEntArrayByScriptName( "glitch_blocker1" ) )
    {
        mover.NonPhysicsMoveTo( mover.GetOrigin() - <0,0,2200>, moveTime, 0.1, 0.1 )
    }
}

void function callback_ButtonPetTriggered( entity button, entity player )
{
    entity drone = CreateNPC( "npc_drone", player.GetTeam(), player.GetOrigin(), <0,0,0> )
    SetSpawnOption_AISettings( drone, "npc_drone" )
    DispatchSpawn( drone )

    int followBehavior = GetDefaultNPCFollowBehavior( drone )
    drone.InitFollowBehavior( player, followBehavior )
    drone.EnableBehavior( "Follow" )
    drone.SetTitle( player.GetPlayerName() + "'s pet" )
}

void function callback_ButtonGambleTriggered( entity button, entity player )
{
    thread ButtonGambleTriggeredThreaded( button, player )
}

void function ButtonGambleTriggeredThreaded( entity button, entity player )
{
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )

    player.SetParent( button )

    string str = ""
    for( int x = 0; x < 10; x++ )
    {
        str += "-"
        SendHudMessage( player, str, -1, 0.2, 42, 128, 0, 0, 0.15, 1, 0 )
        EmitSoundOnEntityOnlyToPlayer( player, player, "Menu_AdvocateGift_Open" )
        wait 0.2
    }

    if ( RandomInt( 4 ) != 3 )
    {
        thread GambleDeath( player )
        return
    }

    EmitSoundOnEntityOnlyToPlayer( player, player, "menu_accept" )

    player.ClearParent()

    switch( RandomInt( 5 ) )
    {
        case 4:
        case 0:
            thread GiveRandomWeapon( player )
            break
        case 1:
            StimPlayer( player, 1000000 )
            break
        case 2:
            player.SetMaxHealth( 150 )
            break
        case 3:
            thread GivePhastShiftInf( player )
            break
    }
}

void function GiveRandomWeapon( entity player )
{
    player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() )
    WaitFrame()
    if ( IsAlive( player ) && GetPrimaryWeapons( player ).len() == 2 )
        player.GiveWeapon( reward_weapons.getrandom() )
}

void function GivePhastShiftInf( entity player )
{
    player.TakeOffhandWeapon( OFFHAND_SPECIAL )
    WaitFrame()
    if ( IsAlive( player ) && !IsValid( player.GetOffhandWeapon( OFFHAND_SPECIAL ) ) )
        player.GiveOffhandWeapon( "mp_ability_shifter_super", OFFHAND_SPECIAL, [] )
}

void function GambleDeath( entity player )
{
    // would have been cool :(
    // SyncedMeleeChooser ornull actions = GetSyncedMeleeChooserForPlayerVsTarget( file.pilot, player )
	// if ( actions == null )
	// {
    //     print( "can't melee" )
    //     return
    // }
	// expect SyncedMeleeChooser( actions )

	// SyncedMelee ornull action = FindBestSyncedMelee( file.pilot, player, actions )
	// if ( action == null )
	// {
    //     print( "can't melee" )
    //     return
    // }
    // expect SyncedMelee( action )

    // MeleeThread_PilotVsEnemy( action, file.pilot, player )

    entity spectre = file.spectre
    entity weapon = spectre.GetOffhandWeapon( OFFHAND_LEFT )

    EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
    
    for( int x = 0; x < 5; x++ )
        weapon.FireWeaponGrenade( spectre.GetOrigin() + <0,0,50>, <0,180,0>, <0,0,0>, 1, damageTypes.projectileImpact, damageTypes.explosive, false, true, false )
}

bool function teleport_to( entity player, array<string> args )
{
    if ( !IsValid( player ) || !IsAlive( player ) )
        return true
    
    if ( Distance2D( file.panel.GetOrigin(), player.GetOrigin() ) > 500 )
    {
        Chat_ServerPrivateMessage( player, "too far from panel", false )
        return true
    }
    
    PhaseShift( player, 0, 1 )
    player.SetOrigin( < -4461, -5571, 500 > )
    player.SetAngles( <0,0,0> )

    thread threaded_remove_outofbounds_timer( player )

    player.SetSkyCamera( GetEnt( SKYBOXSPACE ) ) 

    return true
}

void function threaded_remove_outofbounds_timer( entity player )
{
    player.Signal( "OutOfBounds" )

    wait 0.5

    player.SetOutOfBoundsDeadTime( 0.0 )
    player.Signal( "BackInBounds" )
}

void function teleport_from( entity button, entity player )
{
    if ( !IsValid( player ) || !IsAlive( player ) )
        return
    
    PhaseShift( player, 0, 1 )
    player.SetOrigin( < -2818, -1145, 951 > )

    player.SetSkyCamera( GetEnt( SKYBOXLEVEL ) ) 
}

void function RunRecordingLoop()
{
    if ( GetDisabledElements().contains( "past_pilots" ) )
        return

    wait RandomIntRange( 60, 180 )
    for(;;)
    {
        entity pilot = CreateElitePilot( 1, <0,1000,10000>, <0,0,0> )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
		DispatchSpawn( pilot )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
        pilot.kv.skin = PILOT_SKIN_INDEX_GHOST
		pilot.Freeze()
        pilot.SetTitle( "stabcat" )
        SetTeam( pilot, TEAM_IMC )

        thread PlayRecoding_recording_glitchPastPilot2( pilot )

        wait 1.5

        pilot = CreateElitePilot( 1, <0,1000,10000>, <0,0,0> )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
		DispatchSpawn( pilot )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
        pilot.kv.skin = PILOT_SKIN_INDEX_GHOST
		pilot.Freeze()
        pilot.SetTitle( "cat_or_not" )
        SetTeam( pilot, TEAM_MILITIA )

        thread PlayRecoding_recording_glitchPastPilot1( pilot )
        // wait RandomIntRange( 120, 240 )
        wait RandomIntRange( 10, 30 )
    }
}
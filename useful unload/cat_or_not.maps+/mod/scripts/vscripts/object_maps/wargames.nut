global function placeWarGameObjects
global function CreateAshPeaceKraberSeller

struct
{
    bool isthere = false
} file

const float moveTime = 0.5
const int moveDistance = 75

void function placeWarGameObjects()
{
    PrecacheModel( $"models/levels_terrain/mp_wargames/wargames_upmart_glitch.mdl" )

    CreateSimpleButton( <758, 0, 104>, <0, 90, 0>, "to control the bridge", callback_ButtonTriggered ) // was z 66
    
    CreatePropDynamic( $"models/levels_terrain/mp_wargames/wargames_upmart_glitch.mdl", <758, 70, 64>, <0, 135, 0>, SOLID_VPHYSICS, 10000 )

    for( int x = 0; x < 5; x++ )
    {
        foreach( int offset in [-moveDistance,0,moveDistance]  )
        {
            entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", <88 - offset, -342, -148>, <0,0,0>, SOLID_VPHYSICS, 1000 )
            mover.SetPusher( true )
            mover.SetScriptName( "wargames_bridge2"+x )
        }
    }

    for( int x = 0; x < 5; x++ )
    {
        foreach( int offset in [-moveDistance,0,moveDistance]  )
        {
            entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", <88 - offset, 347, -148>, <0,0,0>, SOLID_VPHYSICS, 1000 )
            mover.SetPusher( true )
            mover.SetScriptName( "wargames_bridge1"+x )
        }
    }

    CreateNessy( < -536.204, 142.314, 204.031 >, <0, 0, 0>, 0 )

    CreateSarahCoffeMaker( < -2620, 1586, 116 >, <0,0,0> )
    CreateAshPeaceKraberSeller( < -2718, 1227, -87 >, <0,180,0> )
}

void function callback_ButtonTriggered( entity panel, entity player )
{
    if ( !file.isthere )
    {
        thread extandBridge1()
        thread extandBridge2()
    }
    else
    {
        thread contractBridge2()
        thread contractBridge1()
    }

    file.isthere = !file.isthere
}

void function extandBridge2()
{
    for( int x = 0; x < 5; x++ )
    {
        foreach( entity mover in GetEntArrayByScriptName( "wargames_bridge2"+x )  )
        {
            mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,moveDistance*x,15>, moveTime, 0.1, 0.1 )
        }
        wait moveTime + 0.3
    }
}

void function extandBridge1()
{
    for( int x = 0; x < 5; x++ )
    {
        foreach( entity mover in GetEntArrayByScriptName( "wargames_bridge1"+x )  )
        {
            mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,-moveDistance*x,15>, moveTime, 0.1, 0.1 )
        }
        wait moveTime + 0.3
    }
}

void function contractBridge2()
{
    for( int x = 4; x >= 0; x-- )
    {
        foreach( entity mover in GetEntArrayByScriptName( "wargames_bridge2"+x )  )
        {
            mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,-moveDistance*x,-15>, moveTime, 0.1, 0.1 )
        }
        wait moveTime + 0.3
    }
}

void function contractBridge1()
{
    for( int x = 4; x >= 0; x-- )
    {
        foreach( entity mover in GetEntArrayByScriptName( "wargames_bridge1"+x )  )
        {
            mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,moveDistance*x,-15>, moveTime, 0.1, 0.1 )
        }
        wait moveTime + 0.3
    }
}

void function CreateAshPeaceKraberSeller( vector origin, vector angles )
{
    if ( GetDisabledElements().contains( "ash" ) )
        return

    entity ash = CreateEntity( "prop_dynamic" )

    ash.SetValueForModelKey( $"models/humans/heroes/imc_hero_ash.mdl" )
	ash.kv.fadedist = 1000
	ash.kv.renderamt = 255
	ash.kv.rendercolor = "81 130 151"
	ash.kv.solid = SOLID_VPHYSICS

    ash.SetOrigin( origin )
	ash.SetAngles( angles )
	DispatchSpawn( ash )

    ash.Anim_Play( "Ash_menu_pose_alt" )
    SetTeam( ash, TEAM_BOTH )

    entity prop = CreateEntity( "prop_dynamic" )

    prop.SetValueForModelKey( $"models/dev/editor_ref.mdl" )
	prop.kv.fadedist = 1000
	prop.kv.renderamt = 255
	prop.kv.rendercolor = "81 130 151"
	prop.kv.solid = SOLID_VPHYSICS
    

	SetTeam( prop, TEAM_BOTH )
	prop.SetOrigin( origin )
	prop.SetAngles( angles )
	DispatchSpawn( prop )
    prop.Hide()

    prop.SetUsable()
    prop.SetUsableByGroup( "pilot" )
    prop.SetUsePrompts( "Hold %use% to get a PeaceKraber", "Press %use% to get a PeaceKraber" )
	thread AshThink( prop, ash )
}

void function AshThink( entity prop, entity ash )
{
    while ( IsValid( prop ) && IsValid( ash ) )
    {
        prop.SetUsable()
        ash.SetSkin( 0 )

        entity player = expect entity( prop.WaitSignal( "OnPlayerUse" ).player )
        if ( IsAlive( player ) && IsValid( player ) )
            player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() )
        WaitFrame()
        if ( IsAlive( player ) && GetPrimaryWeapons( player ).len() == 2 )
            player.GiveWeapon( "mp_weapon_peacekraber" )

        prop.UnsetUsable()
        ash.SetSkin( 1 )
        wait 5
    }
}
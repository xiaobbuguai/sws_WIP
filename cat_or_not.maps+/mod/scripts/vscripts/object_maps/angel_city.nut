global function placeAngelCityObjects
global function CreateSarahCoffeMaker

// $"models/robots/aerial_unmanned_worker/worker_drone_pc4.mdl"
const asset Sarah = $"models/humans/heroes/mlt_hero_sarah.mdl"
const asset Pallet = $"models/containers/plastic_pallet_01.mdl"

struct Path
{
    void functionref( entity, vector, vector ) handler
    vector origin
    vector angles
}

struct
{
    int TrainSpeed = 500
} file

void function placeAngelCityObjects()
{
    CreateNessy( <540, 2316, 169>, <0, 60, 0>, 7 )
    CreateSarahCoffeMaker( <1196, 879, 140>, <0,270,0> )
    //CreateAshPeaceKraberSeller( < 1555, 903, 167 >, <0,0,0> )

    if ( !GetDisabledElements().contains( "gunship_station" ) )
    {
        entity button = CreateSimpleButton( < -1526, 1314, 960 >, <0,0,0>, "to spawn a gunship", callback_dropShipButtonTriggered, 40.0 )
        button.SetScriptName( "gunship_spawner" )
        CreateNessyMessager( button.GetOrigin() + <0,30,0>, <0,180,0>, "to get a gunship type !gunship in chat" )
    }

    CreatePhaseTeleporter( <1873.07, -3554.51, 208.031>, <3593.64, 885.446, 171.031> )
    CreatePhaseTeleporter( < -4499.8, 4274.84, 250.035 >, < -811.883, 4354.57, 354.399 > )

    array<Path> TrainPath
    Path path1

    path1.handler = TrainDriveForward
    path1.origin = < -600, 2500, 175 >
    path1.angles = <0,90,0>
    TrainPath.append( path1 )

    Path path2

    path2.handler = TrainDriveWithAngle
    path2.origin = < -790, 2200, 175>
    path2.angles = <0,180,0>
    TrainPath.append( path2 )

    Path path3

    path3.handler = TrainDriveForward
    path3.origin = < -790, 675, 175 >
    path3.angles = <0,180,0>
    TrainPath.append( path3 )

    Path path4

    path4.handler = TrainDriveWithAngle
    path4.origin = < -600, 580, 175 >
    path4.angles = <0,-90,0>
    TrainPath.append( path4 )

    Path path5

    path5.handler = TrainDriveForward
    path5.origin = < 510, 580, 175 >
    path5.angles = <0,-90,0>
    TrainPath.append( path5 )

    Path path6

    path6.handler = TrainDriveWithAngle
    path6.origin = < 640, 580, 175 >
    path6.angles = <0,0,0>
    TrainPath.append( path6 )

    Path path7

    path7.handler = TrainDriveForward
    path7.origin = < 640, 2200, 175 >
    path7.angles = <0,0,0>
    TrainPath.append( path7 )

    Path path8

    path8.handler = TrainDriveWithAngle
    path8.origin = <500, 2500, 175>
    path8.angles = <0,90,0>
    TrainPath.append( path8 )

    CreateTrainAtStation( <500, 2500, 175>, <0,90,0>, TrainPath )

    file.TrainSpeed = GetConVarInt( "train_speed" )

    thread RunRecordingLoop()
}

void function CreateSarahCoffeMaker( vector origin, vector angles )
{
    if ( GetDisabledElements().contains( "sarah" ) )
        return

    entity sarah = CreateEntity( "prop_dynamic" )
    sarah.SetValueForModelKey( Sarah )
	sarah.kv.fadedist = 1000
	sarah.kv.renderamt = 255
	sarah.kv.rendercolor = "81 130 151"
	sarah.kv.solid = SOLID_VPHYSICS

	SetTeam( sarah, TEAM_BOTH )
	sarah.SetOrigin( origin )
	sarah.SetAngles( angles )
    sarah.SetScriptName( "sarah_coffee" )
	DispatchSpawn( sarah )

    sarah.SetUsable()
    sarah.SetUsableByGroup( "pilot" )
    sarah.SetUsePrompts( "按 %use% 拿一杯激素咖啡", "按 %use% 拿一杯激素咖啡" )
	thread SarahThink( sarah )

    sarah.Anim_Play( "Sarah_menu_pose" )
}

void function SarahThink( entity sarah )
{
    while ( IsValid( sarah ) )
    {
        sarah.SetUsable()
        sarah.SetSkin( 0 )

        entity player = expect entity( sarah.WaitSignal( "OnPlayerUse" ).player )
        StimPlayer( player, 30 )

        sarah.UnsetUsable()
        sarah.SetSkin( 1 )
        wait 5
    }
}

void function CreateTrainAtStation( vector origin, vector angles, array<Path> TrainPath )
{
    if ( GetDisabledElements().contains( "train_angel" ) )
        return

    entity train = CreateExpensiveScriptMover()
    train.SetPusher( true )

    for( int x = 0; x <= 192; x += 64 )
    {
        for( int y = 0; y <= 384; y += 64 )
        {
            entity mover = CreateExpensiveScriptMoverModel( Pallet, <x,y,0>, <0,0,0>, SOLID_VPHYSICS, 5000 )
            mover.SetPusher( true )
            mover.SetParent( train )
        }
    }

    train.SetOrigin( origin )
    train.NonPhysicsRotateTo( angles, 0.000000001, 0, 0 )

    thread TrainPathThink( train, TrainPath )
    // thread TrainThink( train )
}

void function TrainThink( entity train )
{
    train.EndSignal( "OnDestroy" )

    for(;;)
    {
        vector low = <0,0,0>
        vector high = ( -train.GetForwardVector() * 192 ) + ( train.GetRightVector() * 384 ) + <0,0,50>

        foreach( entity player in GetPlayerArray() )
        {
            vector origin = player.GetOrigin() - train.GetOrigin()
            if ( origin > low && origin < high && player.IsCrouched() )
            {
                player.SetParent( train )
            }
            else if ( !player.IsCrouched() && player.GetParent() == train )
            {
                player.ClearParent()
            }

            WaitFrame()
        }
        WaitFrame()
    }
}

void function TrainPathThink( entity train, array<Path> TrainPath )
{
    train.EndSignal( "OnDestroy" )

    for(;;)
    {
        foreach( Path path in TrainPath )
        {
            waitthread path.handler( train, path.origin, path.angles )
        }
    }
}

float function CalculateTravelTime( vector start, vector end )
{
    return Distance2D( start, end ) / file.TrainSpeed
}

void function TrainDriveForward( entity train, vector origin, vector angles )
{
    float Ttime = 0.2
    Ttime = CalculateTravelTime( train.GetOrigin(), origin )

    if ( Ttime <= 0.201 )
        Ttime = 0.2

    train.NonPhysicsMoveTo( origin, Ttime, 0.1, 0.1 )
    wait Ttime + 0.3
}

void function TrainDriveWithAngle( entity train, vector origin, vector angles )
{
    float Ttime = 0.2
    Ttime = CalculateTravelTime( train.GetOrigin(), origin ) + 0.5

    if ( Ttime <= 0.201 )
        Ttime = 0.2

    train.NonPhysicsMoveTo( origin, Ttime, 0.1, 0.1 )
    train.NonPhysicsRotateTo( angles, Ttime, 0.1, 0.1 )
    wait Ttime + 0.3
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
        waitthread PlayRecoding_recording_angelCityPastPilot( pilot )
        wait RandomIntRange( 60, 180 )
    }
}
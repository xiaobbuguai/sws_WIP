global function placeColonyObjects
global function callback_dropShipButtonTriggered
global function CreateNessyMessager

struct
{
    entity nessy
}
file


void function placeColonyObjects()
{
    CreateSimpleButton( <0, 115, 60>, <0, 0, 0>, "召喚毒蛇", callback_ValidateVoperRequest, 120.0 )
    PrecacheModel( $"models/communication/terminal_com_station_tall.mdl" )

    if ( !GetDisabledElements().contains( "dropship_station" ) )
    {
        entity button = CreateSimpleButton( <405.671, 115.202, 1039.96> + <0,10,-4>, <0, 0, 30>, "生成核彈飛船", callback_dropShipButtonTriggered )
        CreateSimpleButton( <405.671, 115.202, 1039.96> + < 50,10,-4 >, <0, 0, 30>, "告訴你哪裏有尼斯湖小水怪", callback_NessyButtonTriggered )
        CreateNessyMessager( button.GetOrigin() + <0,30,0>, <0,180,0>, "The tower is on a cooldown. Try !dropship in the chat <3." )
    }
    CreateSimpleButton( <349,1598,132>, <0, 90, 30>, "獻祭一臺帝王獲得一顆電池", callback_tradeButtonTriggered, 10 )

    CreateNessy( < -930, -8577, 279 >, <0, 60, 0>, 9 )
    CreateSarahCoffeMaker( < -574, 2717, 158>, <0,0,0> )
    CreateAshPeaceKraberSeller( < -1308, 2883, 160>, <0,0,0> )

    entity pole = CreateEntity( "prop_dynamic_lightweight" )
	pole.SetValueForModelKey( $"models/communication/terminal_com_station_tall.mdl" )
	pole.kv.fadedist = 10000
	pole.kv.renderamt = 255
	pole.kv.rendercolor = "255 255 255"
    pole.kv.modelscale = 5
	pole.kv.solid = SOLID_VPHYSICS // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
    pole.SetOrigin( < -574, -8255, 321 > )
    pole.SetAngles( CONVOYDIR )
    DispatchSpawn( pole )

    thread InitColonyRoom()

    thread RunRecordingLoop()
}

void function callback_dropShipButtonTriggered( entity button, entity player )
{
    if ( GetEntArrayByScriptName( "drivable_dropship" ).len() > 10 )
		return

    if ( !GetConVarBool( "dropships_enabled" ) )
    {
        Chat_ServerPrivateMessage( player, "dropships are disabled by host", false )
		return
    }

    foreach ( entity ent in GetEntArrayByScriptName( "drivable_dropship" ) )
    {
        if ( Distance2D( ent.GetOrigin(), button.GetOrigin() ) < 1000 )
            return
    }

    #if DROPSHIP_MOD
        file.nessy.SetUsable()

        vector origin = button.GetOrigin()

        string ShipType = "dropship"
        if ( button.GetScriptName() == "gunship_spawner" )
            ShipType = "gunship"

        DropShiptruct dropship = SpawnDrivableDropShip( origin + <0,10000,10000>, <0,-90,0>, player.GetTeam(), ShipType )
        entity mover = dropship.dropship.mover

        mover.NonPhysicsMoveTo( origin + <0,500,0>, 6, 0.1, 1 )

        thread TurnOffNessyMessage()
    #else
        print("cat_or_not.DropshipDrivable isn't installed >:(")
    #endif
}

void function TurnOffNessyMessage()
{
    wait 30
    file.nessy.UnsetUsable()
}

void function CreateNessyMessager( vector origin, vector angles, string message )
{
    file.nessy = CreatePropDynamic( $"models/domestic/nessy_doll.mdl", origin, angles, SOLID_VPHYSICS )
    file.nessy.SetUsableByGroup( "pilot" )
    file.nessy.SetUsePrompts( message, message )
    file.nessy.UnsetUsable()
}

void function callback_NessyButtonTriggered( entity button, entity player )
{
    array<entity> Nessy = GetEntArrayByScriptName( "Nessy" )

    if ( Nessy.len() == 0 )
        return

    player.SetAngles( <0,-103,0> )

    Chat_ServerPrivateMessage( player, "那裏有一只尼斯湖小水怪玩偶（你可能需要開飛船過去）", false )
}

void function callback_tradeButtonTriggered( entity button, entity player )
{
    if ( !player.IsTitan() )
        return

    entity soul = player.GetTitanSoul()
    if ( !IsValid( soul ) )
        return

    if ( GetSoulPlayerSettings( soul ) != "titan_atlas_vanguard" )
        return

    entity t = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )

    TitanBecomesPilot( player, t )
    t.Destroy()

    entity battery = Rodeo_CreateBatteryPack()
    battery.SetOrigin( button.GetOrigin() + <0,0,50> )
    battery.SetVelocity( <0,0,-1> )
}

void function RunRecordingLoop()
{
    if ( GetDisabledElements().contains( "past_pilots" ) )
        return

    wait RandomIntRange( 5, 10 )
    for(;;)
    {
        entity pilot = CreateElitePilot( 1, <0,1000,10000>, <0,0,0> )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
		DispatchSpawn( pilot )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
        pilot.kv.skin = PILOT_SKIN_INDEX_GHOST
		pilot.Freeze()
        waitthread PlayRecoding_recording_colonyPastPilot( pilot )
        wait RandomIntRange( 120, 240 )
    }
}
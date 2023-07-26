global function StartVoperBattle
global function CoreFire
global function HandleCamera
global function ViperGetEnemy
global function GetVoper
global function GetVoperShip
global function RunJetSfx
global function AnimateViper
global function ViperBankMagnitude
global function InitEmptyShip
global entity viper


global function MissionEND

global int waves = 0
global int PassWaves

const vector Player_SpawnPoint_Voper = < -151, 1091, 1490 >

struct
{
    ShipStruct& viperShip
    entity viper
    entity ref
    bool fighting = false
    bool coring = false

    entity RespawnShip
} file
//生成泰坦种类
array<string> basic_titan = [
    "npc_titan_atlas_stickybomb_bounty",
    "npc_titan_ogre_meteor_bounty",
    "npc_titan_stryder_sniper_bounty",
    "npc_titan_stryder_leadwall_bounty",
    "npc_titan_atlas_tracker_bounty",
    "npc_titan_ogre_minigun_bounty",
    "npc_titan_atlas_vanguard_bounty"
    "npc_titan_stryder_rocketeer_dash_core"
    "npc_titan_ogre_minigun_boss_fd"
    "npc_titan_atlas_stickybomb_boss_fd"
    "npc_titan_vanguard"
]

void function StartVoperBattle( int varient )
{

    thread TEAM_Player()
    vector origin_ref = <3352, -4226, 3267>
    if ( varient == 0 )
        origin_ref = <985, 1138, 1604>
        switch(GetMapName()){
            case "mp_angel_city":
                origin_ref=< 0, 0, 0 >
            break;//天使城
            case "mp_black_water_canal":
                origin_ref=< 400, -1250, 600 >
            break;//黑水运河
            case "mp_colony02":
                origin_ref=< 800, 5115, 310 >
            break;//殖民地
            case "mp_drydock":
                origin_ref=< 3000, -3250, 800 >
            break;//船坞
            case "mp_eden":
                origin_ref=< 4600, 500, 500 >
            break;//伊甸园
            case "mp_thaw":
                origin_ref=< 2000, -1498, 0 >
            break;//系外行星
            case "mp_glitch":
                origin_ref=< 3350, 100, 550 >
            break;//异常
            case "mp_relic02":
                origin_ref=< 5635, -3527, 380 >
            break;//遗迹
            case "mp_wargames":
                origin_ref=< 2600, 1200, 300 >
            break;//战争游戏
            case "mp_homestead":
                origin_ref=< 5279, 1716, 600 >
            break;//家园
        }
    file.ref = CreateScriptMover( origin_ref, < 0, 90, 0 > )

    vector delta = <100,0,5000>
    LocalVec origin
	origin.v = file.ref.GetOrigin() + delta

    entity viper = CreateNPCTitan( "titan_stryder", 10, origin.v, <0,90,0>, [] )
    SetSpawnOption_AISettings( viper, "npc_titan_stryder_sniper_boss_fd" )
    DispatchSpawn( viper )

	viper.SetModel( $"models/titans/light/titan_light_raptor.mdl" )
	viper.SetSkin( 10 )
	viper.SetInvulnerable()
    viper.SetMaxHealth( 524286 )
    viper.SetHealth( 524286 )
	viper.SetNoTarget( true )
	viper.SetNoTargetSmartAmmo( false )
    viper.kv.AccuracyMultiplier = 50.0
    viper.kv.WeaponProficiency = 50.0
    viper.SetTitle( "viper" )
    NPC_SetNuclearPayload( viper )
    ShowName( viper )
    viper.Anim_Play( "s2s_viper_flight_move_idle" )

    GiveViperLoadout( viper )

	entity mover = CreateScriptMover( <0,0,0>, <0,180,0> )
	entity link = CreateExpensiveScriptMover( <0,0,0>, <0,180,0> )
	SetOriginLocal( mover, origin )
	link.SetParent( mover, "", false, 0 )
	viper.SetParent( link, "", false, 0 )
    link.NonPhysicsRotateTo( <0,180,0>, 0.0000001,0,0 )

	ShipStruct viperShip
	viperShip.model = viper
	viperShip.mover = mover
	viperShip.boundsMinRatio 	= 0.5
	viperShip.defBankTime		= 0.5	//1.5
	viperShip.defAccMax 		= 500	//350
	viperShip.defSpeedMax 		= 1000	//500
	viperShip.defRollMax 		= 15
	viperShip.defPitchMax 		= 3
	viperShip.FuncGetBankMagnitude = ViperBankMagnitude

	InitEmptyShip( viperShip )

	// int backID = viper.LookupPoseParameterIndex( "move_yaw_backward" )
    int backID = viper.LookupPoseParameterIndex( "move_yaw" )
	viper.SetPoseParameterOverTime( backID, 45, 0.1 )

	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_BOT_THRUST" ) )
    StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_BOT_THRUST" ) )
    StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_TOP_THRUST" ) )
    StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_TOP_THRUST" ) )

	file.viperShip = viperShip
	file.viper = viper

	file.viperShip.localVelocity.v = <0,500,0>
	SetMaxSpeed( file.viperShip, 700 )
	SetMaxAcc( file.viperShip, 300 )

	thread ShipIdleAtTargetPos( file.viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < 500, 0, 500 > ) , <0,100,500> )
    viperShip.goalRadius = 500
    file.viperShip.mover.NonPhysicsRotateTo( <0,180,0>, 0.0000001,0,0 )

    if ( varient == 0 )
    {
        file.RespawnShip = CreateExpensiveScriptMoverModel( $"models/vehicle/goblin_dropship/goblin_dropship.mdl", Player_SpawnPoint_Voper + <0,0,1500>, <0,90,0>, 6, 100000 )
        file.RespawnShip.Anim_Play( "dropship_open_doorR_idle" )
        file.RespawnShip.Anim_Play( "dropship_open_doorL_idle" )
    }

    file.fighting = true

    thread StartIntro( file.viperShip, varient )
    thread RunJetSfx( viper )

    if ( varient == 0 )
        thread correctViper()
}

string IMC_Player_Name = ""
int IMC_Player_i = 0
void function TEAM_Player(){//将玩家全部切换至反抗军
    while(true){
        foreach(entity player in GetPlayerArray()){
            if(player.GetPlayerName()!=IMC_Player_Name && player.GetTeam()!=TEAM_MILITIA){
                SetTeam(player,TEAM_MILITIA)
            }
        }
        wait 1
        //TitanWeapon_ViperMod()
    }

}

void function RunJetSfx( entity viper )
{
    EndSignal( viper, "OnDeath" )
    EndSignal( viper, "OnDestroy" )

    for(;;)
    {
        StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_BOT_THRUST" ) )
        StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_BOT_THRUST" ) )
        StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_TOP_THRUST" ) )
        StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_TOP_THRUST" ) )

        wait 60
    }
}

void function StartIntro( ShipStruct viperShip, int varient )
{
    WaitSignal( viperShip, "Goal" )
    entity viper = viperShip.model


    EmitSoundOnEntity( viper, "music_s2s_14_titancombat" )
	EmitSoundOnEntity( viper, "diag_sp_bossFight_STS673_01_01_mcor_viper" )
    foreach( entity player in GetPlayerArray() )
    {
        thread HandleCamera( player, file.ref )
    }


    WaitSignal( file.ref, "CameraHandleOver" )
    viper.Signal( "CameraHandleOver" )

    thread CoreFire()

    thread ShipIdleAtTargetPos( viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < -500, 0, 200 > ) , <100,500,0> )
    entity link = viper.GetParent()
    link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )

    thread AnimateViper( viper )

    if ( varient == 0 )
    {
        thread Phase1Think()
        //thread PhaseBackThink()
    }
}

void function HandleCamera( entity player, entity ref )
{
    if ( !IsValid( player ) || !IsAlive( player ) )
        return

    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )
    ref.EndSignal( "CameraHandleOver" )

    entity mover
    entity camera

    OnThreadEnd(
		function() : ( player, camera, mover )
		{
            if ( IsValid( player ) )
            {
                //ViewConeFree( player )
                //player.ClearParent()
                //RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
                //DeployAndEnableWeapons( player )
                //player.ClearInvulnerable()
                //player.AnimViewEntity_SetLerpOutTime( 1 )
                //player.AnimViewEntity_Clear()
//
                // if ( IsValid( camera ) )
                //     EntFireByHandle( camera, "Disable", "!activator", 0, player, null )
                //player.Die()
                //thread DelayedRespawnPlayer( player )


            }

			if ( IsValid( camera ) )
                camera.Destroy()
            if ( IsValid( mover ) )
                mover.Destroy()
		}
	)

    //player.SetInvulnerable()
//
    vector angles = <0,0,0>
//
    //camera = CreateEntity( "point_viewcontrol" )
    //camera.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid
    //camera.SetOrigin( player.GetOrigin() )
    //camera.SetAngles( angles )
    //DispatchSpawn( camera )
//
    //player.SetViewEntity( camera, true )
    //// EntFireByHandle( camera, "Enable", "!activator", 0, player, null )
    mover = CreateExpensiveScriptMover( player.GetOrigin(), angles )
    //camera.SetParent( mover )
//
    //player.SetAngles( angles )
    //HolsterAndDisableWeapons( player )
    //AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )
    //player.PlayerCone_SetLerpTime( 0.5 )
    //player.PlayerCone_FromAnim()
    //player.PlayerCone_SetMinYaw( 0 )
    //player.PlayerCone_SetMaxYaw( 0 )
    //player.PlayerCone_SetMinPitch( 0 )
    //player.PlayerCone_SetMaxPitch( 0 )

    mover.NonPhysicsMoveTo( ref.GetOrigin() + < -500,0,100 >, 1, 0.1, 0.1 )

    wait 2

    ref.Signal( "CameraHandleOver" )
}

void function DelayedRespawnPlayer( entity player )
{
    player.EndSignal( "OnDestroy" )

    WaitFrame()

    DoRespawnPlayer( player, null )
}

void function Phase1Think()
{
    // SmokescreenStruct smoke
    // smoke.smokescreenFX = $"P_smokescreen_FD"
    // smoke.fxXYRadius = 3000
    // smoke.fxZRadius = 800
    // smoke.origin = <366, -140, 0>
    // smoke.angles = <0,0,0>
    // smoke.lifetime = 300000000.0
    // smoke.isElectric = false

    // vector origin = <600, 0, 1380>
    // for( float y = 0; y < 2001; y+= 100 )
    //     smoke.fxOffsets.append( origin - <0,y,0> )

    // Smokescreen( smoke )

    float activatorTime = Time()

    entity npc
    int team = file.viperShip.model.GetTeam()
    //vector origin = GetClosest2D( SpawnPoints_GetDropPod(), <1200, 1145, 1380>, 1000000000 ).GetOrigin()

    int count = GetPlayerArray().len()
    if ( count > 10 )
        count = 10

    foreach( string NpcName in ["npc_super_spectre"] )
    {
        for( int x = 0; x < count; x++ )
        {
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPC( NpcName, team, LuckyPlayer, <0,0,0>);
            SetSpawnOption_AISettings( npc, NpcName)
            DispatchSpawn( npc )
            thread SonarTitan(npc, 3000)
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            npc.SetScriptName( "phase1_ents" )

            wait 0.00000000001
        }

        wait 0.1
    }

    for(;;)
    {
        if ( GetEntArrayByScriptName( "phase1_ents" ).len() == 0 )
            break

        if ( activatorTime + 120 <= Time() )
        {
            foreach( npc in GetEntArrayByScriptName( "phase1_ents" ) )
            {
                if ( IsValid( npc ) )
                    npc.Die()
            }
            break
        }

        wait 1
    }

    thread Phase2Think()
    thread RocketFireThink()
}

void function Phase2Think()
{
    foreach( entity player in GetPlayerArray() )
		EmitSoundOnEntity( player, "diag_sp_viperchat_STS666_01_01_mcor_viper" )

    float activatorTime = Time()

    entity npc
    int team = file.viperShip.model.GetTeam()

    int count = GetPlayerArray().len()

    if ( count >= 7 )
        count = 7

    foreach( entity player in GetPlayerArray() )
    {
        if ( !player.IsTitan() && IsValid( player ) && IsAlive( player ) )
        {
            player.p.earnMeterOverdriveFrac = 1.0
            player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
            PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
            PlayerEarnMeter_SetRewardFrac( player, 1.0 )
            wait 0.1
        }
    }

    for( int x = 0; x < count; x++ )
    {
        vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
        npc = CreateNPCTitan( "npc_titan_ogre", team, LuckyPlayer, <0,0,0>, [] )
        SetSpawnOption_NPCTitan( npc, TITAN_HENCH )
        SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor" )
        SetSpawnOption_Titanfall( npc )
        DispatchSpawn( npc )

        npc.AssaultPoint( Player_SpawnPoint_Voper )
        npc.AssaultSetFightRadius( 1000 )
        npc.AssaultSetGoalRadius( 1000 )
        npc.SetScriptName( "phase2_ents" )


        wait 0.00000000001
    }

    for(;;)
    {
        if ( GetEntArrayByScriptName( "phase2_ents" ).len() == 0 )
            break

        if ( activatorTime + 120 <= Time() )
        {
            foreach( npc in GetEntArrayByScriptName( "phase2_ents" ) )
            {
                if ( IsValid( npc ) )
                    npc.Die()
            }
            break
        }

        wait 1
    }

    thread Phase3Think()

}

void function Phase3Think()
{
    file.viperShip.model.ClearInvulnerable()
    thread ShipIdleAtTargetPos( file.viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < 500, 0, 200 > ) , <500,1000,0> )
    entity link = file.viperShip.model.GetParent()
    link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
    int waves = 0
    thread UnlimitedSpawn()
    file.viperShip.model.SetHealth(500000)

    foreach( entity player in GetPlayerArray() )
    {
        if ( ( !player.IsTitan() && IsValid( player ) && IsAlive( player ) ) )
        {
            player.p.earnMeterOverdriveFrac = 1.0
            player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
            PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
            PlayerEarnMeter_SetRewardFrac( player, 1.0 )
            wait 0.1
        }
    }

    entity soul = file.viperShip.model.GetTitanSoul()

    while( IsValid( file.viperShip.model ) )
    {
        if ( IsValid( soul ) && soul.IsDoomed() )
            thread SetBehavior( file.viperShip, eBehavior.DEATH_ANIM )

        WaitFrame()
    }

    AddTeamScore( TEAM_MILITIA, 10000 )
    AddTeamScore( TEAM_IMC, 10000 )
}

void function UnlimitedSpawn()
{
    entity npc
    entity npcs
    int team = file.viperShip.model.GetTeam()
    int PassWaves = 0
    //int count = GetPlayerArray().len() + 1
    int MissionStart = 0
    //if ( count >= 7 ){
    int count = 5
        //wait 0.1
    //}
    for (; ;) {
    //int ViperMinHp = 520000 - 10000
    entity viper = file.viperShip.model



//非“家园”部分
if (IsValid( viper ) && IsAlive( viper )){

    if ( waves > 9 ){
    waves = 0
    }

    else if ( viper.GetHealth() < 5000){
        thread SetBehavior( file.viperShip, eBehavior.DEATH_ANIM )
        viper.SetInvulnerable()
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_42_01_imc_viper" )
        wait 5
        AddTeamScore( TEAM_MILITIA, 114514 )
        AddTeamScore( TEAM_IMC, 111111 )
        viper.Die()
        break
    }

    else if ( PassWaves == 0 && GetMapName() != "mp_homestead"){//
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_22_01_imc_viper" )
        viper.SetInvulnerable()
        //viper.SetHealth(viper.GetHealth() - 15000)
        //vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
        SpawnEnemies( viper.GetOrigin(), 4, team, file.viperShip.model )
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPCTitan( basic_titan[waves], team, LuckyPlayer, <0,0,0>, [] )
            SetSpawnOption_NPCTitan( npc, TITAN_HENCH )
            SetSpawnOption_AISettings( npc, basic_titan[waves] )
            SetSpawnOption_Titanfall( npc )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            npc.SetScriptName( "phase3_ents" )
            wait 1
        }
        wait 5
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPC( "npc_pilot_elite", team, LuckyPlayer, <0,0,0> )
            SetSpawnOption_AISettings( npc, "npc_pilot_elite" )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            //npc.SetScriptName( "phase3_ents" )
            npc.TakeWeaponNow("mp_weapon_r97")
            npc.GiveWeapon( "mp_weapon_alternator_smg", ["super"] )
            wait 0.1
            thread SuperSpectre_WarpFall( npc )
            wait 0.5
            }
        for (; ;) {
            if ( GetEntArrayByScriptName( "phase3_ents" ).len() == 0){
                waves++
                PassWaves++
                break
                }
            wait 0.1
        }
    }

    else if  ( PassWaves == 1 && GetMapName() != "mp_homestead"){
        PassWaves++
        int ViperMinHp = viper.GetHealth() - 25000
        viper.ClearInvulnerable()
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_36_01_imc_viper" )
        viper.ClearInvulnerable()
        for (; ;) {
            if ( viper.GetHealth() < ViperMinHp){
                PassWaves = 0
                break
                }
            wait 0.1
        //wait 20
        ////int ViperMinHealth = (viper.GetHealth() - 25000)
        ////PassWaves = 2
        ////for (; ;) {
        ////if (viper.GetHealth() == ViperMinHealth){
        //PassWaves = 0
        ////break
        ////}
        ////wait 0.1
        ////}
        }
    }
//“家园”部分（加入护送莎拉布里格斯）
    else if ( PassWaves == 0 && GetMapName() == "mp_homestead" && viper.GetHealth() > 150000 ){//
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_22_01_imc_viper" )
        foreach( entity player in GetPlayerArray() )
        Chat_ServerPrivateMessage(player, string(viper.GetHealth()), false)
        viper.SetInvulnerable()
        //viper.SetHealth(viper.GetHealth() - 15000)
        //vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
        SpawnEnemies( viper.GetOrigin(), 4, team, file.viperShip.model )
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPCTitan( basic_titan[waves], team, LuckyPlayer, <0,0,0>, [] )
            SetSpawnOption_NPCTitan( npc, TITAN_HENCH )
            SetSpawnOption_AISettings( npc, basic_titan[waves] )
            SetSpawnOption_Titanfall( npc )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            npc.SetScriptName( "phase3_ents" )
            wait 1
        }
        wait 5
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPC( "npc_pilot_elite", team, LuckyPlayer, <0,0,0> )
            SetSpawnOption_AISettings( npc, "npc_pilot_elite" )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            //npc.SetScriptName( "phase3_ents" )
            npc.TakeWeaponNow("mp_weapon_r97")
            npc.GiveWeapon( "mp_weapon_alternator_smg", ["super"] )
            wait 0.1
            thread SuperSpectre_WarpFall( npc )
            wait 0.5
            }
        for (; ;) {
            if ( GetEntArrayByScriptName( "phase3_ents" ).len() == 0){
                waves++
                PassWaves++
                break
                }
            else if (viper.GetHealth() < 25000){
                break
            }
            wait 0.1
        }
    }
    else if  ( GetMapName() == "mp_homestead" && viper.GetHealth()>100001 && viper.GetHealth()<150000 && MissionStart == 0){
        MissionStart++
        PassWaves = 2
        viper.SetInvulnerable()
        thread SarahDefenseThink( TEAM_MILITIA )
    }

    else if ( GetMapName() == "mp_homestead" && PassWaves == 0 && viper.GetHealth() < 100000){//
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_22_01_imc_viper" )
        viper.SetInvulnerable()
        //viper.SetHealth(viper.GetHealth() - 15000)
        //vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
        SpawnEnemies( viper.GetOrigin(), 4, team, file.viperShip.model )
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPCTitan( basic_titan[waves], team, LuckyPlayer, <0,0,0>, [] )
            SetSpawnOption_NPCTitan( npc, TITAN_HENCH )
            SetSpawnOption_AISettings( npc, basic_titan[waves] )
            SetSpawnOption_Titanfall( npc )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            npc.SetScriptName( "phase3_ents" )
            wait 1
        }
        wait 5
        for( int x = 0; x < count; x++ ){
            vector LuckyPlayer = GetPlayerArray()[(GetPlayerArray().len() == 1) ? 0 : RandomInt(GetPlayerArray().len()-1)].GetOrigin()
            npc = CreateNPC( "npc_pilot_elite", team, LuckyPlayer, <0,0,0> )
            SetSpawnOption_AISettings( npc, "npc_pilot_elite" )
            DispatchSpawn( npc )
            npc.AssaultPoint( Player_SpawnPoint_Voper )
            npc.AssaultSetFightRadius( 10000 )
            npc.AssaultSetGoalRadius( 1000 )
            //npc.SetScriptName( "phase3_ents" )
            npc.TakeWeaponNow("mp_weapon_r97")
            npc.GiveWeapon( "mp_weapon_alternator_smg", ["super"] )
            wait 0.5
            thread SuperSpectre_WarpFall( npc )
            wait 0.5
            }
        for (; ;) {
            if ( GetEntArrayByScriptName( "phase3_ents" ).len() == 0){
                waves++
                PassWaves++
                break
                }
            wait 0.1
        }
    }

    else if  ( PassWaves == 1 && GetMapName() == "mp_homestead" && viper.GetHealth() > 150000){
        PassWaves++
        int ViperMinHp = viper.GetHealth() - 25000
        viper.ClearInvulnerable()
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_36_01_imc_viper" )
        viper.ClearInvulnerable()
        for (; ;) {
            if ( viper.GetHealth() < ViperMinHp){
                PassWaves = 0
                break
            }
            else if (viper.GetHealth() < 150000){
                    break
            }
            else if ( ViperMinHp < 150000){
                break
        }
            wait 0.1
        }
    }

    else if  ( PassWaves == 1 && GetMapName() == "mp_homestead" && viper.GetHealth() < 200001){
        PassWaves++
        int ViperMinHp = viper.GetHealth() - 25000
        viper.ClearInvulnerable()
        EmitSoundOnEntity( viper, "diag_sp_bossFight_STS676_36_01_imc_viper" )
        viper.ClearInvulnerable()
        for (; ;) {
            if ( viper.GetHealth() < ViperMinHp){
                PassWaves = 0
                break
                }
            wait 0.1
        }
    }

    count = GetPlayerArray().len() + 1
    if ( count >= 7 ){
    int count = 7
        wait 0.1
    }
    wait 0.1
}
}
}
void function PhaseBackThink()
{
    while( IsValid( file.viperShip.model ) && file.fighting )
    {
        foreach( entity player in GetPlayerArray() )
        {
            vector origin = player.GetOrigin()
            if ( origin.x > file.ref.GetOrigin().x + 700 )
                thread PhaseBack( player )
        }
        wait 10
    }
}

void function PhaseBack( entity player )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "OnDeath" )

    entity mover
    vector origin = Player_SpawnPoint_Voper + <0,0,500>

    OnThreadEnd(
		function() : ( mover )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

    if ( IsValid( player ) && IsAlive( player ) && IsValid( file.RespawnShip ) && !player.IsTitan() )
        origin = file.RespawnShip.GetOrigin() + <0,0,10>

    if ( player.GetTeam() == TEAM_IMC )
        origin += <0,50,0>
    else
        origin -= <0,50,0>

    if ( IsValid( player ) && IsAlive( player ) && !IsPlayerDisembarking( player ) && !IsPlayerEmbarking( player ) )
    {

        mover = CreateOwnedScriptMover( player )
        player.SetParent( mover )
        mover.NonPhysicsMoveTo( origin, 0.5, 0, 0 )
        vector angles = player.GetAngles()
        PhaseShift( player, 0.1, 1 )
        player.SetAngles( angles )
    }

    wait 0.6
    if ( IsValid( player ) )
    {
        player.ClearParent()
        player.SetInvulnerable()
        player.SetVelocity( < -400,0,0 > )
    }

    if ( IsValid( mover ) )
        mover.Destroy()

    wait 0.5

    if ( IsValid( player ) )
    {
        player.ClearInvulnerable()
    }
}

void function AnimateViper( entity viper )
{
    viper.EndSignal("OnDeath")
    viper.EndSignal("OnDestroy")

    for(;;)
    {
        WaitFrame()

        if ( file.coring )
            continue

        viper.Anim_Play( "s2s_viper_flight_move_idle" )

        WaitFrame()
    }
}

void function RocketFireThink()
{
    while( IsValid( file.viperShip.model ) && file.fighting )
    {
        if ( RandomIntRange( 0, 15 ) == 1 )
            waitthread CoreFire()
        wait 1
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    viper logic                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void function GiveViperLoadout( entity viper )
{
    TakeAllWeapons( viper )

	viper.GiveWeapon( "mp_titanweapon_sniper", [] )
    viper.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets",0, [ "burn_mod_titan_dumbfire_rockets", "fd_twin_cluster" ] )
    viper.GiveOffhandWeapon( "mp_titanability_tether_trap",2, [ "fd_explosive_trap" ] )

        viper.Anim_Play( "s2s_viper_flight_move_idle" )
}
void function GiveViperLoadoutRockets( entity viper )
{
    TakeAllWeapons( viper )

    viper.GiveWeapon( "mp_titanweapon_flightcore_rockets", [] ) // "DarkMissiles"
    viper.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets",0, [ "burn_mod_titan_dumbfire_rockets", "fd_twin_cluster" ] )
    viper.GiveOffhandWeapon( "mp_titanability_tether_trap",2, [ "fd_explosive_trap" ] )
}

void function CoreFire()
{
    GiveViperLoadoutRockets( file.viper )

    entity target = ViperGetEnemy( file.viper )
    WeaponViperAttackParams	viperParams = ViperSwarmRockets_SetupAttackParams( target.GetOrigin() - <0,0,200>, file.ref )
    // viperParams.target = target

    file.viperShip.mover.NonPhysicsMoveTo( file.viper.GetOrigin(), 1,0,0 )

    foreach( entity player in GetPlayerArray() )
        EmitSoundOnEntityOnlyToPlayer( player, player, "northstar_rocket_warning" )

    file.viper.Anim_Play( "s2s_viper_flight_core_idle" )

    for( int x = 0; x < 20; x++ )
    {
        OnWeaponScriptPrimaryAttack_ViperSwarmRockets_s2s( file.viper.GetActiveWeapon(), viperParams )
        file.viper.Anim_Play( "s2s_viper_flight_core_idle" )
        wait 0.01
    }

    wait 1

    GiveViperLoadout( file.viper )
}

void function correctViper()
{
    entity viper = file.viperShip.model

    while( IsValid( viper ) )
    {
        if ( viper.IsOnGround() )
        {
            viper.SetOrigin( viper.GetParent().GetOrigin() )
            entity link = file.viperShip.model.GetParent()
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )

            thread ShipIdleAtTargetPos(  file.viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < 0, 0, 500 > ) , <100,500,0> )
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
        }

        if ( viper.GetAngles().y >= 270 || viper.GetAngles().y <= 90 )
        {
            if ( IsValid(file.viperShip.model)){
            entity link = file.viperShip.model.GetParent()
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
            }
        }
        wait 1
    }
}

void function MissionEND()
{
    file.viperShip.model.SetHealth( 200000 )
    //PassWaves = 0
    file.viperShip.model.ClearInvulnerable()
}

entity function GetVoper()
{
    return file.viperShip.model
}

ShipStruct function GetVoperShip()
{
    return file.viperShip
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    viper logic from s2s                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

entity function ViperGetEnemy( entity viper )
{
    if ( GetPlayerArray().len() == 0 )
        return file.ref

    entity target = GetClosest2D( GetPlayerArray(), viper.GetOrigin(), 1000000000 )

    if ( !IsValid( target ) || !IsAlive( target ) )
        return file.ref

    return target
}


float function ViperBankMagnitude( float dist )
{
	return GraphCapped( dist, 0, 500, 0.0, 1.0 )
}

void function InitEmptyShip( ShipStruct ship )
{
	ship.free 	= false
	ship.localVelocity.v 	= <0,0,0>
	ship.goalRadius 		= SHIPGOALRADIUS

	ship.defaultBehaviorFunc 	= DefaultBehavior_Viper
	ship.defaultEventFunc 		= DefaultEventCallbacks_Viper

	ResetAllEventCallbacksToDefault( ship )
	ResetAllBehaviorsToDefault( ship )
	ResetMaxSpeed( ship )
	ResetMaxAcc( ship )
	ResetMaxRoll( ship )
	ResetMaxPitch( ship )
	ResetBankTime( ship )
	ship.behavior 		= eBehavior.IDLE
	ship.prevBehavior 	= [ eBehavior.IDLE ]

	thread RunBehaviorFiniteStateMachine( ship )
}

void function DefaultBehavior_Viper( ShipStruct ship, int behavior )
{
	switch ( behavior )
	{
		case eBehavior.ENEMY_CHASE:
			AddShipBehavior( ship, behavior, Behavior_ViperChaseEnemy )
			break

		case eBehavior.DEPLOY:
			AddShipBehavior( ship, behavior, Behavior_ViperChaseEnemy )
			break

		case eBehavior.DEATH_ANIM:
			AddShipBehavior( ship, behavior, Behavior_ViperDeathAnim )
	}
}

void function Behavior_ViperChaseEnemy( ShipStruct ship )
{
	entity enemy 	= ship.chaseEnemy
	int behavior 	= ship.behavior
	vector bounds 	= ship.flyBounds[ behavior ]
	vector offset 	= ship.flyOffset[ behavior ]
	float seekAhead = ship.seekAhead[ behavior ]
	__ShipFlyAlongEdge( ship, bounds, offset, seekAhead, eShipEvents.SHIP_ATNEWEDGE )
}

void function Behavior_ViperDeathAnim( ShipStruct ship )
{
	thread Behavior_ViperDeathAnimThread( ship )
}

void function Behavior_ViperDeathAnimThread( ShipStruct ship )
{
    file.fighting = false

    foreach( entity player in GetPlayerArray() )
		EmitSoundOnEntity( player, "diag_sp_gibraltar_STS102_13_01_imc_grunt1" )

	Signal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )

    ship.model.SetInvulnerable()

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )

	// entity ref = file.viper.GetParent()
	// float blendTime = 1.0

	// float dec = -ship.accMax
	// LocalVec trajectory = GetCurrentTrajectoryAtFullDeceleration( ship.mover, dec )

	// vector delta = GetRelativeDelta( LocalToWorldOrigin( trajectory ), file.ref )
	// vector pos = < 0, delta.y, 10000 >
	// vector offset = < 1500, delta.y + 700, 1300 >

	int attachID = ship.model.LookupAttachment( "CHESTFOCUS" )
	int fxID = GetParticleSystemIndex( $"P_s2s_viper_death_fire" )
	int fxID2 = GetParticleSystemIndex( $"xo_exp_death_s2s" )
	StartParticleEffectOnEntity( ship.model, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	StartParticleEffectOnEntity( ship.model, fxID2, FX_PATTACH_POINT, attachID )

    SetMaxSpeed( ship, 1400 )
	SetMaxAcc( ship, 700 )

	thread ShipIdleAtTargetPos( ship, WorldToLocalOrigin( file.ref.GetOrigin() + < 500, 0, 10000 > ) , <100,500,0> )
	// ship.goalRadius = SHIPGOALRADIUS

	// string deathAnim = "s2s_viper_flight_death_screen_L"
	// vector vel = GetVelocityLocal( mover ).v
	// if ( vel.x > 0 )
	// 	deathAnim = "s2s_viper_flight_death_screen_R"

	// file.viper.Anim_Play( deathAnim )
	// file.viper.SetEfficientMode( true )
	// file.viper.EnableNPCFlag( NPC_IGNORE_ALL )
	// waitthread PlayAnim( file.viper, deathAnim )

	// float duration = file.viper.GetSequenceDuration( deathAnim )
    float duration = 10.0
	wait duration

    if(IsAlive(file.viper)){
	file.viper.Die()
    }
	mover.Destroy()

    foreach( entity player in GetPlayerArray() )
		EmitSoundOnEntity( player, "diag_sp_maltaDeck_STS374_01_01_mcor_bt" )
}

void function SonarTitan(entity player, int duration)
{
#if SERVER
    float dur = duration.tofloat()
	StatusEffect_AddTimed( player, eStatusEffect.sonar_detected, 1.0, dur, 0.0 )
    Highlight_SetEnemyHighlight( player, "enemy_sonar" )
    wait duration
    if (Hightlight_HasEnemyHighlight(player, "enemy_sonar"))
        Highlight_ClearEnemyHighlight( player )
#endif
}

void function DefaultEventCallbacks_Viper( ShipStruct ship, int val )
{

}
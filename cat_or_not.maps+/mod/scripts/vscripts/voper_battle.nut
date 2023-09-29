untyped // for we using entity.s
global function VoperBattle_Init

global function StartVoperBattle
global function CoreFire
global function ViperGetEnemy
global function GetVoper
global function GetVoperShip
global function RunJetSfx
global function AnimateViper
global function ViperBankMagnitude
global function InitEmptyShip
global entity viper

global function PlayerBecomesBetrayer

global function MissionEND

global int waves = 0
global int PassWaves

const vector Player_SpawnPoint_Voper = < -151, 1091, 1490 >

// voper
const int VOPER_TEAM = TEAM_IMC
// voper settings
const int VOPER_MAX_HEALTH = 90000 // 90000 health with 0.8 damage reduction ~= 450000 health
const float VOPER_DAMAGE_SCALE = 2.5 // voper deals 2.5x damage to players
const float VOPER_DAMAGE_REDUCTION_SCALE = 0.8
// voper health settings
const float VOPER_MIN_HEALTH_FRAC = 0.03 // viper will keep 3% of health before getting killed
const float SARAH_QUEST_VOPER_HEALTH_FRAC = 0.3 // in homestead, game will start SarahDefenseThink() if viper reaches this percentage of health or lower
const float ASH_ASSIST_HEALTH_FRAC = 0.5 // lower than this amount of health will call-in a ash to help
// voper core settings
const float VOPER_CORE_MIN_COOLDOWN = 10.0 // voper will have minium of this cooldown for their core ability
const float VOPER_CORE_MAX_COOLDOWN = 30.0 // voper will have maxnium of this cooldown for their core ability
const int VOPER_CORE_MAX_BURSTS = 32 // how many rockets voper will fire during one core activation
const float VOPER_CORE_BURST_INTERVAL = 0.1 // interval between each rocket launch( script tickrate is 10 by default )
const float VOPER_CORE_ROCKET_SPEED_SCALE = 1.5 // launch speed scale for core rocket. the higher, the rocket can be more accurate at long range
const float VOPER_CORE_ROCKET_HOMING_SPEED_SCALE = 2.0 // homing speed scale for core rocket. the higher, the rocket can be more accurate at close range

// ash assist
const int ASH_MAX_HEALTH = 90000 // 90000 health with 0.5 damage reduction ~= 180000 health
const float ASH_DAMAGE_SCALE = 2.0
const float ASH_DAMAGE_REDUCTION_SCALE = 0.5
const float ASH_CORE_METER_MULTIPLIER = 6.0 // ash's core multiplier

// npc health settings
const float INFANTRY_HEALTH_SCALE = 2.0
const float TITAN_HEALTH_SCALE = 1.5
const float REAPER_HEALTH_SCALE = 2.0
// npc damage
const float NPC_TITAN_CORE_METER_MULTIPLIER = 2.5 // npc titan's core multiplier
const float NPC_TITAN_EJECTING_DELAY = 3.0 // npc pilot ejecting delay after doom

// wave point settings
const int WAVE_POINTS_PER_INFANTRY = 1 // an infantry unit worth 1 wave point
const int WAVE_POINTS_PER_TITAN = 10 // a titan unit worth 10 wave point
const int WAVE_POINTS_PER_REAPER = 5 // a reaper unit woth 5 wave points

// wave settings
const float PHASE_TRANSITION_DELAY = 5.0
const bool WAVE_CLEANUP_ON_END = true // clean up all spawned npcs on wave end
// 1st wave( phase1 )
const int FIRST_WAVE_REAPERS_COUNT = 10
const float FIRST_WAVE_TIMEOUT = -1 // -1 means infinite timeout
// 2nd wave( phase2 )
const int SECOND_WAVE_TITANS_COUNT = 7
const float SECOND_WAVE_TIMEOUT = -1 // -1 means infinite timeout
// unlimited spawn wave( phase3 )
const int UNLIMITED_SPAWN_SQUADS_COUNT = 5
const int UNLIMITED_SPAWN_REAPERS_COUNT = 4
const int UNLIMITED_SPAWN_TITANS_COUNT = 3
const float UNLIMITED_SPAWN_TIMEOUT = -1 // -1 means infinite timeout

// notification settings
// WIP
//const int WAVE_PROGRESS_HUD_ENABLED = true // may cause unexpected crash and client-side stuck. don't know why, better rework sh_message_utils.gnut?

// betrayer settings
enum ePlayerBetrayType
{
    BETRAY_FULL_MATCH,
    BETRAY_ONE_LIFE,
}

const table<string, int> MAP_BETRAYER_TYPE =
{
    ["mp_homestead"]            = ePlayerBetrayType.BETRAY_ONE_LIFE,

    ["mp_colony02"]             = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_forwardbase_kodai"]    = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_black_water_canal"]    = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_drydock"]              = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_eden"]                 = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_thaw"]                 = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_glitch"]               = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_relic02"]              = ePlayerBetrayType.BETRAY_ONE_LIFE,
    ["mp_wargames"]             = ePlayerBetrayType.BETRAY_ONE_LIFE,
}

// by default they'll use file.ref position
const table<string, vector> MAP_ASH_SPAWNPOINTS =
{
    ["mp_drydock"]              = < 1070, 3465, 400 >
}
 
const array<string> BETRAYER_TITAN_LIMITED =
[
    "ion",
    "tone",
    "northstar",
    "ronin",
    "legion",
    "scorch",
]

const bool END_WAVE_ON_BETRAYER_WIPE = true // end curret wave if betrayers are wiped
const int BETRAY_MIN_REQUIRED_PLAYERS = 4 // you need at least this amount of players to start betray
const float BETRAY_PLAYER_PERCENTAGE = 0.2 // this percentage of total player will betray their teammates, gain dash recharge boost, instant core recharge and higher health

// full-match betrayer
const float BETRAYED_PLAYER_RESPAWN_DELAY = 20.0

const float BETRAYED_PLAYER_HEALTH_SCALE = 2.0 // betrayed player's health scale
const float BETRAYED_PLAYER_DAMAGE_REDUCTION_SCALE = 0.5 // 0.5x damage reduction prettymuch means 2x health
const int BETRAYED_PLAYER_DOOMED_HEALTH = 8000 // betrayed player's doomed health value
const float BETRAYED_PLAYER_SHIELD_SCALE = 2.0 // betrayed player's shield scale
const float BETRAYED_PLAYER_SHIELD_REGEN_TIME = 3.0 // time required to regen shield to full
const float BETRAYED_PLAYER_SHIELD_REGEN_DELAY = 3.0 // how long the betaryed player can start regen shield
const float BETRAYED_PLAYER_CORE_MULTIPLIER = 10.0 // beteryed player's core meter multiplier

// debug
const bool VOPER_BATTLE_DEBUG = false

struct
{
    ShipStruct& viperShip
    entity viper
    entity ref
    bool fighting = false
    bool coring = false

    entity RespawnShip

    vector origin_ref
    string viperLastDialogue

    // music
    string musicPlaying
    table<entity, string> playerMusicPlaying

    // settings storing
    bool titanExitDisabledOnStart

    // wave spawns
    table<entity, bool> entSpawnForVoperBattle
    table<string, int> pendingWaveTimeouts

    // betrayer
    bool fullMatchBetrayedPicked = false
    array<string> betrayedPlayerUIDs
    array<entity> betrayedPlayers
    array<entity> livingBetrayedPlayers
} file

void function VoperBattle_Init()
{
    // store default settings
    if ( Riff_TitanExitEnabled() == eTitanExitEnabled.Never )
        file.titanExitDisabledOnStart = true
    // allow player to eject, but kill them on successful ejecting
    Riff_ForceTitanExitEnabled( eTitanExitEnabled.Always )

    // add new boss titan
	ExtraSpawner_RegisterToBossTitanSpawnList
	(
		"viper_boss",									// spawn name. unique
		"Viper",										// boss name
		"titan_stryder_sniper",							// setFile
		"npc_titan_stryder_sniper_bounty",				// aiSet, bigger overlay
		"behavior_titan_sniper",						// titan behavior
		"execution_northstar_prime",					// executionRef
		"#BOSSNAME_VIPER",								// boss title
		"毒蛇",											// pilot title. can't use localized string
		$"models/humans/pilots/pilot_medium_reaper_m.mdl",		// character model, use mp pilot model: pulse blade male
		VoperBossTitanSetup,                            // generic loadout function for boss fight titans
		1,												// skin index, unsure
		10												// decal index
	)

    ExtraSpawner_RegisterToBossTitanSpawnList
	(
		"ash_boss",										// spawn name. unique
		"Ash",											// boss name
		"titan_stryder_leadwall",						// setFile
		"npc_titan_stryder_leadwall_bounty",			// aiSet, bigger overlay
		"behavior_titan_shotgun",						// titan behavior
		"execution_ronin_prime",						// executionRef
		"#BOSSNAME_ASH",								// boss title
		"艾許",											// pilot title. can't use localized string
		$"models/Humans/heroes/imc_hero_ash.mdl",		// character model
		VoperBossTitanSetup, 					        // generic loadout function for boss fight titans
		6,												// skin index
		10												// decal index
	)

    // music
    AddCallback_OnClientConnected( OnClientConnected )

    // wave spawns
    RegisterSignal( "VoperWaveTransfer" )
    RegisterSignal( "VoperWaveEnd" )
    // unused, already handled by normal wave spawns
    //AddDeathCallback( "npc_soldier" )
    //AddDeathCallback( "npc_super_spectre" )
    //AddDeathCallback( "npc_titan" )

    // betrayer
    RegisterSignal( "TrackPlayerLeavingTitan" )
    RegisterSignal( "OnBetrayerDeath" )
    // track betrayer death
    AddDeathCallback( "player", OnPlayerKilled )
    // for titan limitation
    AddCallback_OnTryGetTitanLoadout( OnTryGetTitanLoadout )
    // for betrayer playstyle restriction
    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
    // for updating betrayer titan loadout
    AddSpawnCallback( "npc_titan", OnTitanSpawned )

    // debug
    AddClientCommandCallback( "voper_battle", CC_ForceStartVoperBattle )
    AddClientCommandCallback( "clear_non_voper_npc", CC_ClearNonVoperNPCs )
}

void function OnClientConnected( entity player )
{
    file.playerMusicPlaying[ player ] <- ""

    PlayCurrentScriptedMusicToPlayer( player )
}

void function VoperBossTitanSetup( entity titan )
{
    // generic loadout function for bosses that has no pilot model for mp
	entity soul = titan.GetTitanSoul()
	if ( IsValid( soul ) )
	{
		// disable their ejecting, so players won't easily notice that they have no proper model
		TitanHealth_SetSoulNPCPilotEjectDelay( soul, -1 ) // -1 means never eject
	}
}

void function OnPlayerKilled( entity player, var damageInfo )
{
    // team switch don't count as anything
    if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.team_switch )
        return

    if ( IsPlayerBetrayer( player ) )
        player.Signal( "OnBetrayerDeath" ) // this will end TrackBetrayedPlayerLifeTime() thread
}

sTryGetTitanLoadoutCallbackReturn function OnTryGetTitanLoadout( entity player, TitanLoadoutDef loadout, bool wasChanged )
{
    sTryGetTitanLoadoutCallbackReturn returnStruct
    returnStruct.wasChanged = false
    returnStruct.loadout = loadout
    if ( IsPlayerBetrayer( player ) && !BETRAYER_TITAN_LIMITED.contains( loadout.titanClass ) )
    {
        print( "Updating betrayer player loadout!" )
        returnStruct.wasChanged = true
        returnStruct.loadout = GetTitanLoadoutFromPersistentData( player, 0 )
        print( "returnStruct.loadout.titanClass: " + returnStruct.loadout.titanClass )
        //SendHudMessage( player, "背叛者不可用帝王", -1, -0.35, 255, 255, 0, 255, 0, 5, 0 )
    }
    
    return returnStruct
}

void function OnPlayerRespawned( entity player )
{
    bool respawnAsTitan = expect bool( player.GetPersistentVar( "spawnAsTitan" ) ) || Riff_SpawnAsTitan() == 1
    if ( respawnAsTitan ) // player already spawned as titan
        return

    if ( player.IsTitan() || IsValid( player.GetPetTitan() ) )
        return

    if ( IsPlayerBetrayer( player ) )
    {
        print( "Betrayer player respawned! Setting to titan" )
        // this will change player to spectator, no worries
        thread ReplaceBetrayerAsTitan( player )
    }
}

bool function IsPlayerBetrayer( entity player )
{
    if ( ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_ONE_LIFE && file.livingBetrayedPlayers.contains( player ) )
         || ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_FULL_MATCH && file.betrayedPlayerUIDs.contains( player.GetUID() ) ) )
        return true

    return false
}

array<entity> function GetAllBetrayedPlayers()
{
    array<entity> betrayedPlayers 
    foreach ( entity player in GetPlayerArray() )
    {
        if ( IsPlayerBetrayer( player ) )
            betrayedPlayers.append( player )
    }

    return betrayedPlayers
}

// a copy of RespawnAsTitan(), without killing player
// betrayer never becomes pilot, so we can feel free to rip their pilot stuffs
void function ReplaceBetrayerAsTitan( entity player )
{
    TakeAllWeapons( player )
    player.FreezeControlsOnServer()
    player.Hide()
    player.SetInvulnerable()
	//if( IsAlive( player ) )
	//	return

	player.Signal( "PlayerRespawnStarted" )
	// modified
	//player.SetPlayerSettings( "spectator" ) // prevent a crash with going from titan => pilot on respawn
	//player.StopPhysics() // need to set this after SetPlayerSettings
	//PlayerClassChangeToSpectator( player )
	
	player.isSpawning = true
	entity spawnpoint = FindSpawnPoint( player, true, ( ShouldStartSpawn( player ) || Flag( "ForceStartSpawn" ) ) && !IsFFAGame() )

 	TitanLoadoutDef titanLoadout = GetTitanLoadoutForPlayer( player )
	
	asset model = GetPlayerSettingsAssetForClassName( titanLoadout.setFile, "bodymodel" )
	Attachment warpAttach = GetAttachmentAtTimeFromModel( model, "at_hotdrop_01", "offset", spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 0 )
	PlayFX( TURBO_WARP_FX, warpAttach.position, warpAttach.angle )
		
	entity titan = CreateAutoTitanForPlayer_FromTitanLoadout( player, titanLoadout, spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	DispatchSpawn( titan )
	// removed. prompt won't show when player is dead
	//player.SetPetTitan( null ) // prevent embark prompt from showing up
	player.SetPetTitan( titan ) // required for marking this player having a pet titan

	ClearPlayerEliminated( player ) // mark as player not eliminated
	ClearRespawnAvailable( player ) // need so the respawn icon doesn't show
	
    AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD ) // hide hud from pilots
	AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) // hide hud
	// do titanfall scoreevent
	AddPlayerScore( player, "Titanfall", player )

	entity camera = CreateTitanDropCamera( spawnpoint.GetAngles(), < 90, titan.GetAngles().y, 0 > )
	camera.SetParent( titan )
	
	// calc offset for spawnpoint angle
	// todo this seems bad but too lazy to figure it out rn
	//vector xyOffset = RotateAroundOrigin2D( < 44, 0, 0 >, < 0, 0, 0>, spawnpoint.GetAngles().y )
	//xyOffset.z = 520 // < 44, 0, 520 > at 0,0,0, seems to be the offset used in tf2
	//print( xyOffset )
	
	vector xyOffset = RotateAroundOrigin2D( < 44, 0, 520 >, < 0, 0, 0 >, spawnpoint.GetAngles().y )
	
	camera.SetLocalOrigin( xyOffset )
	camera.SetLocalAngles( < camera.GetAngles().x, spawnpoint.GetAngles().y, camera.GetAngles().z > ) // this straight up just does not work lol
	camera.Fire( "Enable", "!activator", 0, player )
	
	player.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDestroy" )
	OnThreadEnd( function() : ( player, titan, camera )
	{
		if ( IsValid( player ) )
		{
            player.UnfreezeControlsOnServer()
            player.Show()
            player.ClearInvulnerable()
            RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
			RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) // show hud
			player.isSpawning = false
			ClearTitanAvailable( player ) // we've done everything, considering clear titan available
		}
	
		if ( IsValid( titan ) )
			titan.Destroy() // pilotbecomestitan leaves an npc titan that we need to delete
		else
			RespawnAsPilot( player ) // this is 100% an edgecase, just avoid softlocking if we ever hit it in playable gamestates
			
		camera.Fire( "Disable", "!activator", 0, player )
		camera.Destroy()
	})
	
	waitthread TitanHotDrop( titan, "at_hotdrop_01", spawnpoint.GetOrigin(), spawnpoint.GetAngles(), player, camera ) // do hotdrop anim
	
	player.SetOrigin( titan.GetOrigin() )
	
	// don't make player titan when entity batteryContainer is not valid.
	// This will prevent a servercrash that sometimes occur when evac is disabled and somebody is calling a titan in the defeat screen.
	if( IsValid( titan.GetTitanSoul().soul.batteryContainer ) )
		PilotBecomesTitan( player, titan ) // make player titan
	else
		print( "batteryContainer is not a valid entity in RespawnAsTitan(). Skipping PilotBecomesTitan()." )
}

void function OnTitanSpawned( entity titan )
{
    // check owner player
    entity owner = GetPetTitanOwner( titan )
	if( !IsValid( owner ) )
		return

	// check if player has a titan dropping, if not it means player disembarked and created their pet titans, don't give protection if so.
	if ( "spawnWithoutSoul" in titan.s )
	{
        // this is defined in CreateAutoTitanForPlayer_ForTitanBecomesPilot(), mark the titan as "disembarked" not "hotdropping"
		if ( expect bool ( titan.s.spawnWithoutSoul ) )
			return
	}

    // check owner betrayer state
    if ( IsPlayerBetrayer( owner ) )
    {
        print( "Betrayer titan spawned! Applying loadout" )
        // add betrayer abilities
        SetUpBetrayerOwnedTitan( titan, owner )
    }
    else // normal player state: only enable ejecting tracking for titanExitDisabled case
    {
        if ( file.titanExitDisabledOnStart )
        {
            // disable disembarking but still allow ejecting
            thread TrackPlayerLeavingTitan( owner, "當前模式關閉彈射，離開泰坦視作死亡" )
        }
    }
}

void function SetUpBetrayerOwnedTitan( entity titan, entity owner )
{
    entity soul = titan.GetTitanSoul()
    // setup titan passives and health
    titan.SetMaxHealth( titan.GetMaxHealth() * BETRAYED_PLAYER_HEALTH_SCALE )
    titan.SetHealth( titan.GetMaxHealth() )
    TitanSoul_SetSoulDoomedHealthOverride( soul, BETRAYED_PLAYER_DOOMED_HEALTH )
    StatusEffect_AddEndless( soul, eStatusEffect.damage_reduction, BETRAYED_PLAYER_DAMAGE_REDUCTION_SCALE )

    // shield regen
    TitanHealth_SetSoulEnableShieldRegen( soul, true )
	TitanHealth_SetSoulShieldRegenDelay( soul, BETRAYED_PLAYER_SHIELD_REGEN_DELAY )
	TitanHealth_SetSoulShieldRegenTime( soul, BETRAYED_PLAYER_SHIELD_REGEN_TIME )

    soul.SetShieldHealthMax( soul.GetShieldHealthMax() * BETRAYED_PLAYER_SHIELD_SCALE )
    soul.SetShieldHealth( soul.GetShieldHealthMax() )

    // passives
    PlayerEarnMeter_SetSoulEarnMeterSmokeEnabled( soul, false ) // disable earnmeter smoke
    TitanLoadoutDef loadout = soul.soul.titanLoadout
    // give PAS_HYPER_CORE
    if ( SoulHasPassive( soul, ePassives.PAS_HYPER_CORE ) )
    {
        TakePassive( soul, ePassives.PAS_HYPER_CORE )
        thread RecoverOverCoreEffect( titan )
    }
    // these mods gets applied on player embark!
    loadout.setFileMods.removebyvalue( "pas_mobility_dash_capacity" ) // incompatible with turbo_titan, remove
    loadout.setFileMods.append( "turbo_titan" )
    // super nuke: PAS_NUCLEAR_CORE + PAS_BUILD_UP_NUCLEAR_CORE
    GivePassive( soul, ePassives.PAS_NUCLEAR_CORE )
    if ( !SoulHasPassive( soul, ePassives.PAS_BUILD_UP_NUCLEAR_CORE ) )
        GivePassive( soul, ePassives.PAS_BUILD_UP_NUCLEAR_CORE )

    // core meter
    TitanHealth_SetTitanCoreBuilderMultiplier( titan, BETRAYED_PLAYER_CORE_MULTIPLIER )

    // disable disembarking but still allow ejecting
    thread TrackPlayerLeavingTitan( owner, "背叛者離開泰坦視作死亡" )
}

void function RecoverOverCoreEffect( entity titan )
{
	titan.EndSignal( "OnDestroy" )

	entity soul = titan.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
	soul.EndSignal( "OnDestroy" )

	WaitEndFrame() // wait for titan get smoke weapon
	SoulTitanCore_SetNextAvailableTime( soul, 0.0 )
	titan.TakeOffhandWeapon( OFFHAND_INVENTORY )
}

void function TrackPlayerLeavingTitan( entity owner, string notification = "" )
{
    //print( "RUNNING TrackPlayerLeavingTitan()" )
    owner.Signal( "TrackPlayerLeavingTitan" )
    owner.EndSignal( "TrackPlayerLeavingTitan" )
    owner.EndSignal( "OnDestroy" )
    owner.EndSignal( "OnDeath" )
    //print( "betrayer: " + string( owner ) )

    // disble owner exiting titan
    DisableTitanExit( owner )

    table result = WaitSignal( owner, "DisembarkingTitan", "TitanEjectionStarted" )
    //print( "betrayer leaving titan or ejecting!" )

    entity attacker = owner
    entity inflictor = owner
    int damageSourceId = damagedef_suicide
    int damageTypes = DF_GIB
    if ( result.signal == "TitanEjectionStarted" )
    {
        entity soul = owner.GetTitanSoul()

        if ( IsValid( soul ) )
        {
            table lastAttackInfo = expect table( soul.lastAttackInfo )
            attacker = ( "attacker" in lastAttackInfo ) ? expect entity( lastAttackInfo.attacker ) : owner
            inflictor = ( "inflictor" in lastAttackInfo ) ? expect entity( lastAttackInfo.inflictor ) : owner
            damageSourceId = ( "damageSourceId" in lastAttackInfo ) ? expect int( lastAttackInfo.damageSourceId ) : damagedef_suicide
        }
    }

    while ( owner.IsTitan() )
        WaitFrame()

    //print( "betrayer has became pilot!" )
    if ( IsAlive( owner ) )
    {
        if ( notification != "" )
            SendHudMessage( owner, notification, -1, -0.35, 255, 255, 0, 255, 0, 5, 0 )
        owner.Die( attacker, inflictor, { scriptType = damageTypes, damageSourceId = damageSourceId } )
    }
}

bool function CC_ForceStartVoperBattle( entity player, array<string> args )
{
    // needs checks here
    // requires karma.abuse
	hadGift_Admin = false;
	CheckAdmin( player );
	if ( hadGift_Admin != true )
	{
		Kprint( player, "Admin permission not detected." );
		return false;
	}

    if ( file.fighting )
        return true

    thread StartVoperBattle( 0 )
    return true
}

bool function CC_ClearNonVoperNPCs( entity player, array<string> args )
{
    hadGift_Admin = false;
	CheckAdmin( player );
	if ( hadGift_Admin != true )
	{
		Kprint( player, "Admin permission not detected." );
		return false;
	}

    ClearNonVoperNPCs()

    return true
}

void function ClearNonVoperNPCs( string forcedScriptName = "" )
{
    foreach ( entity npc in GetNPCArray() )
    {
        if ( forcedScriptName != "" )
        {
            if ( npc.GetScriptName() != forcedScriptName )
                continue
        }

        if ( IsAlive( npc ) && npc != file.viper )
            npc.Die()
    }
}

void function StartVoperBattle( int varient )
{
    // npc synced melee settings
    MeleeSyncedNPC_AllowNPCTitanExecutions( true )
	MeleeSyncedNPC_AllowNPCPilotExecutions( true )
	MeleeSyncedNPC_AllowNPCGruntExecutions( true ) // spectres don't have neck snap attacker sequence, they'll try pilot executions, which is bad
	MeleeSyncedNPC_AllowNPCPilotExecuteOtherNPCs( true ) // pilot models don't have syncedMeleeData initialized, so let them use mp pilot executions
    // extra spawner npc weapon settings
    // set up all anti-titan weapons for each npc type
    // grunt
    ExtraSpawner_SetNPCWeapons( "npc_soldier", ["mp_weapon_rspn101", "mp_weapon_lmg", "mp_weapon_shotgun", "mp_weapon_r97", "mp_weapon_dmr"] )
	ExtraSpawner_SetNPCAntiTitanWeapons( "npc_soldier", ["mp_weapon_rocket_launcher", "mp_weapon_mgl", "mp_weapon_defender", "mp_weapon_arc_launcher"] )
	ExtraSpawner_SetNPCGrenadeWeapons( "npc_soldier", ["mp_weapon_frag_grenade", "mp_weapon_thermite_grenade", "mp_weapon_grenade_electric_smoke"] )
    // spectre
	ExtraSpawner_SetNPCWeapons( "npc_spectre", ["mp_weapon_mastiff", "mp_weapon_doubletake", "mp_weapon_hemlok_smg", "mp_weapon_hemlok"] )
	ExtraSpawner_SetNPCAntiTitanWeapons( "npc_spectre", ["mp_weapon_rocket_launcher", "mp_weapon_mgl", "mp_weapon_defender", "mp_weapon_arc_launcher"] )
    // stalker
	ExtraSpawner_SetNPCWeapons( "npc_stalker", ["mp_weapon_softball", "mp_weapon_smr"] ) // npcs can't shoot "mp_weapon_pulse_lmg"
    ExtraSpawner_SetNPCAntiTitanWeapons( "npc_stalker", ["mp_weapon_rocket_launcher", "mp_weapon_mgl", "mp_weapon_defender", "mp_weapon_arc_launcher"] )
    // pilot
	ExtraSpawner_SetNPCWeapons( "npc_pilot_elite", ["mp_weapon_rspn101_og", "mp_weapon_r97", "mp_weapon_car", "mp_weapon_hemlok_smg", "mp_weapon_hemlok", "mp_weapon_g2", "mp_weapon_vinson"] )
	ExtraSpawner_SetNPCAntiTitanWeapons( "npc_pilot_elite", ["mp_weapon_rocket_launcher", "mp_weapon_mgl", "mp_weapon_defender", "mp_weapon_arc_launcher"] )
    ExtraSpawner_SetNPCGrenadeWeapons( "npc_pilot_elite", ["mp_weapon_thermite_grenade", "mp_weapon_grenade_emp"] )	

    // force update player team
    thread ForceSetPlayerToMilitia()

    file.origin_ref = <3352, -4226, 3267>
    if ( varient == 0 )
    {
        file.origin_ref = <985, 1138, 1604>

        switch( GetMapName() )
        {
            case "mp_angel_city": //天使城
                file.origin_ref=< 0, 0, 0 >
                break;

            case "mp_black_water_canal": //黑水运河
                file.origin_ref=< 400, -1250, 600 >
                break;

            case "mp_colony02": //殖民地
                file.origin_ref=< 800, 5115, 310 >
                break;

            case "mp_drydock": //干坞
                file.origin_ref=< 3000, -3250, 800 >
                break;

            case "mp_eden": //伊甸
                file.origin_ref=< 4600, 500, 500 >
                break;

            case "mp_thaw": //系外行星
                file.origin_ref=< 2000, -1498, 0 >
                break;

            case "mp_glitch": //异常
                file.origin_ref=< 3350, 100, 550 >
                break;

            case "mp_relic02": //遗迹
                file.origin_ref=< 5635, -3527, 380 >
                break;
            case "mp_wargames": //战争游戏
                file.origin_ref=< 2600, 1200, 300 >
                break;

            case "mp_homestead": //家园
                file.origin_ref=< 5279, 1716, 600 >
                break;
        }
    }
    file.ref = CreateScriptMover( file.origin_ref, < 0, 90, 0 > )

    vector delta = <100,0,5000>
    LocalVec origin
	origin.v = file.ref.GetOrigin() + delta

    entity viper = ExtraSpawner_SpawnBossTitan( origin.v, <0,90,0>, VOPER_TEAM, "viper_boss", TITAN_MERC )
    file.viper = viper

    MpBossTitan_SetDamageScale( viper, VOPER_DAMAGE_SCALE ) // they can deal higher damage
	MpBossTitan_SetDamageReductionScale( viper, VOPER_DAMAGE_REDUCTION_SCALE )
    viper.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AllowUse( false ) // disable core ability, we use scripted titan core weapon
    // Don't do trigger checks
    viper.SetTouchTriggers( false )

    ExtraSpawner_StopDefaultHandler( viper ) // stop handler for viper, so their animation won't be messed up

    #if VOPER_BATTLE_DEBUG
        viper.SetMaxHealth( 2500 )
    #else
        viper.SetMaxHealth( VOPER_MAX_HEALTH )
    #endif // VOPER_BATTLE_DEBUG
    viper.SetHealth( viper.GetMaxHealth() )
	viper.SetNoTarget( true )
	viper.SetNoTargetSmartAmmo( false )
    viper.kv.AccuracyMultiplier = 50.0
    viper.kv.WeaponProficiency = 50.0

    GiveViperLoadout( viper, true )

    file.fighting = true

    thread StartIntro_BossViper( viper, varient )
}

void function PickRandomBetrayerFromPlayers()
{
    // no betrayer allowed if player count not enough
    if ( GetPlayerArray().len() < BETRAY_MIN_REQUIRED_PLAYERS )
        return

    // full-match betrayer
    if ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_FULL_MATCH )
    {
        if ( file.fullMatchBetrayedPicked )
            return
        array<entity> validBetrayerPlayers
        array<string> lastBetrayedPlayerUIDs = GetStringArrayFromConVar( "last_betrayed_players" )
        StoreStringArrayIntoConVar( "last_betrayed_players", [] ) // clean up convar
        array<entity> pickedBetrayerPlayers
        int pendingBetrayerCount = int( GetPlayerArray().len() * BETRAY_PLAYER_PERCENTAGE )
        if ( pendingBetrayerCount <= 0 )
            pendingBetrayerCount = 1
        pendingBetrayerCount -= GetAllBetrayedPlayers().len()
        if ( pendingBetrayerCount <= 0 )
            return

        // first search for all valid betrayer players
        foreach ( entity player in GetPlayerArray() )
        {
            if ( lastBetrayedPlayerUIDs.contains( player.GetUID() ) )
                continue
            if ( IsPlayerBetrayer( player ) )
                continue

            if ( !validBetrayerPlayers.contains( player ) )
                validBetrayerPlayers.append( player )
        }

        // if we don't have enough players, allow last round picked player to become betrayer again
        bool hasEnoughPlayer = validBetrayerPlayers.len() > pendingBetrayerCount
        while ( pickedBetrayerPlayers.len() < pendingBetrayerCount )
        {
            foreach ( entity player in GetPlayerArray() )
            {
                if ( IsPlayerBetrayer( player ) ) // never allow current betrayer to do it again
                    continue

                if ( hasEnoughPlayer && lastBetrayedPlayerUIDs.contains( player.GetUID() ) )
                    continue

                if ( pickedBetrayerPlayers.contains( player ) )
                    continue

                if ( CoinFlip() )
                {
                    pickedBetrayerPlayers.append( player )
                    break
                }
            }
        }

        // start becoming betaryer
        foreach ( entity player in pickedBetrayerPlayers )
        {
            PlayerBecomesBetrayer( player )
            AppendStringIntoArrayConVar( "last_betrayed_players", player.GetUID() ) // store into convar
        }
        file.fullMatchBetrayedPicked = true
    }
    // one-life betray
    else if ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_ONE_LIFE )
    {
        array<entity> validBetrayerPlayers
        array<entity> pickedBetrayerPlayers
        int pendingBetrayerCount = int( GetPlayerArray().len() * BETRAY_PLAYER_PERCENTAGE )
        if ( pendingBetrayerCount <= 0 )
            pendingBetrayerCount = 1
        pendingBetrayerCount -= GetAllBetrayedPlayers().len()
        if ( pendingBetrayerCount <= 0 )
            return

        // first search for all valid betrayer players
        foreach ( entity player in GetPlayerArray() )
        {
            if ( file.betrayedPlayers.contains( player ) )
                continue
            if ( IsPlayerBetrayer( player ) )
                continue

            if ( !validBetrayerPlayers.contains( player ) )
                validBetrayerPlayers.append( player )
        }

        // if we don't have enough players, allow last round picked player to become betrayer again
        bool hasEnoughPlayer = validBetrayerPlayers.len() > pendingBetrayerCount
        while ( pickedBetrayerPlayers.len() < pendingBetrayerCount )
        {
            foreach ( entity player in GetPlayerArray() )
            {
                if ( IsPlayerBetrayer( player ) ) // never allow current betrayer to do it again
                    continue
                
                if ( hasEnoughPlayer && file.betrayedPlayers.contains( player ) )
                    continue

                if ( pickedBetrayerPlayers.contains( player ) )
                    continue

                if ( CoinFlip() )
                {
                    pickedBetrayerPlayers.append( player )
                    break
                }
            }
        }

        // start becoming betaryer
        foreach ( entity player in pickedBetrayerPlayers )
        {
            PlayerBecomesBetrayer( player )
        }
    }
}

void function PlayerBecomesBetrayer( entity player )
{
    thread PlayerBecomesBetrayer_Threaded( player )
}

void function PlayerBecomesBetrayer_Threaded( entity player )
{
    // full match betray: longer respawn delay
    if ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_FULL_MATCH )
    {
        SetPlayerRespawnDelayForced( player, BETRAYED_PLAYER_RESPAWN_DELAY )
        file.betrayedPlayerUIDs.append( player.GetUID() )
    }
    // one-life betray
    else if ( MAP_BETRAYER_TYPE[ GetMapName() ] == ePlayerBetrayType.BETRAY_ONE_LIFE )
    {
        thread TrackBetrayedPlayerLifeTime( player )
        // add to in-file array
        file.betrayedPlayers.append( player )
    }

    // killing betrayer think
    if ( player.isSpawning ) // is respawning as titan?
    {
        while ( !player.IsTitan() )
            WaitFrame() // wait until player become titan and kill them
    }
    // kill them and send to intermissing cam, so they can respawn
    if ( IsAlive( player ) )
        player.Die( player, player, { damageSourceId = eDamageSourceId.team_switch } )
    SetPlayerCameraToIntermissionCam( player )

    SetTeam( player, VOPER_TEAM )
    NSSendAnnouncementMessageToPlayer( player, "已被切換至背叛者玩家", "將獲得全屬性增強，不可離開泰坦", <1,1,0>, 1, 0 )
    
    thread DelayedRemoveBetrayerPlayerDeathCount( player )
}

void function DelayedRemoveBetrayerPlayerDeathCount( entity player )
{
    WaitEndFrame() // wait for death being added by postDeathThread
    if ( IsValid( player ) )
        player.AddToPlayerGameStat( PGS_DEATHS, -1 )
}

void function TrackBetrayedPlayerLifeTime( entity player )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "OnBetrayerDeath" )
    ArrayRemoveInvalid( file.livingBetrayedPlayers )

    table results = {
        waveEndedProperly = false
    }
    OnThreadEnd
    (
        function(): ( player, results )
        {
            if ( IsValid( player ) )
            {
                if ( IsAlive( player ) )
                    player.Die( player, player, { damageSourceId = eDamageSourceId.outOfBounds } )
                file.livingBetrayedPlayers.removebyvalue( player )
                NSSendInfoMessageToPlayer( player, "背叛狀態已結束" )
            }
            ArrayRemoveInvalid( file.livingBetrayedPlayers )
            // all betrayers died
            if ( file.livingBetrayedPlayers.len() == 0 )
            {
                #if END_WAVE_ON_BETRAYER_WIPE
                    if ( !results.waveEndedProperly )
                        svGlobal.levelEnt.Signal( "VoperWaveEnd" )
                #endif
                /*
                foreach ( entity otherPlayer in GetPlayerArrayOfTeam( GetOtherTeam( VOPER_TEAM ) ) )
                {
                    if ( player != otherPlayer )
                        NSSendAnnouncementMessageToPlayer( player, "全部背叛者已被清除", "波次結束", <1,0,0>, 1, 0 )
                }
                */
            }
        }
    )

    file.livingBetrayedPlayers.append( player )
    svGlobal.levelEnt.WaitSignal( "VoperWaveEnd" )
    results.waveEndedProperly = true
}

void function ForceSetPlayerToMilitia()
{//将玩家全部切换至反抗军
    while ( true )
    {
        foreach ( entity player in GetPlayerArray() )
        {
            if ( !IsPlayerBetrayer( player ) && player.GetTeam() != TEAM_MILITIA )
            {
                SetTeam( player, TEAM_MILITIA )
                entity petTitan = player.GetPetTitan()
                if ( IsValid( petTitan ) )
                    SetTeam( petTitan, TEAM_MILITIA )
            }
        }

        WaitFrame()
        //TitanWeapon_ViperMod()
    }

}

void function RunJetSfx( entity viper )
{
    PlayLoopFXOnEntity( $"P_xo_jet_fly_large", viper, "FX_L_BOT_THRUST", null, null, ENTITY_VISIBLE_TO_EVERYONE )
    PlayLoopFXOnEntity( $"P_xo_jet_fly_large", viper, "FX_R_BOT_THRUST", null, null, ENTITY_VISIBLE_TO_EVERYONE )
    PlayLoopFXOnEntity( $"P_xo_jet_fly_small", viper, "FX_L_TOP_THRUST", null, null, ENTITY_VISIBLE_TO_EVERYONE )
    PlayLoopFXOnEntity( $"P_xo_jet_fly_small", viper, "FX_R_TOP_THRUST", null, null, ENTITY_VISIBLE_TO_EVERYONE )
}

// for extra_ai_spawner boss viper
void function StartIntro_BossViper( entity viper, int varient )
{
    viper.EndSignal( "OnDeath" )
    viper.EndSignal( "OnDestroy" )

    PlayScriptedMusicToAllPlayers( "music_s2s_14_titancombat" )
    WaitSignal( viper, "BossTitanIntroEnded" ) // intro reaches combat point

    // viper mover setup
    vector delta = <100,0,5000>
    LocalVec origin
	origin.v = file.ref.GetOrigin() + delta

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

	thread RunJetSfx( viper )

	file.viperShip = viperShip

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
        file.RespawnShip.NotSolid() // stop it's collision
    }

    if ( varient == 0 )
        thread correctViper()
    // viper mover setup ends

    //thread CoreFire()
    thread RocketFireThink()

    thread ShipIdleAtTargetPos( viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < -500, 0, 200 > ) , <100,500,0> )
    link = viper.GetParent()
    link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )

    thread AnimateViper( viper )

    if ( varient == 0 )
    {
        viper.SetInvulnerable() // invulnerable gets cleared in phase3
        #if VOPER_BATTLE_DEBUG
            thread Phase3Think()
        #else
            thread Phase1Think()
        #endif // VOPER_BATTLE_DEBUG
        //thread PhaseBackThink() 
    }
}

array<entity> function ViperGetTargetPlayers( bool heavyArmorOnly = false )
{
    entity voper = GetVoper()
    array<entity> validTargets
    foreach ( entity player in GetPlayerArray_Alive() )
    {
        if ( IsValid( voper ) )
        {
            if ( voper.GetTeam() == player.GetTeam() )
                continue
        }

        if ( player.IsTitan() )
            validTargets.append( player )
    }
    if ( !heavyArmorOnly && validTargets.len() == 0 ) // no valid targets!!
    {
        foreach ( entity player in GetPlayerArray_Alive() )
        {
            if ( IsValid( voper ) )
            {
                if ( voper.GetTeam() == player.GetTeam() )
                    continue
            }

            validTargets.append( player )
        }
    }

    return validTargets
}

Point function GetHotDropSpawnPointFromLuckyPlayer( entity player )
{
    vector origin = player.GetOrigin()
    vector traceAngles = < 90, player.GetAngles().y, 0 > // face down to ground
    vector tracePos = origin + < 0, 0, 500 >

    return CalculateTitanReplacementPoint( origin, tracePos, traceAngles )
}

void function Phase1Think()
{
    // start betrayer think
    PickRandomBetrayerFromPlayers()

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

    // phase 1 enemy: reaper can launch ticks
    const int count = FIRST_WAVE_REAPERS_COUNT
    thread VoperBattle_GenericReaperSpawn( "phase1_ents", count ) // start spawn

    // calculate wave points
    int wavePoints = WAVE_POINTS_PER_REAPER * count
    // wait for all reapers killed or 150s timeout
    waitthread WaitForWaveTimeout( "phase1_ents", wavePoints, FIRST_WAVE_TIMEOUT )

    wait PHASE_TRANSITION_DELAY
    thread Phase2Think()
    //thread RocketFireThink()
}

void function Phase2Think()
{
    // start betrayer think
    PickRandomBetrayerFromPlayers()

	//EmitSoundOnEntity( file.viper, "diag_sp_viperchat_STS666_01_01_mcor_viper" )
    VoperBattle_ScriptedDialogue( "diag_sp_viperchat_STS666_01_01_mcor_viper" )

    foreach( entity player in GetPlayerArray() )
        TryRechargePlayerTitanMeter( player )

    // phase 2 enemy: npc pilot embarked titans
    const int count = SECOND_WAVE_TITANS_COUNT
    thread VoperBattle_GenericTitanSpawn( "phase2_ents", count ) // start spawn

    // calculate wave points
    int wavePoints = WAVE_POINTS_PER_TITAN * count
    // wait for all titans killed or 180s timeout
    waitthread WaitForWaveTimeout( "phase2_ents", wavePoints, SECOND_WAVE_TIMEOUT )

    wait PHASE_TRANSITION_DELAY
    thread Phase3Think()
}

void function Phase3Think()
{
    print( "RUNNING Phase3Think()" )

    //file.viperShip.model.ClearInvulnerable()
    thread ShipIdleAtTargetPos( file.viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < 500, 0, 200 > ) , <500,1000,0> )
    entity link = file.viperShip.model.GetParent()
    link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
    int waves = 0

    thread UnlimitedSpawn()
    // below are modified
    //file.viperShip.model.SetHealth( VOPER_MAX_HEALTH )
    thread BossAshAssistThink()

    foreach( entity player in GetPlayerArray() )
        TryRechargePlayerTitanMeter( player )

    entity soul = file.viperShip.model.GetTitanSoul()

    while( IsValid( file.viperShip.model ) )
    {
        if ( IsValid( soul ) && soul.IsDoomed() )
            thread SetBehavior( file.viperShip, eBehavior.DEATH_ANIM )

        WaitFrame()
    }

    //AddTeamScore( TEAM_MILITIA, 10000 )
    //AddTeamScore( TEAM_IMC, 10000 )
    AddTeamScore( GetOtherTeam( VOPER_TEAM ), 10000 )
    StopScriptedMusicForAllPlayers()
}

void function BossAshAssistThink()
{
    while ( IsValid( file.viperShip.model ) )
    {
        if ( GetHealthFrac( file.viperShip.model ) <= ASH_ASSIST_HEALTH_FRAC )
        {
            SpawnAshBossTitanAndSetup()
            return
        }
        WaitFrame()
    }
}

void function SpawnAshBossTitanAndSetup()
{
    vector pos = file.origin_ref
    if ( GetMapName() in MAP_ASH_SPAWNPOINTS )
        pos = MAP_ASH_SPAWNPOINTS[ GetMapName() ]
    entity ash = ExtraSpawner_SpawnBossTitan( pos, <0,90,0>, VOPER_TEAM, "ash_boss", TITAN_MERC )

    ash.SetMaxHealth( ASH_MAX_HEALTH )
    ash.SetHealth( ash.GetMaxHealth() )
    MpBossTitan_SetDamageScale( ash, ASH_DAMAGE_SCALE ) // they can deal higher damage
	MpBossTitan_SetDamageReductionScale( ash, ASH_DAMAGE_REDUCTION_SCALE )
    TitanHealth_SetTitanCoreBuilderMultiplier( ash, ASH_CORE_METER_MULTIPLIER ) // want them get core abilities faster
}

// new-adding version
// WIP
void function UnlimitedSpawn()
{
    int team = file.viperShip.model.GetTeam()
    // homestead: sarah briggs's quest
    bool sarahQuestCompleted = false

    while ( true )
    {
        WaitFrame() // always wait a frame to prevent stuck!

        entity voper = file.viperShip.model
        if ( !IsAlive( voper ) ) // voper died before loop!
            return
        entity soul = voper.GetTitanSoul()
        if ( !IsValid( soul ) )
            return
        if ( soul.IsDoomed() ) // doomed voper handled by Phase3Think()
            return

        bool runWaveSpawn = true // if set to false, it means we won't run wave spawn for this loop
        float delayBeforeNextWave = 0.0

        // viper health
        float healthFrac = GetHealthFrac( voper )
        if ( healthFrac <= VOPER_MIN_HEALTH_FRAC ) // viper near death after a wave...
        {
            // force stop viper logic and kill it
            runWaveSpawn = false

            // start death animation
            thread SetBehavior( file.viperShip, eBehavior.DEATH_ANIM )
            voper.SetInvulnerable()
            VoperBattle_ScriptedDialogue( "diag_sp_bossFight_STS676_42_01_imc_viper" )

            wait 5
            // set winner!
            AddTeamScore( GetOtherTeam( VOPER_TEAM ), 114514 )
            //AddTeamScore( TEAM_IMC, 111111 )
            voper.Die()
            return // viper died, wave spawn ends
        }
        // homestead: sarah briggs's quest
        else if ( healthFrac <= SARAH_QUEST_VOPER_HEALTH_FRAC )
        {
            if ( GetMapName() == "mp_homestead" && !sarahQuestCompleted )
            {
                runWaveSpawn = false
                delayBeforeNextWave = 10.0

                voper.SetInvulnerable()
                waitthread SarahDefenseThink( TEAM_MILITIA )
                sarahQuestCompleted = true
                PassWaves = 2 // reset wave count: we enter health wave after quest
            }
        }

        // wave
        if ( runWaveSpawn )
        {
            print( "PassWaves" )
            switch ( PassWaves )
            {
                case 1: // first wave
                    // wave type: npc spawn
                    print( "wave type: npc spawn" )
                    // start betrayer think
                    PickRandomBetrayerFromPlayers()
                    // start wave!
                    VoperBattle_ScriptedDialogue( "diag_sp_bossFight_STS676_22_01_imc_viper" )
                    voper.SetInvulnerable()
                    const int squadSpawnCount = UNLIMITED_SPAWN_SQUADS_COUNT
                    const int reaperSpawnCount = UNLIMITED_SPAWN_REAPERS_COUNT
                    const int titanSpawnCount = UNLIMITED_SPAWN_TITANS_COUNT
                    thread VoperBattle_GenericSpecialistSquadSpawn( "phase3_ents", squadSpawnCount, "npc_soldier", "npc_soldier_shield_captain" ) // 5 shield captain squad
                    thread VoperBattle_GenericReaperSpawn( "phase3_ents", reaperSpawnCount ) // 4 tick reapers
                    thread VoperBattle_GenericTitanSpawn( "phase3_ents", titanSpawnCount ) // 3 npc titans
                    // calculate wave points. all titans + all reapers + all infantries
                    int wavePoints =  WAVE_POINTS_PER_INFANTRY * SQUAD_SIZE * squadSpawnCount + WAVE_POINTS_PER_REAPER * reaperSpawnCount + WAVE_POINTS_PER_TITAN * titanSpawnCount
                    // wait for required spawn, no timeout
                    waitthread WaitForWaveTimeout( "phase3_ents", wavePoints, UNLIMITED_SPAWN_TIMEOUT ) // 150s timeout
                    break

                case 2: // second wave
                    // wave type: viper health
                    print( "wave type: viper health" )
                    delayBeforeNextWave = 5.0 // next wave delay 

                    // start wave!
                    VoperBattle_ScriptedDialogue( "diag_sp_bossFight_STS676_36_01_imc_viper" )
                    waitthread WaitForVoperHealthLossPercentage( 0.1 ) // wait for viper loses 10% of health
                    break

                default: // reach max wave spawns
                    PassWaves = 0 // start from first wave
                    break
            }
        }

        if ( delayBeforeNextWave > 0 )
            wait delayBeforeNextWave

        PassWaves++ // one wave cleared!
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

        SendHudMessage(player, "超出了战斗区域！" , -1, -0.35, 255, 255, 0, 255, 0, 3, 0)
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
        //WaitFrame()

        if ( file.coring )
        {
            WaitFrame() // prevent loop stucking!
            continue
        }

        // rework here: prevent idle animation keep blend-in and out
        viper.Anim_Play( "s2s_viper_flight_move_idle" )
        WaittillAnimDone( viper )

        //WaitFrame()
    }
}

void function RocketFireThink()
{
    while( IsValid( file.viperShip.model ) && file.fighting )
    {
        // rework here...
        //if ( RandomIntRange( 0, 15 ) == 1 )
        //    waitthread CoreFire()
        //wait 1

        waitthread CoreFire()
        wait RandomFloatRange( VOPER_CORE_MIN_COOLDOWN, VOPER_CORE_MAX_COOLDOWN )
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    viper logic                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void function GiveViperLoadout( entity viper, bool ignoreAnim = false )
{
    TakeAllWeapons( viper )

	viper.GiveWeapon( "mp_titanweapon_sniper", [] )
    viper.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets",0, [ "burn_mod_titan_dumbfire_rockets", "fd_twin_cluster" ] )
    viper.GiveOffhandWeapon( "mp_titanability_tether_trap",2, [ "fd_explosive_trap" ] )

    // modified: remove meaningless idle anim call
    //if ( !ignoreAnim )
    //    viper.Anim_Play( "s2s_viper_flight_move_idle" )
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

    //entity target = ViperGetEnemy( file.viper )
    //WeaponViperAttackParams	viperParams = ViperSwarmRockets_SetupAttackParams( target.GetOrigin() - <0,0,200>, file.ref )
    // viperParams.target = target

    file.viperShip.mover.NonPhysicsMoveTo( file.viper.GetOrigin(), 1,0,0 )

    foreach( entity player in GetPlayerArray() )
        EmitSoundOnEntityOnlyToPlayer( player, player, "northstar_rocket_warning" )

    file.coring = true // mark as we're firing core, so idle animation don't override
    file.viper.Anim_Stop()
    file.viper.Anim_Play( "s2s_viper_flight_core_idle" )

    int validShots
    //for( int x = 0; x < VOPER_CORE_MAX_BURSTS; x++ )
    while ( validShots <= VOPER_CORE_MAX_BURSTS )
    {
        entity target = ViperGetEnemy( file.viper )
        if ( target == file.ref ) // using ref as target! meaning we can't find target
        {
            WaitFrame()
            continue
        }
        WeaponViperAttackParams	viperParams = ViperSwarmRockets_SetupAttackParams( target.GetOrigin() - <0,0,200>, file.ref )
        // reworked... really should make them homing to player
        //OnWeaponScriptPrimaryAttack_ViperSwarmRockets_s2s( file.viper.GetActiveWeapon(), viperParams )
        OnWeaponScriptPrimaryAttack_ViperSwarmRockets_s2s( file.viper.GetActiveWeapon(), viperParams, target, VOPER_CORE_ROCKET_HOMING_SPEED_SCALE, VOPER_CORE_ROCKET_SPEED_SCALE )
        file.viper.Anim_Stop()
        file.viper.Anim_Play( "s2s_viper_flight_core_idle" )
        validShots += 1
        wait VOPER_CORE_BURST_INTERVAL
    }

    wait 1

    file.coring = false // remove core statement and start idle animation

    GiveViperLoadout( file.viper )
}

void function correctViper()
{
    entity viper = file.viperShip.model

    while( IsValid( viper ) )
    {
        entity link = file.viperShip.model.GetParent()
        if ( !IsValid( link ) )
            return
        if ( viper.IsOnGround() )
        {
            viper.SetOrigin( viper.GetParent().GetOrigin() )
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )

            thread ShipIdleAtTargetPos(  file.viperShip, WorldToLocalOrigin( file.ref.GetOrigin() + < 0, 0, 500 > ) , <100,500,0> )
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
        }

        if ( viper.GetAngles().y >= 270 || viper.GetAngles().y <= 90 )
        {
            if ( IsValid(file.viperShip.model)){
            link.NonPhysicsRotateTo( <0,180,0>, 0.00000001,0,0 )
            }
        }
        wait 1
    }
}

void function MissionEND()
{
    entity voper = GetVoper()
    if ( IsValid( voper ) )
    {
        voper.SetHealth( voper.GetMaxHealth() * SARAH_QUEST_VOPER_HEALTH_FRAC )
        //PassWaves = 0
        voper.ClearInvulnerable()
    }
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
    array<entity> validTargets = ViperGetTargetPlayers()
    if ( validTargets.len() == 0 )
        return file.ref

    entity target = GetClosest2D( validTargets, viper.GetOrigin(), 1000000000 )

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

	//EmitSoundOnEntity( file.viper, "diag_sp_gibraltar_STS102_13_01_imc_grunt1" )
    VoperBattle_ScriptedDialogue( "diag_sp_gibraltar_STS102_13_01_imc_grunt1" )

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

	//EmitSoundOnEntity( file.viper, "diag_sp_maltaDeck_STS374_01_01_mcor_bt" )
    VoperBattle_ScriptedDialogue( "diag_sp_maltaDeck_STS374_01_01_mcor_bt" )
}



// __        _____     _______     ____  ____   ___        ___   _     _____ _   _ _   _  ____ _____ ___ ___  _   _ ____  
// \ \      / / \ \   / / ____|   / ___||  _ \ / \ \      / / \ | |   |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
//  \ \ /\ / / _ \ \ / /|  _|     \___ \| |_) / _ \ \ /\ / /|  \| |   | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
//   \ V  V / ___ \ V / | |___     ___) |  __/ ___ \ V  V / | |\  |   |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
//    \_/\_/_/   \_\_/  |_____|   |____/|_| /_/   \_\_/\_/  |_| \_|   |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 

// main setup func, should always be at the end of a npc's handler function
void function SetupVoperBattleSpawnedNPC( entity npc, string scriptName, int wavePoint = 1 )
{
    npc.SetScriptName( scriptName )
    file.entSpawnForVoperBattle[ npc ] <- true
    thread WaitForNPCDeath( npc, scriptName, wavePoint )
}

void function WaitForNPCDeath( entity npc, string scriptName, int wavePoint )
{
    // we stop counting if wave transfering
    svGlobal.levelEnt.EndSignal( "VoperWaveTransfer" ) 
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" )
    string scriptName = npc.GetScriptName()
    WaitSignal( npc, "OnDeath", "OnDestroy" )

    if ( scriptName in file.pendingWaveTimeouts )
        file.pendingWaveTimeouts[ scriptName ] += wavePoint
}

void function WaitForViperTargetSpawn( bool heavyArmorOnly = false )
{
    // wait for target spawn
    while ( ViperGetTargetPlayers( heavyArmorOnly ).len() == 0 ) 
        WaitFrame()
}

void function VoperBattle_GenericReaperSpawn( string waveEntName, int count )
{
    // generic reaper enemy: nuke reaper that can launch
    // setup reaper handler
    ExtraSpawner_SetNPCHandlerFunc( 
        "npc_super_spectre",            // npc class to handle
        // npc handler function
        void function( entity reaper ): ( waveEntName )
        {
            // start search for enemies
            thread ExtraSpawner_ReaperHandler( reaper )

            // highlight
            thread SonarEnemyForever( reaper )

            // update health
            reaper.SetMaxHealth( reaper.GetMaxHealth() * REAPER_HEALTH_SCALE )
            reaper.SetHealth( reaper.GetMaxHealth() )

            // setup wave points, for WaitForWaveTimeout() handling spawns
            SetupVoperBattleSpawnedNPC( reaper, waveEntName, WAVE_POINTS_PER_REAPER )
        }
    ) // npc handler

    // we stop spawning if wave transfering
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" )

    WaitEndFrame() // wait so WaitForWaveTimeout() can set up

    for( int x = 0; x < count; x++ )
    {
        waitthread WaitForViperTargetSpawn() // wait for target spawn

        array<entity> validTargets = ViperGetTargetPlayers()
        if ( validTargets.len() == 0 ) // defensive fix: still no target valid
        {
            x--
            continue
        }
        entity luckyPlayer = validTargets[ RandomInt( validTargets.len() ) ]

        Point dropPoint = GetHotDropSpawnPointFromLuckyPlayer( luckyPlayer )

        thread ExtraSpawner_SpawnReaperCanLaunchTicks( 
            dropPoint.origin,           // origin
            dropPoint.angles,           // angles
            VOPER_TEAM,                 // team
            "npc_super_spectre_aitdm",  // reaper aiset
            "npc_frag_drone_fd"         // ticks aiset
        )

        wait 0.7
    }
}

void function VoperBattle_GenericTitanSpawn( string waveEntName, int count )
{
    // generic titan enemy: npc pilot embarked titans
    // setup titan handler
    ExtraSpawner_SetNPCHandlerFunc( 
        "npc_titan",            // npc class to handle
        // npc handler function
        void function( entity titan ): ( waveEntName )
        {
            // search for enemies
            thread ExtraSpawner_TitanHandler( titan )

            // we don't setup general stuffs for boss titan
            if ( titan.ai.bossTitanType != TITAN_MERC )
            {
                TitanHealth_SetTitanCoreBuilderMultiplier( titan, NPC_TITAN_CORE_METER_MULTIPLIER ) // want them get core abilities faster
        
                // highlight
                thread SonarEnemyForever( titan, 5 ) // add 5s delay before start highlighting

                // update health
                titan.SetMaxHealth( titan.GetMaxHealth() * TITAN_HEALTH_SCALE )
                titan.SetHealth( titan.GetMaxHealth() )

                // setup default nuke
                ExtraSpawner_SetNPCPilotEmbarkedTitanNuke( titan )
                TitanHealth_SetSoulNPCPilotEjectDelay( titan.GetTitanSoul(), NPC_TITAN_EJECTING_DELAY )

                // setup wave points, for WaitForWaveTimeout() handling spawns
                print( "SetupVoperBattleSpawnedNPC for: " + string( titan ) )
                SetupVoperBattleSpawnedNPC( titan, waveEntName, WAVE_POINTS_PER_TITAN )
            }
        }
    )

    // we stop spawning if wave transfering
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" )

    WaitEndFrame() // wait so WaitForWaveTimeout() can set up

    // valid titan enemies
    const array<string> TITAN_SPAWN_NAMES =
    [
        "ion",
        "scorch",
        "tone",
        "northstar",
        "ronin",
        "legion",
        // no monarch
    ]

    for( int x = 0; x < count; x++ )
    {
        waitthread WaitForViperTargetSpawn() // wait for target spawn

        array<entity> validTargets = ViperGetTargetPlayers()
        if ( validTargets.len() == 0 ) // defensive fix: still no target valid
        {
            x--
            continue
        }
        entity luckyPlayer = validTargets[ RandomInt( validTargets.len() ) ]

        string titanToSpawn = TITAN_SPAWN_NAMES[ RandomInt( TITAN_SPAWN_NAMES.len() ) ]
        Point dropPoint = GetHotDropSpawnPointFromLuckyPlayer( luckyPlayer )

        thread ExtraSpawner_SpawnPilotCanEmbark(
            dropPoint.origin,   // origin
            dropPoint.angles,   // angles
            VOPER_TEAM,         // team
            titanToSpawn        // spawn name
        )

        wait 1.5
    }
}

void function VoperBattle_GenericNPCSquadSpawn( string waveEntName, int count, string squadClass )
{
    // we stop spawning if wave transfering
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" )
    
    WaitEndFrame() // wait so WaitForWaveTimeout() can set up

    for( int x = 0; x < count; x++ )
    {
        waitthread WaitForViperTargetSpawn() // wait for target spawn

        array<entity> validTargets = ViperGetTargetPlayers()
        if ( validTargets.len() == 0 ) // defensive fix: still no target valid
        {
            x--
            continue
        }
        entity luckyPlayer = validTargets[ RandomInt( validTargets.len() ) ]

        Point dropPoint = GetHotDropSpawnPointFromLuckyPlayer( luckyPlayer )

        thread ExtraSpawner_SpawnDropPod( 
            dropPoint.origin,           // origin
            dropPoint.angles,           // angles
            VOPER_TEAM,                 // team
            squadClass,                 // npc class
            // squad handler function
            void function( array<entity> guys ): ( waveEntName )
            {
                // start search for enemies
                thread ExtraSpawner_SquadHandler( guys )

                // below should setup for all squad members
                foreach ( guy in guys )
                {
                    // highlight
                    thread SonarEnemyForever( guy )

                    // update health
                    guy.SetMaxHealth( guy.GetMaxHealth() * INFANTRY_HEALTH_SCALE )
                    guy.SetHealth( guy.GetMaxHealth() )

                    // setup wave points, for WaitForWaveTimeout() handling spawns
                    SetupVoperBattleSpawnedNPC( guy, waveEntName, WAVE_POINTS_PER_INFANTRY )
                }
            },
            eDropPodFlag.DISSOLVE_AFTER_DISEMBARKS      // droppod flag. don't want them waste time on disembarking the droppod
        )

        wait 0.5
    }
}

void function VoperBattle_GenericSpecialistSquadSpawn( string waveEntName, int count, string squadClass, string leaderAiSet )
{
    // we stop spawning if wave transfering
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" )

    WaitEndFrame() // wait so WaitForWaveTimeout() can set up

    for( int x = 0; x < count; x++ )
    {
        waitthread WaitForViperTargetSpawn() // wait for target spawn

        array<entity> validTargets = ViperGetTargetPlayers()
        if ( validTargets.len() == 0 ) // defensive fix: still no target valid
        {
            x--
            continue
        }
        entity luckyPlayer = validTargets[ RandomInt( validTargets.len() ) ]

        Point dropPoint = GetHotDropSpawnPointFromLuckyPlayer( luckyPlayer )

        thread ExtraSpawner_SpawnSpecialistGruntDropPod( 
            dropPoint.origin,           // origin
            dropPoint.angles,           // angles
            VOPER_TEAM,                 // team
            squadClass,                 // npc class
            leaderAiSet,                // specialist grunt leader aiset
            150,                        // specialist grunt leader health. this is a temp, we update it in squad handler
            // squad handler function
            void function( array<entity> guys ): ( waveEntName )
            {
                // start search for enemies
                thread ExtraSpawner_SquadHandler( guys )

                // below should setup for all squad members
                int index = 0
                foreach ( guy in guys )
                {
                    bool isLeader = index == 0 // leader always spawn first

                    // highlight
                    thread SonarEnemyForever( guy )

                    // update health. for leader, update their health to all other squad member's health total
                    if ( isLeader )
                    {
                        int totalSquadHealth = 0
                        foreach ( otherGuy in guys )
                        {
                            if ( otherGuy == guy )
                                continue
                            totalSquadHealth += guy.GetMaxHealth()
                        }
                        if ( totalSquadHealth > 0 )
                            guy.SetMaxHealth( totalSquadHealth )
                    }
                    guy.SetMaxHealth( guy.GetMaxHealth() * INFANTRY_HEALTH_SCALE )
                    guy.SetHealth( guy.GetMaxHealth() )

                    // setup wave points, for WaitForWaveTimeout() handling spawns
                    SetupVoperBattleSpawnedNPC( guy, waveEntName, WAVE_POINTS_PER_INFANTRY )

                    index++
                }
            },
            eDropPodFlag.DISSOLVE_AFTER_DISEMBARKS      // droppod flag. don't want them waste time on disembarking the droppod
        )

        wait 0.5
    }
}

void function WaitForWaveTimeout( string waveEntName, int wavePointsNeeded, float maxTimeout )
{
    svGlobal.levelEnt.Signal( "VoperWaveTransfer" ) // stop current counting wave
    svGlobal.levelEnt.EndSignal( "VoperWaveEnd" ) // signaled on all betrayer death
    file.pendingWaveTimeouts[ waveEntName ] <- 0

    OnThreadEnd
    (
        function(): ( waveEntName )
        {
            print( "waveEnt: " + waveEntName + " ended!" )
            delete file.pendingWaveTimeouts[ waveEntName ]
            #if WAVE_CLEANUP_ON_END
                ClearNonVoperNPCs( waveEntName )
            #endif
        }
    )

    float maxWait = Time() + maxTimeout
    if ( maxTimeout < 0 )
        maxWait = Time() + 65535 // timeout < 0 means no timeout
    while ( Time() < maxWait )
    {
        //print( "file.pendingWaveTimeouts[ waveEntName ]: " + string( file.pendingWaveTimeouts[ waveEntName ] ) )
        //print( "wavePointsNeeded: " + string( wavePointsNeeded ) )
        if ( file.pendingWaveTimeouts[ waveEntName ] >= wavePointsNeeded )
            break

        WaitFrame()
    }

    // wave ended!
    svGlobal.levelEnt.Signal( "VoperWaveEnd" ) // stop current counting wave
}

void function WaitForVoperHealthLossPercentage( float percentage )
{
    entity voper = file.viper
    int maxHealth = voper.GetMaxHealth()
    int startHealth = voper.GetHealth()
    int minHealth = int( maxHealth * VOPER_MIN_HEALTH_FRAC )
    int targetHealth = maxint( minHealth, startHealth - int( maxHealth * percentage ) )
    while ( IsAlive( voper ) )
    {
        voper.ClearInvulnerable() // keep clearing
        if ( voper.GetHealth() <= targetHealth )
            break

        WaitFrame()
    }
    if ( IsAlive( voper ) )
        voper.SetInvulnerable() // wave ended properly
}

//  _   _ _____ ___ _     ___ _______   __    _____ _   _ _   _  ____ _____ ___ ___  _   _ ____  
// | | | |_   _|_ _| |   |_ _|_   _\ \ / /   |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
// | | | | | |  | || |    | |  | |  \ V /    | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
// | |_| | | |  | || |___ | |  | |   | |     |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
//  \___/  |_| |___|_____|___| |_|   |_|     |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 

void function SonarTitan(entity player, float duration, float delay = 0)
{
    player.EndSignal( "OnDestroy" )

    wait delay
	//StatusEffect_AddTimed( player, eStatusEffect.sonar_detected, 1.0, duration, 0.0 ) // this overwrites highlight context...
    Highlight_SetEnemyHighlight( player, "enemy_sonar" )

    wait duration

    if (Hightlight_HasEnemyHighlight(player, "enemy_sonar"))
        Highlight_ClearEnemyHighlight( player )
}

void function SonarEnemyForever( entity npc, float delay = 0 )
{
    npc.EndSignal( "OnDeath" )
    npc.EndSignal( "OnDestroy" )

    wait delay
    while ( true )
    {
        Highlight_SetEnemyHighlight( npc, "enemy_sonar" )
        npc.WaitSignal( "StopPhaseShift" ) // restart highlight after entity phase!
    }
}

void function DefaultEventCallbacks_Viper( ShipStruct ship, int val )
{

}

bool function TryRechargePlayerTitanMeter( entity player )
{
    if ( !player.IsTitan() && IsValid( player ) && IsAlive( player ) )
    {
        PlayerEarnMeter_AddOwnedFrac( player, 1.0 )
        return true
    }

    return false
}

void function PlayScriptedMusicToAllPlayers( string musicName )
{
    file.musicPlaying = musicName

    foreach ( entity player in GetPlayerArray() )
    {
        PlayCurrentScriptedMusicToPlayer( player )
    }
}

// on connection
void function PlayCurrentScriptedMusicToPlayer( entity player )
{
    thread PlayCurrentScriptedMusicToPlayer_Threaded( player )
}

void function PlayCurrentScriptedMusicToPlayer_Threaded( entity player )
{
    player.EndSignal( "OnDestroy" )
    WaitFrame() // wait for player can receive server signals
    print( "file.musicPlaying: " + file.musicPlaying )
    if ( file.musicPlaying != "" )
    {
        EmitSoundOnEntityOnlyToPlayer( player, player, file.musicPlaying )
        file.playerMusicPlaying[ player ] = file.musicPlaying
    }
}

void function StopScriptedMusicForAllPlayers()
{
    foreach ( entity player in GetPlayerArray() )
    {
        StopLastScriptedMusicForPlayer( player )
    }
    file.musicPlaying = ""
}

void function StopLastScriptedMusicForPlayer( entity player )
{
    if ( file.playerMusicPlaying[ player ] == "" )
        return
    EmitSoundOnEntityOnlyToPlayer( player, player, file.playerMusicPlaying[ player ] )
    file.playerMusicPlaying[ player ] = ""
}

void function VoperBattle_ScriptedDialogue( string dialogue )
{
    entity viper = file.viper
    if ( !IsAlive( viper ) )
        return
    MpBossTitan_CancelBossConversation( viper ) // cancel current boss titan conversation
    if ( file.viperLastDialogue != "" )
        StopSoundOnEntity( viper, file.viperLastDialogue )
    EmitSoundOnEntity( viper, dialogue )
    file.viperLastDialogue = dialogue
    MpBossTitan_DelayNextBossRandomLine( viper ) // delay viper's next random dialogue
}


//   ____ ___  _   ___     ___    ____      _   _ _____ ___ _     ___ _______   __
//  / ___/ _ \| \ | \ \   / / \  |  _ \    | | | |_   _|_ _| |   |_ _|_   _\ \ / /
// | |  | | | |  \| |\ \ / / _ \ | |_) |   | | | | | |  | || |    | |  | |  \ V / 
// | |__| |_| | |\  | \ V / ___ \|  _ <    | |_| | | |  | || |___ | |  | |   | |  
//  \____\___/|_| \_|  \_/_/   \_\_| \_\    \___/  |_| |___|_____|___| |_|   |_|  

array<string> function GetStringArrayFromConVar( string convar )
{
    return split( GetConVarString( convar ), "," )
}

string function StoreStringArrayIntoConVar( string convar, array<string> arrayToStore )
{
    string builtString = ""
    foreach ( string item in arrayToStore )
    {
        if ( builtString == "" )
            builtString = item
        else
            builtString += "," + item
    }

    SetConVarString( convar, builtString )
    return builtString
}

void function AppendStringIntoArrayConVar( string convar, string stringToAppend )
{
    array<string> convarArray = GetStringArrayFromConVar( convar )
    convarArray.append( stringToAppend )
    StoreStringArrayIntoConVar( convar, convarArray )
}
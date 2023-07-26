global function NorthstarRespawnProtect_Init

void function NorthstarRespawnProtect_Init(){
    AddCallback_OnPilotBecomesTitan(OnPilotBecomesTitan)
    AddSpawnCallback( "npc_titan", OnAutoTitanSpawned )
}


void function OnPilotBecomesTitan(entity player, entity titan){
    thread OnPilotBecomesTitanThread(player,titan)
}

void function OnAutoTitanSpawned(entity titan){
    thread OnAutoTitanSpawnedThread(titan)
}

void function OnAutoTitanSpawnedThread(entity titan){
	entity owner = GetPetTitanOwner( titan )
    entity soul = titan.GetTitanSoul()
	if( !IsValid( owner ) ){
        return
    }
	if( !owner.IsPlayer() ){
        return
    }
    titan.SetInvulnerable()
}


void function OnPilotBecomesTitanThread(entity player,entity titan){
    if(!IsValid(player)){
        return
    }
    if(!player.IsTitan()){
        return
    }
    player.ClearInvulnerable()
    entity soul = player.GetTitanSoul()
    StatusEffect_AddTimed( soul, eStatusEffect.damage_reduction, 1, 5, 0.0 )
}

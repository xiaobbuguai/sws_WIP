global function placeExoPlanetObjects

void function placeExoPlanetObjects()
{
    CreateNessy( <1594, -2307, 493>, <0, 60, 0>, 8 )
    CreateSimpleButton( < -30, -1398, 0 >, <0, 180, 0>, "獲得寵物服主", Callback_ButtonTriggered )

    CreatePhaseTeleporter( < -737.05, -2814.75, -351.969 >, <1453.61, -4251.59, -205.969> )
}

void function Callback_ButtonTriggered( entity button, entity player )
{
    if ( GetNPCArrayByClass( "npc_prowler" ).len() >= 15 )
        return

    entity mover = CreateScriptMover( <147.705, -1467.56, -400> )

    array<entity> prowlers

    for( int x = 0; x < 5; x++ )
    {
        entity prowler = CreateNPC( "npc_prowler", 4, mover.GetOrigin(), <0,0,0>)
        SetSpawnOption_AISettings( prowler, "npc_prowler")
        DispatchSpawn( prowler )
        prowler.SetParent( mover )
        prowlers.append( prowler )
        prowler.SetTitle( "可愛小B,你真的忍心開槍嗎？" )
    }

    mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,0,200>, 0.5, 0.1, 0.1 )

    thread Callback_ButtonTriggeredThreaded( mover, prowlers )
}

void function Callback_ButtonTriggeredThreaded( entity mover, array<entity> prowlers )
{
    wait 1

    foreach( entity prowler in prowlers )
    {
        if ( IsValid( prowler ) )
            prowler.ClearParent()
    }

    if ( IsValid( mover ) )
        mover.Destroy()
}
global function placeBlackWaterObjects

struct {
    entity tower
    bool isdown = true
} file

void function placeBlackWaterObjects()
{
    PrecacheModel( $"models/levels_terrain/mp_black_water_canal/black_water_canal_pipeline_bldg_04_tank_01.mdl" )

    CreateSimpleButton( <664, -164, -55>, <0, 90, 0>, "to control the smoke", callback_ButtonTriggered )
    CreateSimpleButton( <628, -2004, 0>, <0, 90, 0>, "to control the great tower", callback_TowerButtonTriggered )

    CreateNessy( <55, -187, -150>, <0, 90, 0>, 2 )

    file.tower = CreateExpensiveScriptMoverModel( $"models/levels_terrain/mp_black_water_canal/black_water_canal_pipeline_bldg_04_tank_01.mdl", <847, -1458, -1000>, <0,180,0>, SOLID_VPHYSICS, 10000 )
}

void function callback_ButtonTriggered( entity button, entity player )
{
    BringSmoke()
}

void function BringSmoke()
{
    SmokescreenStruct smoke
    smoke.smokescreenFX = $"P_smokescreen_FD"
    smoke.fxXYRadius = 1500
    smoke.fxZRadius = 500
    smoke.origin = <366, -140, 0>
    smoke.angles = <0,0,0>
    smoke.lifetime = 30.0
    smoke.isElectric = false
    smoke.fxOffsets = [ 
        <300, 100, 0>,
        < -300, -100, 0 >,
        <300, 100, 100>, 
        < -300, -100, 100 >,
        < -300, 100, 0 >,
        < 300, -100, 0 >,
        < -300, 100, 100 >,
        < 300, -100, 100 >,
        <0,0,0>,
        <0,0,100>,
        <0,100,100>,
        <0,-100,100>,
        <100,-100,100>,
        <200,-100,100>,
        <100,-100,0>,
        <200,-100,0>,
        < -100,100,100>,
        < -200,100,100>,
        < -100,100,0>,
        < -200,100,0>,
        <100,0,100>,
        <200,0,100>,
        <100,0,0>,
        <200,0,0>,
        < -100,0,100>,
        < -200,0,100>,
        < -100,0,0>,
        < -200,0,0>
    ]
    Smokescreen( smoke )
}

void function callback_TowerButtonTriggered( entity button, entity player )
{
    if ( file.isdown )
        file.tower.NonPhysicsMoveTo( file.tower.GetOrigin() + <0,0,500>, 10, 1, 1 )
    else
        file.tower.NonPhysicsMoveTo( file.tower.GetOrigin() - <0,0,500>, 10, 1, 1 )
}
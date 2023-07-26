global function InitKeyTracking
global function GetPlayerKeysList
global function GetPlayerKey

global const int KJ = 0 // jump
global const int KD = 1 // duck/crouch
global const int KF = 2 // w key
global const int KB = 3 // s key
global const int KL = 4 // a key
global const int KR = 5 // d key
global const int KU = 6 // use
global const int KA = 7 // I think shoot gun
global const int KO0 = 7 // offhand switch
global const int KO1 = 8 // offhand switch
global const int KO2 = 9 // offhand switch
global const int KO3 = 10 // offhand switch
global const int KO4 = 11 // offhand switch
global const int KOQ = 12 // offhand switch

struct
{
    bool initialized = false
    table< entity, array< bool > > keys
}
file

void function InitKeyTracking()
{
    if ( file.initialized )
        return
    file.initialized = true
    
    AddCallback_OnClientConnected( SetupKeyTracking )

    foreach( entity player in GetPlayerArray() )
        SetupKeyTracking( player )
}

void function SetupKeyTracking( entity player )
{
    AddPlayerToKeysList( player )
    
	AddButtonPressedPlayerInputCallback( player, IN_DUCK , PlayerMoveDuck )
	AddButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE , PlayerMoveDuck )
	AddButtonPressedPlayerInputCallback( player, IN_JUMP , PlayerMoveJump )
    AddButtonPressedPlayerInputCallback( player, IN_FORWARD, PlayerMoveFORWARD ) 
    AddButtonPressedPlayerInputCallback( player, IN_BACK, PlayerMoveBACK )
    AddButtonPressedPlayerInputCallback( player, IN_MOVELEFT, PlayerMoveLEFT )
    AddButtonPressedPlayerInputCallback( player, IN_MOVERIGHT, PlayerMoveRIGHT )
	AddButtonPressedPlayerInputCallback( player, IN_USE, PlayerMoveUSE )
    AddButtonPressedPlayerInputCallback( player, IN_USE_AND_RELOAD, PlayerMoveUSE )
    AddButtonPressedPlayerInputCallback( player, IN_ATTACK, PlayerMoveATTACK )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND0, PlayerMoveOFFHAND0 )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerMoveOFFHAND1 )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND2, PlayerMoveOFFHAND2 )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND3, PlayerMoveOFFHAND3 )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND4, PlayerMoveOFFHAND4 )
    AddButtonPressedPlayerInputCallback( player, IN_OFFHAND_QUICK, PlayerMoveOFFHANDQ )


    AddButtonReleasedPlayerInputCallback( player, IN_DUCK , PlayerStopDuck )
	AddButtonReleasedPlayerInputCallback( player, IN_DUCKTOGGLE , PlayerStopDuck )
	AddButtonReleasedPlayerInputCallback( player, IN_JUMP , PlayerStopJump )
    AddButtonReleasedPlayerInputCallback( player, IN_FORWARD, PlayerStopFORWARD ) 
    AddButtonReleasedPlayerInputCallback( player, IN_BACK, PlayerStopBACK )
    AddButtonReleasedPlayerInputCallback( player, IN_MOVELEFT, PlayerStopLEFT ) 
    AddButtonReleasedPlayerInputCallback( player, IN_MOVERIGHT, PlayerStopRIGHT )
	AddButtonReleasedPlayerInputCallback( player, IN_USE, PlayerStopUSE )
    AddButtonReleasedPlayerInputCallback( player, IN_USE_AND_RELOAD, PlayerStopUSE )
    AddButtonReleasedPlayerInputCallback( player, IN_ATTACK, PlayerStopATTACK )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND0, PlayerStopOFFHAND0 )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND1, PlayerStopOFFHAND1 )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND2, PlayerStopOFFHAND2 )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND3, PlayerStopOFFHAND3 )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND4, PlayerStopOFFHAND4 )
    AddButtonReleasedPlayerInputCallback( player, IN_OFFHAND_QUICK, PlayerStopOFFHANDQ )
}

void function AddPlayerToKeysList( entity player )
{
    file.keys[player] <- [ false, false, false, false, false, false, false, false, false, false, false, false, false, false ]
}

array<bool> function GetPlayerKeysList( entity player )
{
    return file.keys[player]
}

bool function GetPlayerKey( entity player, int index )
{
    return file.keys[player][index]
}

void function _AddMovement( entity player, int MovementIndex )
{
    file.keys[player][MovementIndex] = true
} 

void function _RmMovement( entity player, int MovementIndex )
{
    file.keys[player][MovementIndex] = false
}

void function PlayerMoveJump( entity player )
{
    _AddMovement( player, KJ )
}
void function PlayerMoveDuck( entity player )
{
    _AddMovement( player, KD )
}
void function PlayerMoveFORWARD( entity player )
{
    _AddMovement( player, KF )
}
void function PlayerMoveBACK( entity player )
{
    _AddMovement( player, KB )
}
void function PlayerMoveLEFT( entity player )
{
    _AddMovement( player, KL )
}
void function PlayerMoveRIGHT( entity player )
{
    _AddMovement( player, KR )
}
void function PlayerMoveUSE( entity player )
{
    _AddMovement( player, KU )
}
void function PlayerMoveATTACK( entity player )
{
    _AddMovement( player, KA )
}
void function PlayerMoveOFFHAND0( entity player )
{
    _AddMovement( player, KO0 )
}
void function PlayerMoveOFFHAND1( entity player )
{
    _AddMovement( player, KO1 )
}
void function PlayerMoveOFFHAND2( entity player )
{
    _AddMovement( player, KO0 )
}
void function PlayerMoveOFFHAND3( entity player )
{
    _AddMovement( player, KO0 )
}
void function PlayerMoveOFFHAND4( entity player )
{
    _AddMovement( player, KO4 )
}
void function PlayerMoveOFFHANDQ( entity player )
{
    _AddMovement( player, KOQ )
}

// Not Movement

void function PlayerStopJump( entity player )
{
    _RmMovement( player, KJ )
}
void function PlayerStopDuck( entity player )
{
    _RmMovement( player, KD )
}
void function PlayerStopFORWARD( entity player )
{
    _RmMovement( player, KF )
}
void function PlayerStopBACK( entity player )
{
    _RmMovement( player, KB )
}
void function PlayerStopLEFT( entity player )
{
    _RmMovement( player, KL )
}
void function PlayerStopRIGHT( entity player )
{
    _RmMovement( player, KR )
}
void function PlayerStopUSE( entity player )
{
    _RmMovement( player, KU )
}
void function PlayerStopATTACK( entity player )
{
    _RmMovement( player, KA )
}
void function PlayerStopOFFHAND0( entity player )
{
    _RmMovement( player, KO0 )
}
void function PlayerStopOFFHAND1( entity player )
{
    _RmMovement( player, KO1 )
}
void function PlayerStopOFFHAND2( entity player )
{
    _RmMovement( player, KO0 )
}
void function PlayerStopOFFHAND3( entity player )
{
    _RmMovement( player, KO0 )
}
void function PlayerStopOFFHAND4( entity player )
{
    _RmMovement( player, KO4 )
}
void function PlayerStopOFFHANDQ( entity player )
{
    _RmMovement( player, KOQ )
}
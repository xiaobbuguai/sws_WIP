global function RulesInit
global function CommandSendRules
global function CommandRules

bool rulesEnabled = true // true: users can use !rules | false: users cant use !rules
bool adminSendRulesEnabled = true // true: admins can send users the rules | false: admins cant do that
int showRulesTime = 15 // for how many seconds the rules should be displayed when an admin sends them
string rules

void function RulesInit(){
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!rules", CommandRules)
    AddClientCommandCallback("!RULES", CommandRules)
    AddClientCommandCallback("!Rules", CommandRules)

    AddClientCommandCallback("!sendrules", CommandSendRules)
    AddClientCommandCallback("!sendRules", CommandSendRules)
    AddClientCommandCallback("!SENDRULES", CommandSendRules)
    AddClientCommandCallback("!sr", CommandSendRules)

    /*
     *  add rules here
     */

    // string rule99 = "this is your rule"
    //string rule1 = "[1] 如何駕駛飛船:"
    //string rule2 = "[2] 按W加速按S減速,空格著陸和起步"
    //string rule3 = "[3] 按Ctrl可以彈射離開飛船"
    //string rule4 = "[4] 如果您乘坐的是哥布林號飛船,處於炮手位置可以長按瞄準進入自由視角"
    //string rule5 = "[5] 按正常開火鍵方式進行開火"
    //string rule6 = "[6] 輕型飛船使用四聯裝充能激光"
    //string rule7 = "[7] 中型飛船采用一連串導彈攻擊"
    //string rule8 = "[8] 重型飛船有駕駛位和炮手位,并且炮手位置使用smr進行攻擊"
    string rule1 = "[1] 毒蛇觸發按鈕在地圖某地，詳細尋找！"
    string rule2 = "[2] 毒蛇在當前波次敵人沒有清除前，處於無敵狀態。"
    string rule3 = "[3] 你有20%概率成爲叛變者，叛變者有逆天加成"
    string rule4 = "[4] 如果叛變者死亡，當前波束强制結束，如果當前波數敵人全部死亡，叛變者死亡。"
    string rule5 = "[5] 地圖上遍佈了可交互元素，請善用。"
    string rule6 = "[6] 請注意，毒蛇核心發射的導彈是制導的，并且配備了三連發電漿磁軌炮。"
    string rule7 = "[7] 你可以彈射，但是請注意，彈射后立即死亡，叛變者自帶超級核能彈射。"
    string rule8 = "[8] 毒蛇死亡，游戲結束。"
    // add rules to the rule builder
    // dont forget the "\n" to add a new line, also dont put a + after the last rule
    rules = rule1 + "\n" +
            rule2 + "\n" +
            rule3 + "\n" +
            rule4 + "\n" +
            rule5 + "\n" +
            rule6 + "\n" +
            rule7 + "\n" +
            rule8

    /*
     *  end of rules
     */

    // ConVars
    rulesEnabled = GetConVarBool( "pv_rules_enabled" )
    adminSendRulesEnabled = GetConVarBool( "pv_rules_admin_send_enabled" )
    showRulesTime = GetConVarInt( "pv_rules_show_time" )
}

/*
 *  COMMAND LOGIC
 */

bool function CommandSendRules(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER USED SEND RULES")

        // send rules disabled
        if(!adminSendRulesEnabled){
            NSSendInfoMessageToPlayer(player, COMMAND_DISABLED)
            return false
        }

        // Check if user is admin
        if(!IsPlayerAdmin(player)){
            NSSendInfoMessageToPlayer(player, MISSING_PRIVILEGES)
            return false
        }

        // check if theres something after !announce
        if(args.len() < 1){
            NSSendInfoMessageToPlayer(player, NO_PLAYERNAME_FOUND + HOW_TO_SENDRULES)
            return false
        }

        // check if player substring exists n stuff
        // player not on server or substring unspecific
        if(!CanFindPlayerFromSubstring(args[0])){
            NSSendInfoMessageToPlayer(player, CANT_FIND_PLAYER_FROM_SUBSTRING + args[0])
            return false
        }

        // get the full player name based on substring. we can be sure this will work because above we check if it can find exactly one matching name... or at least i hope so
        string fullPlayerName = GetFullPlayerNameFromSubstring(args[0])

        // give admin feedback
        NSSendInfoMessageToPlayer(player, RULES_SENT_TO_PLAYER + fullPlayerName)

        entity target = GetPlayerFromName(fullPlayerName)

        // last minute error handling if player cant be found
        if(target == null){
            NSSendInfoMessageToPlayer( player, PLAYER_IS_NULL )
            return false
        }

        NSSendInfoMessageToPlayer(target, ADMIN_SENT_YOU_RULES + rules)
    }
    return true
}

bool function CommandRules(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER USED RULES")
        if(rulesEnabled)
            SendHudMessageBuilder(player, rules, 200, 200, 255, showRulesTime)
        else
            NSSendInfoMessageToPlayer( player, COMMAND_DISABLED )
    }
    return true
}

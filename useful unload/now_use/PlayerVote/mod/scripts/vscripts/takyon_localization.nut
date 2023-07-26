// Since there cant be localization in a sever sided mod, this will sort of be one
// Here are all the basic strings
// Change these based on your servers language
//由於在一個伺服器端的mod中無法進行當地語系化，所以這將是一個
//以下是所有基本字串
//根據您的服務器語言更改這些 NSSendInfoMessageToPlayer(player, )

// general
global const string ALREADY_VOTED = "您已經投票了"
global const string MISSING_PRIVILEGES = "您缺少權限"
global const string COMMAND_DISABLED = "此命令已禁用"
global const string NO_PLAYERNAME_FOUND = "您沒有給出姓名"
global const string CANT_FIND_PLAYER_FROM_SUBSTRING = "無法匹配一個玩家 " // remember the space at the end

// vote skip
global const string ADMIN_SKIPPED = "系統已跳過"
global const string MULTIPLE_SKIP_VOTES = " 玩家試圖跳過地圖,請按下T鍵輸入!skip來投票" // remember to keep the space in the beginning
global const string ONE_SKIP_VOTE = " 玩家試圖跳過地圖,請按下T鍵輸入!skip來投票" // remember to keep the space in the beginning

// announce
global const string NO_ANNOUNCEMENT_FOUND = "找不到消息通告消息"

// vote kick
global const string CANT_KICK_YOURSELF = "您不能踢自己"
global const string KICKED_PLAYER = "踢 " // remember the space at the end
global const string NOT_ENOUGH_PLAYERS_ONLINE_FOR_KICK = "沒有足够的玩家線上投票"
global const string PLAYER_WANTS_TO_KICK_PLAYER = " 想踢 " // remember to keep the space in the beginning and at the end
global const string HOW_TO_KICK = ",投票類型!yes或!no,聊天中沒有（匿名）"
global const string ALREADY_VOTE_GOING = "已經有活躍的投票支持" // remember the space at the end
global const string NO_VOTE_GOING = "沒有投票,按下T鍵輸入!kick來踢"

// message
global const string HOW_TO_MESSAGE = "\n!msg 通知玩家名稱"
global const string NO_MESSAGE_FOUND = "未找到郵件"
global const string PLAYER_IS_NULL = "出現錯誤,玩家可能已經離開了"
global const string MESSAGE_SENT_TO_PLAYER = "消息發送到 " // remember the space at the end

// help
global const string HELP_MESSAGE = "歡迎來到星願服,按下T鍵輸入!help查看幫助"

// vote extend
global const string ADMIN_EXTENDED = "系統延長遊戲時間"
global const string MAP_CANT_BE_EXTENDED_TWICE = "地圖不能延長遊戲2次"
global const string MULTIPLE_EXTEND_VOTES = " 玩家希望延長此地圖的遊戲時間,按下T鍵輸入!extend來投票" // remember to keep the space in the beginning
global const string ONE_EXTEND_VOTE = " 玩家希望延長此地圖的遊戲時間,按下T鍵輸入!extend來投票" // remember to keep the space in the beginning
global const string MAP_EXTENDED = "地圖已延遲遊戲時間"

// rules
global const string HOW_TO_SENDRULES = "\n!sr 玩家姓名"
global const string RULES_SENT_TO_PLAYER = "規則發送到 " // remember the space at the end
global const string ADMIN_SENT_YOU_RULES = "系統决定您應該閱讀規則\n\n" // two linebreaks to distinguish from rules

// switch
global const string SWITCH_FROM_UNASSIGNED = "您未被分配，囙此選擇了一個隨機隊伍"
global const string SWITCH_TOO_MANY_PLAYERS = "敵隊隊員太多了"
global const string SWITCHED_BY_ADMIN = "您的隊伍已由系統切換"
global const string SWITCHED_TOO_OFTEN = "您切換得太頻繁了。 您可以在下一張地圖上再次切換隊伍"
global const string SWITCH_ADMIN_SUCCESS = " 已切換" // message for admin that player has been switched. remember to keep the space in the beginning
global const string SWITCH_SUCCESS = "您已切換隊伍" // message for player that they have switched

// balance
global const string BALANCED = "隊伍已由K/D平衡"
global const string ONE_BALANCE_VOTE = " 玩家希望通過K/D平衡隊伍,按下T鍵輸入!balance來投票" // remember to keep the space in the beginning
global const string MULTIPLE_BALANCD_VOTES = " 玩家希望通過K/D平衡隊伍,按下T鍵輸入!balance來投票" // remember to keep the space in the beginning
global const string ADMIN_BALANCED = "系統已按K/D平衡隊伍"

// map vote
global const string MAPS_NOT_PROPOSED = "地圖尚未提出"
global const string MAP_VOTE_USAGE = "按下T鍵輸入!vote 地圖數字,投票下一個地圖"//"!vote number -> in chat"
global const string ADMIN_VOTED_MAP = " 系統將下一個地圖設定為"
global const string MAP_NOT_GIVEN = "未給出地圖"
global const string MAP_NUMBER_NOT_FOUND = "未找到地圖編號"
global const string MAP_YOU_VOTED = "您已投票支持 " // remember the space at the end

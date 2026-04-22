local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "SELECT phone_number FROM phone_logged_in_accounts WHERE app = 'DarkChat' AND `active` = 1 AND username = ?"
  if A2_2 then
    L5_2 = " AND phone_number != ?"
    if L5_2 then
      goto lbl_11
    end
  end
  L5_2 = ""
  ::lbl_11::
  L4_2 = L4_2 .. L5_2
  L5_2 = {}
  L6_2 = A0_2
  L7_2 = A2_2
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = 1
  L5_2 = #L3_2
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = SendNotification
    L9_2 = L3_2[L7_2]
    L9_2 = L9_2.phone_number
    L10_2 = A1_2
    L8_2(L9_2, L10_2)
  end
end
L1_1 = BaseCallback
L2_1 = "darkchat:getUsername"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = GetLoggedInAccount
  L3_2 = A1_2
  L4_2 = "DarkChat"
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = MySQL
    L3_2 = L3_2.scalar
    L3_2 = L3_2.await
    L4_2 = "SELECT username FROM phone_darkchat_accounts WHERE phone_number = ? AND `password` IS NULL"
    L5_2 = {}
    L6_2 = A1_2
    L5_2[1] = L6_2
    L3_2 = L3_2(L4_2, L5_2)
    L2_2 = L3_2
    if L2_2 then
      L3_2 = AddLoggedInAccount
      L4_2 = A1_2
      L5_2 = "DarkChat"
      L6_2 = L2_2
      L3_2(L4_2, L5_2, L6_2)
    else
      L3_2 = false
      return L3_2
    end
  end
  L3_2 = MySQL
  L3_2 = L3_2.scalar
  L3_2 = L3_2.await
  L4_2 = "SELECT TRUE FROM phone_darkchat_accounts WHERE username = ? AND `password` IS NOT NULL"
  L5_2 = {}
  L6_2 = L2_2
  L5_2[1] = L6_2
  L3_2 = L3_2(L4_2, L5_2)
  if not L3_2 then
    L4_2 = {}
    L4_2.username = L2_2
    L4_2.password = false
    return L4_2
  end
  L4_2 = {}
  L4_2.username = L2_2
  L4_2.password = true
  return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = BaseCallback
L2_1 = "darkchat:setPassword"
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = #A2_2
  if L3_2 < 3 then
    L3_2 = debugprint
    L4_2 = "DarkChat: password < 3 characters"
    L3_2(L4_2)
    L3_2 = false
    return L3_2
  end
  L3_2 = GetLoggedInAccount
  L4_2 = A1_2
  L5_2 = "DarkChat"
  L3_2 = L3_2(L4_2, L5_2)
  if L3_2 then
    L4_2 = MySQL
    L4_2 = L4_2.scalar
    L4_2 = L4_2.await
    L5_2 = "SELECT TRUE FROM phone_darkchat_accounts WHERE username = ? AND `password` IS NOT NULL"
    L6_2 = {}
    L7_2 = L3_2
    L6_2[1] = L7_2
    L4_2 = L4_2(L5_2, L6_2)
    if not L4_2 then
      goto lbl_28
    end
  end
  L4_2 = false
  do return L4_2 end
  ::lbl_28::
  L4_2 = GetPasswordHash
  L5_2 = A2_2
  L4_2 = L4_2(L5_2)
  L5_2 = MySQL
  L5_2 = L5_2.update
  L5_2 = L5_2.await
  L6_2 = "UPDATE phone_darkchat_accounts SET `password` = ? WHERE username = ?"
  L7_2 = {}
  L8_2 = L4_2
  L9_2 = L3_2
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L5_2(L6_2, L7_2)
  L5_2 = true
  return L5_2
end
L1_1(L2_1, L3_1)
L1_1 = BaseCallback
L2_1 = "darkchat:login"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT `password` FROM phone_darkchat_accounts WHERE username = ?"
  L6_2 = {}
  L7_2 = A2_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L5_2 = {}
    L5_2.success = false
    L5_2.reason = "invalid_username"
    return L5_2
  else
    L5_2 = VerifyPasswordHash
    L6_2 = A3_2
    L7_2 = L4_2
    L5_2 = L5_2(L6_2, L7_2)
    if not L5_2 then
      L5_2 = {}
      L5_2.success = false
      L5_2.reason = "incorrect_password"
      return L5_2
    end
  end
  L5_2 = AddLoggedInAccount
  L6_2 = A1_2
  L7_2 = "DarkChat"
  L8_2 = A2_2
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = {}
  L5_2.success = true
  return L5_2
end
L1_1(L2_1, L3_1)
L1_1 = BaseCallback
L2_1 = "darkchat:register"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L5_2 = A2_2
  L4_2 = A2_2.lower
  L4_2 = L4_2(L5_2)
  A2_2 = L4_2
  L4_2 = IsUsernameValid
  L5_2 = A2_2
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L4_2 = {}
    L4_2.success = false
    L4_2.reason = "USERNAME_NOT_ALLOWED"
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT 1 FROM phone_darkchat_accounts WHERE username = ?"
  L6_2 = {}
  L7_2 = A2_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 then
    L4_2 = {}
    L4_2.success = false
    L4_2.reason = "username_taken"
    return L4_2
  end
  L4_2 = GetPasswordHash
  L5_2 = A3_2
  L4_2 = L4_2(L5_2)
  L5_2 = MySQL
  L5_2 = L5_2.update
  L5_2 = L5_2.await
  L6_2 = "INSERT INTO phone_darkchat_accounts (phone_number, username, `password`) VALUES (?, ?, ?)"
  L7_2 = {}
  L8_2 = A1_2
  L9_2 = A2_2
  L10_2 = L4_2
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L7_2[3] = L10_2
  L5_2 = L5_2(L6_2, L7_2)
  L5_2 = L5_2 > 0
  if not L5_2 then
    L6_2 = {}
    L6_2.success = false
    L6_2.reason = "unknown"
    return L6_2
  end
  L6_2 = AddLoggedInAccount
  L7_2 = A1_2
  L8_2 = "DarkChat"
  L9_2 = A2_2
  L6_2(L7_2, L8_2, L9_2)
  L6_2 = {}
  L6_2.success = true
  return L6_2
end
L1_1(L2_1, L3_1)
function L1_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = BaseCallback
  L4_2 = "darkchat:"
  L5_2 = A0_2
  L4_2 = L4_2 .. L5_2
  function L5_2(A0_3, A1_3, ...)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    L2_3 = GetLoggedInAccount
    L3_3 = A1_3
    L4_3 = "DarkChat"
    L2_3 = L2_3(L3_3, L4_3)
    if not L2_3 then
      L3_3 = A2_2
      return L3_3
    end
    L3_3 = A1_2
    L4_3 = A0_3
    L5_3 = A1_3
    L6_3 = L2_3
    L7_3 = ...
    return L3_3(L4_3, L5_3, L6_3, L7_3)
  end
  L6_2 = A2_2
  L3_2(L4_2, L5_2, L6_2)
end
L2_1 = L1_1
L3_1 = "changePassword"
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L5_2 = Config
  L5_2 = L5_2.ChangePassword
  L5_2 = L5_2.DarkChat
  if not L5_2 then
    L5_2 = infoprint
    L6_2 = "warning"
    L7_2 = "%s tried to change password on DarkChat, but it's not enabled in the config."
    L8_2 = L7_2
    L7_2 = L7_2.format
    L9_2 = A0_2
    L7_2, L8_2, L9_2, L10_2, L11_2 = L7_2(L8_2, L9_2)
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
    L5_2 = false
    return L5_2
  end
  if A3_2 ~= A4_2 then
    L5_2 = #A4_2
    if not (L5_2 < 3) then
      goto lbl_25
    end
  end
  L5_2 = debugprint
  L6_2 = "same password / too short"
  L5_2(L6_2)
  L5_2 = false
  do return L5_2 end
  ::lbl_25::
  L5_2 = MySQL
  L5_2 = L5_2.scalar
  L5_2 = L5_2.await
  L6_2 = "SELECT `password` FROM phone_darkchat_accounts WHERE username = ?"
  L7_2 = {}
  L8_2 = A2_2
  L7_2[1] = L8_2
  L5_2 = L5_2(L6_2, L7_2)
  if L5_2 then
    L6_2 = VerifyPasswordHash
    L7_2 = A3_2
    L8_2 = L5_2
    L6_2 = L6_2(L7_2, L8_2)
    if L6_2 then
      goto lbl_44
    end
  end
  L6_2 = false
  do return L6_2 end
  ::lbl_44::
  L6_2 = MySQL
  L6_2 = L6_2.update
  L6_2 = L6_2.await
  L7_2 = "UPDATE phone_darkchat_accounts SET `password` = ? WHERE username = ?"
  L8_2 = {}
  L9_2 = GetPasswordHash
  L10_2 = A4_2
  L9_2 = L9_2(L10_2)
  L10_2 = A2_2
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L6_2 = L6_2(L7_2, L8_2)
  L6_2 = L6_2 > 0
  if not L6_2 then
    L7_2 = false
    return L7_2
  end
  L7_2 = L0_1
  L8_2 = A2_2
  L9_2 = {}
  L10_2 = L
  L11_2 = "BACKEND.MISC.LOGGED_OUT_PASSWORD.TITLE"
  L10_2 = L10_2(L11_2)
  L9_2.title = L10_2
  L10_2 = L
  L11_2 = "BACKEND.MISC.LOGGED_OUT_PASSWORD.DESCRIPTION"
  L10_2 = L10_2(L11_2)
  L9_2.content = L10_2
  L10_2 = A1_2
  L7_2(L8_2, L9_2, L10_2)
  L7_2 = MySQL
  L7_2 = L7_2.update
  L7_2 = L7_2.await
  L8_2 = "DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'DarkChat' AND phone_number != ?"
  L9_2 = {}
  L10_2 = A2_2
  L11_2 = A1_2
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L7_2(L8_2, L9_2)
  L7_2 = ClearActiveAccountsCache
  L8_2 = "DarkChat"
  L9_2 = A2_2
  L10_2 = A1_2
  L7_2(L8_2, L9_2, L10_2)
  L7_2 = TriggerClientEvent
  L8_2 = "phone:logoutFromApp"
  L9_2 = -1
  L10_2 = {}
  L10_2.username = A2_2
  L10_2.app = "darkchat"
  L10_2.reason = "password"
  L10_2.number = A1_2
  L7_2(L8_2, L9_2, L10_2)
  L7_2 = true
  return L7_2
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "deleteAccount"
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L4_2 = Config
  L4_2 = L4_2.DeleteAccount
  L4_2 = L4_2.DarkChat
  if not L4_2 then
    L4_2 = infoprint
    L5_2 = "warning"
    L6_2 = "%s tried to delete their account on DarkChat, but it's not enabled in the config."
    L7_2 = L6_2
    L6_2 = L6_2.format
    L8_2 = A0_2
    L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2, L8_2)
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
    L4_2 = false
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT `password` FROM phone_darkchat_accounts WHERE username = ?"
  L6_2 = {}
  L7_2 = A2_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 then
    L5_2 = VerifyPasswordHash
    L6_2 = A3_2
    L7_2 = L4_2
    L5_2 = L5_2(L6_2, L7_2)
    if L5_2 then
      goto lbl_34
    end
  end
  L5_2 = false
  do return L5_2 end
  ::lbl_34::
  L5_2 = L0_1
  L6_2 = A2_2
  L7_2 = {}
  L8_2 = L
  L9_2 = "BACKEND.MISC.DELETED_NOTIFICATION.TITLE"
  L8_2 = L8_2(L9_2)
  L7_2.title = L8_2
  L8_2 = L
  L9_2 = "BACKEND.MISC.DELETED_NOTIFICATION.DESCRIPTION"
  L8_2 = L8_2(L9_2)
  L7_2.content = L8_2
  L5_2(L6_2, L7_2)
  L5_2 = MySQL
  L5_2 = L5_2.update
  L5_2 = L5_2.await
  L6_2 = "DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'DarkChat'"
  L7_2 = {}
  L8_2 = A2_2
  L7_2[1] = L8_2
  L5_2(L6_2, L7_2)
  L5_2 = ClearActiveAccountsCache
  L6_2 = "DarkChat"
  L7_2 = A2_2
  L5_2(L6_2, L7_2)
  L5_2 = TriggerClientEvent
  L6_2 = "phone:logoutFromApp"
  L7_2 = -1
  L8_2 = {}
  L8_2.username = A2_2
  L8_2.app = "darkchat"
  L8_2.reason = "deleted"
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = true
  return L5_2
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "logout"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = RemoveLoggedInAccount
  L4_2 = A1_2
  L5_2 = "DarkChat"
  L6_2 = A2_2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = true
  return L3_2
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "joinChannel"
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT TRUE FROM phone_darkchat_members WHERE channel_name = ? AND username = ?"
  L6_2 = {}
  L7_2 = A3_2
  L8_2 = A2_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 then
    L4_2 = debugprint
    L5_2 = "darkchat: already in channel"
    L4_2(L5_2)
    L4_2 = false
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT TRUE FROM phone_darkchat_channels WHERE `name` = ?"
  L6_2 = {}
  L7_2 = A3_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L5_2 = MySQL
    L5_2 = L5_2.update
    L5_2 = L5_2.await
    L6_2 = "INSERT INTO phone_darkchat_channels (`name`) VALUES (?)"
    L7_2 = {}
    L8_2 = A3_2
    L7_2[1] = L8_2
    L5_2(L6_2, L7_2)
    L5_2 = Log
    L6_2 = "DarkChat"
    L7_2 = A0_2
    L8_2 = "info"
    L9_2 = L
    L10_2 = "BACKEND.LOGS.DARKCHAT_CREATED_TITLE"
    L9_2 = L9_2(L10_2)
    L10_2 = L
    L11_2 = "BACKEND.LOGS.DARKCHAT_CREATED_DESCRIPTION"
    L12_2 = {}
    L12_2.creator = A2_2
    L12_2.channel = A3_2
    L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2, L12_2)
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  end
  L5_2 = MySQL
  L5_2 = L5_2.update
  L5_2 = L5_2.await
  L6_2 = "INSERT INTO phone_darkchat_members (channel_name, username) VALUES (?, ?)"
  L7_2 = {}
  L8_2 = A3_2
  L9_2 = A2_2
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L5_2 = L5_2(L6_2, L7_2)
  L5_2 = L5_2 > 0
  if not L5_2 then
    L6_2 = debugprint
    L7_2 = "darkchat: failed to insert into members"
    L6_2(L7_2)
    L6_2 = false
    return L6_2
  end
  if not L4_2 then
    L6_2 = {}
    L6_2.name = A3_2
    L6_2.members = 1
    return L6_2
  end
  L6_2 = MySQL
  L6_2 = L6_2.single
  L6_2 = L6_2.await
  L7_2 = [[
        SELECT `name`, (SELECT COUNT(username) FROM phone_darkchat_members WHERE channel_name = `name`) AS members
        FROM phone_darkchat_channels c
        WHERE `name` = ?
    ]]
  L8_2 = {}
  L9_2 = A3_2
  L8_2[1] = L9_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = MySQL
  L7_2 = L7_2.single
  L7_2 = L7_2.await
  L8_2 = [[
        SELECT sender, content, `timestamp`
        FROM phone_darkchat_messages
        WHERE `channel` = ?
        ORDER BY `timestamp` DESC
        LIMIT 1
    ]]
  L9_2 = {}
  L10_2 = A3_2
  L9_2[1] = L10_2
  L7_2 = L7_2(L8_2, L9_2)
  if L7_2 then
    L8_2 = L7_2.sender
    L6_2.sender = L8_2
    L8_2 = L7_2.content
    L6_2.lastMessage = L8_2
    L8_2 = L7_2.timestamp
    L6_2.timestamp = L8_2
  end
  L8_2 = TriggerClientEvent
  L9_2 = "phone:darkChat:updateChannel"
  L10_2 = -1
  L11_2 = A3_2
  L12_2 = A2_2
  L13_2 = "joined"
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
  return L6_2
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "leaveChannel"
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L4_2 = MySQL
  L4_2 = L4_2.update
  L4_2 = L4_2.await
  L5_2 = "DELETE FROM phone_darkchat_members WHERE channel_name = ? AND username = ?"
  L6_2 = {}
  L7_2 = A3_2
  L8_2 = A2_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = TriggerClientEvent
  L6_2 = "phone:darkChat:updateChannel"
  L7_2 = -1
  L8_2 = A3_2
  L9_2 = A2_2
  L10_2 = "left"
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
  L5_2 = true
  return L5_2
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "getChannels"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = [[
        SELECT
            `name`,
            (SELECT COUNT(username) FROM phone_darkchat_members WHERE channel_name = `name`) AS members,
            m.sender AS sender,
            m.content AS lastMessage,
            m.`timestamp` AS `timestamp`
        FROM phone_darkchat_channels c
        LEFT JOIN phone_darkchat_messages m ON m.`channel` = c.name
        WHERE EXISTS (SELECT TRUE FROM phone_darkchat_members WHERE channel_name = c.name AND username = ?)
        AND COALESCE(m.`timestamp`, '1970-01-01 00:00:00') = (
            SELECT COALESCE(MAX(`timestamp`), '1970-01-01 00:00:00') FROM phone_darkchat_messages WHERE `channel` = c.`name`
        )
    ]]
  L5_2 = {}
  L6_2 = A2_2
  L5_2[1] = L6_2
  return L3_2(L4_2, L5_2)
end
L5_1 = {}
L2_1(L3_1, L4_1, L5_1)
L2_1 = L1_1
L3_1 = "getMessages"
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L5_2 = MySQL
  L5_2 = L5_2.query
  L5_2 = L5_2.await
  L6_2 = [[
        SELECT sender, content, `timestamp`
        FROM phone_darkchat_messages
        WHERE `channel` = ?

        ORDER BY `timestamp` DESC
        LIMIT ?, ?
    ]]
  L7_2 = {}
  L8_2 = A3_2
  L9_2 = A4_2 * 15
  L10_2 = 15
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L7_2[3] = L10_2
  return L5_2(L6_2, L7_2)
end
L2_1(L3_1, L4_1)
function L2_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = MySQL
  L3_2 = L3_2.insert
  L3_2 = L3_2.await
  L4_2 = "INSERT INTO phone_darkchat_messages (sender, `channel`, content) VALUES (?, ?, ?)"
  L5_2 = {}
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = A2_2
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L5_2[3] = L8_2
  L3_2 = L3_2(L4_2, L5_2)
  if not L3_2 then
    L4_2 = false
    return L4_2
  end
  L4_2 = NotifyPhones
  L5_2 = [[
        phone_darkchat_members m
        JOIN phone_logged_in_accounts l
            ON l.app = 'DarkChat'
            AND l.`active` = 1
            AND l.username = m.username
        WHERE
            m.channel_name = @channel
            AND m.username != @username
    ]]
  L6_2 = {}
  L6_2.app = "DarkChat"
  L6_2.title = A1_2
  L7_2 = A0_2
  L8_2 = ": "
  L9_2 = A2_2
  L7_2 = L7_2 .. L8_2 .. L9_2
  L6_2.content = L7_2
  L7_2 = "l."
  L8_2 = {}
  L8_2["@channel"] = A1_2
  L8_2["@username"] = A0_2
  L4_2(L5_2, L6_2, L7_2, L8_2)
  L4_2 = TriggerClientEvent
  L5_2 = "phone:darkChat:newMessage"
  L6_2 = -1
  L7_2 = A1_2
  L8_2 = A0_2
  L9_2 = A2_2
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  L4_2 = true
  return L4_2
end
L3_1 = L1_1
L4_1 = "sendMessage"
function L5_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L5_2 = ContainsBlacklistedWord
  L6_2 = A0_2
  L7_2 = "DarkChat"
  L8_2 = A4_2
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  if L5_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = L2_1
  L6_2 = A2_2
  L7_2 = A3_2
  L8_2 = A4_2
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  if not L5_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = Log
  L6_2 = "DarkChat"
  L7_2 = A0_2
  L8_2 = "info"
  L9_2 = L
  L10_2 = "BACKEND.LOGS.DARKCHAT_MESSAGE_TITLE"
  L9_2 = L9_2(L10_2)
  L10_2 = L
  L11_2 = "BACKEND.LOGS.DARKCHAT_MESSAGE_DESCRIPTION"
  L12_2 = {}
  L12_2.sender = A2_2
  L12_2.channel = A3_2
  L12_2.message = A4_2
  L10_2, L11_2, L12_2 = L10_2(L11_2, L12_2)
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L5_2 = true
  return L5_2
end
L3_1(L4_1, L5_1)
L3_1 = exports
L4_1 = "SendDarkChatMessage"
function L5_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2
  L4_2 = assert
  L5_2 = type
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L5_2 = "string" == L5_2
  L6_2 = "username must be a string"
  L4_2(L5_2, L6_2)
  L4_2 = assert
  L5_2 = type
  L6_2 = A1_2
  L5_2 = L5_2(L6_2)
  L5_2 = "string" == L5_2
  L6_2 = "channel must be a string"
  L4_2(L5_2, L6_2)
  L4_2 = assert
  L5_2 = type
  L6_2 = A2_2
  L5_2 = L5_2(L6_2)
  L5_2 = "string" == L5_2
  L6_2 = "message must be a string"
  L4_2(L5_2, L6_2)
  L4_2 = L2_1
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = A2_2
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  if A3_2 then
    L5_2 = A3_2
    L6_2 = L4_2
    L5_2(L6_2)
  end
  return L4_2
end
L3_1(L4_1, L5_1)
L3_1 = exports
L4_1 = "SendDarkChatLocation"
function L5_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = assert
  L5_2 = type
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L5_2 = "string" == L5_2
  L6_2 = "Expected string for argument 1, got "
  L7_2 = type
  L8_2 = A0_2
  L7_2 = L7_2(L8_2)
  L6_2 = L6_2 .. L7_2
  L4_2(L5_2, L6_2)
  L4_2 = assert
  L5_2 = type
  L6_2 = A1_2
  L5_2 = L5_2(L6_2)
  L5_2 = "string" == L5_2
  L6_2 = "Expected string for argument 2, got "
  L7_2 = type
  L8_2 = A1_2
  L7_2 = L7_2(L8_2)
  L6_2 = L6_2 .. L7_2
  L4_2(L5_2, L6_2)
  L4_2 = assert
  L5_2 = type
  L6_2 = A2_2
  L5_2 = L5_2(L6_2)
  L5_2 = "vector2" == L5_2
  L6_2 = "Expected vector2 for argument 3, got "
  L7_2 = type
  L8_2 = A2_2
  L7_2 = L7_2(L8_2)
  L6_2 = L6_2 .. L7_2
  L4_2(L5_2, L6_2)
  L4_2 = L2_1
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = "<!SENT-LOCATION-X="
  L8_2 = A2_2.x
  L9_2 = "Y="
  L10_2 = A2_2.y
  L11_2 = "!>"
  L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  if A3_2 then
    L5_2 = A3_2
    L6_2 = L4_2
    L5_2(L6_2)
  end
  return L4_2
end
L3_1(L4_1, L5_1)

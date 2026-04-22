-- Discord Webhook Configuration
Config.Webhooks = {
    enabled = true, -- Master switch for all webhook logging

    webhooks = {
        accountCreated = "", -- When a new account is created
        deposit = "", -- Cash deposits to bank
        withdraw = "", -- Withdrawals from bank
        transfer = "", -- Money transfers between players
        pinChanged = "", -- PIN changes
        cardReissued = "", -- Card re-issues
        upgradePurchased = "", -- Withdrawal/Account level upgrades
        societyDeposit = "", -- Society account deposits
        societyWithdraw = "", -- Society account withdrawals
        societyTransfer = "", -- Society account transfers
        atmTransaction = "", -- ATM transactions
        interestPaid = "", -- Interest payments
        taxCollected = "", -- Tax collections
        nomineeAdded = "", -- Nominee added to account
        nomineeRemoved = "", -- Nominee removed from account
    },

    -- Webhook settings
    settings = {
        botName = "Prism Banking", -- Bot name displayed in Discord
        color = 3066993, -- Embed color (default: green)
        footerText = "Prism Banking System",
        footerIcon = "https://r2.fivemanage.com/r6wwJsF4TfNZ183RO1l2g/Group1317.png", -- Footer icon URL
        thumbnailUrl = "https://r2.fivemanage.com/r6wwJsF4TfNZ183RO1l2g/Group1317.png", -- Thumbnail URL
        includeServerName = true, -- Include server name in footer
        includeTimestamp = true, -- Include timestamp in embeds
    }
}

local function IsWebhookEnabled(webhookType)
    if not Config.Webhooks.enabled then return false end
    if not Config.Webhooks.webhooks[webhookType] then return false end
    if Config.Webhooks.webhooks[webhookType] == "" then return false end
    return true
end


local function GetPlayerName(source)
    local Player = GetPlayer(source)
    if not Player then return "Unknown" end

    if Config.Framework == 'esx' then
        return Player.getName()
    else
        return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    end
end


local function GetPlayerIdentifier(source)
    local Player = GetPlayer(source)
    if not Player then return "Unknown" end

    if Config.Framework == 'esx' then
        return Player.identifier
    else
        return Player.PlayerData.citizenid
    end
end

local function SendWebhook(webhookType, embedData)
    if not IsWebhookEnabled(webhookType) then return end

    local webhook = Config.Webhooks.webhooks[webhookType]
    local settings = Config.Webhooks.settings

    -- Build the embed
    local embed = {
        {
            ["title"] = embedData.title or "Banking Action",
            ["description"] = embedData.description or "",
            ["color"] = embedData.color or settings.color,
            ["fields"] = embedData.fields or {},
            ["footer"] = {
                ["text"] = settings.includeServerName and (settings.footerText .. " | " .. GetConvar("sv_projectName", "FiveM Server")) or settings.footerText,
                ["icon_url"] = settings.footerIcon
            },
            ["thumbnail"] = {
                ["url"] = embedData.thumbnail or settings.thumbnailUrl
            },
            ["timestamp"] = settings.includeTimestamp and os.date("!%Y-%m-%dT%H:%M:%SZ") or nil
        }
    }

    -- Send the webhook
    PerformHttpRequest(webhook, function(err, text, headers)
        if err ~= 200 and err ~= 204 then
            print("^1[Prism Banking - Webhook Error]^0 Failed to send webhook. Error code: " .. tostring(err))
        end
    end, 'POST', json.encode({
        username = settings.botName,
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

function LogAccountCreated(source, accountNumber, cardType, balance)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("accountCreated", {
        title = "💳 New Account Created",
        description = "A new bank account has been created",
        color = 3066993, -- Green
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Card Type",
                ["value"] = cardType,
                ["inline"] = true
            },
            {
                ["name"] = "Starting Balance",
                ["value"] = "$" .. tostring(balance),
                ["inline"] = true
            }
        }
    })
end

-- Log deposits
function LogDeposit(source, accountNumber, amount, newBalance, oldBalance)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("deposit", {
        title = "💵 Cash Deposit",
        description = "Cash deposited to bank account",
        color = 5763719, -- Blue
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Amount Deposited",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Previous Balance",
                ["value"] = "$" .. tostring(oldBalance),
                ["inline"] = true
            },
            {
                ["name"] = "New Balance",
                ["value"] = "$" .. tostring(newBalance),
                ["inline"] = true
            }
        }
    })
end

-- Log withdrawals
function LogWithdraw(source, accountNumber, amount, newBalance, oldBalance)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("withdraw", {
        title = "💸 Cash Withdrawal",
        description = "Cash withdrawn from bank account",
        color = 15105570, -- Orange
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Amount Withdrawn",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Previous Balance",
                ["value"] = "$" .. tostring(oldBalance),
                ["inline"] = true
            },
            {
                ["name"] = "New Balance",
                ["value"] = "$" .. tostring(newBalance),
                ["inline"] = true
            }
        }
    })
end

function LogTransfer(sourcePlayer, targetPlayer, senderAccount, receiverAccount, amount, senderNewBalance, receiverNewBalance)
    local senderName = GetPlayerName(sourcePlayer)
    local senderIdentifier = GetPlayerIdentifier(sourcePlayer)
    local receiverName = GetPlayerName(targetPlayer)
    local receiverIdentifier = GetPlayerIdentifier(targetPlayer)

    SendWebhook("transfer", {
        title = "💱 Money Transfer",
        description = "Money transferred between accounts",
        color = 10181046, -- Purple
        fields = {
            {
                ["name"] = "Sender",
                ["value"] = senderName .. " (ID: " .. sourcePlayer .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Sender Identifier",
                ["value"] = "`" .. senderIdentifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Sender Account",
                ["value"] = "`" .. senderAccount .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Receiver",
                ["value"] = receiverName .. " (ID: " .. targetPlayer .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Receiver Identifier",
                ["value"] = "`" .. receiverIdentifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Receiver Account",
                ["value"] = "`" .. receiverAccount .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Amount Transferred",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Sender New Balance",
                ["value"] = "$" .. tostring(senderNewBalance),
                ["inline"] = true
            },
            {
                ["name"] = "Receiver New Balance",
                ["value"] = "$" .. tostring(receiverNewBalance),
                ["inline"] = true
            }
        }
    })
end

function LogPinChanged(source, accountNumber)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("pinChanged", {
        title = "🔐 PIN Changed",
        description = "Account PIN has been changed",
        color = 3447003, -- Dark Blue
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            }
        }
    })
end


function LogCardReissued(source, oldAccountNumber, newAccountNumber, cost)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("cardReissued", {
        title = "🆕 Card Reissued",
        description = "A new card has been issued",
        color = 11027200, -- Gold
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Old Account Number",
                ["value"] = "`" .. oldAccountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "New Account Number",
                ["value"] = "`" .. newAccountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Cost",
                ["value"] = "$" .. tostring(cost),
                ["inline"] = true
            }
        }
    })
end


function LogUpgradePurchased(source, upgradeType, level, cost)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("upgradePurchased", {
        title = "⬆️ Upgrade Purchased",
        description = "Player purchased an account upgrade",
        color = 3066993, -- Green
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Upgrade Type",
                ["value"] = upgradeType,
                ["inline"] = true
            },
            {
                ["name"] = "New Level",
                ["value"] = tostring(level),
                ["inline"] = true
            },
            {
                ["name"] = "Cost",
                ["value"] = "$" .. tostring(cost),
                ["inline"] = true
            }
        }
    })
end

function LogSocietyDeposit(source, societyName, accountNumber, amount, newBalance, oldBalance)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("societyDeposit", {
        title = "🏢 Society Deposit",
        description = "Cash deposited to society account",
        color = 5763719, -- Blue
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Society",
                ["value"] = societyName,
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Amount Deposited",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Previous Balance",
                ["value"] = "$" .. tostring(oldBalance),
                ["inline"] = true
            },
            {
                ["name"] = "New Balance",
                ["value"] = "$" .. tostring(newBalance),
                ["inline"] = true
            }
        }
    })
end

function LogSocietyWithdraw(source, societyName, accountNumber, amount, newBalance, oldBalance)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("societyWithdraw", {
        title = "🏢 Society Withdrawal",
        description = "Cash withdrawn from society account",
        color = 15105570, -- Orange
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Society",
                ["value"] = societyName,
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Amount Withdrawn",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Previous Balance",
                ["value"] = "$" .. tostring(oldBalance),
                ["inline"] = true
            },
            {
                ["name"] = "New Balance",
                ["value"] = "$" .. tostring(newBalance),
                ["inline"] = true
            }
        }
    })
end


function LogInterestPaid(accountNumber, identifier, amount, newBalance, interestRate)
    SendWebhook("interestPaid", {
        title = "💰 Interest Paid",
        description = "Interest credited to account",
        color = 3066993, -- Green
        fields = {
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Interest Amount",
                ["value"] = "$" .. tostring(amount),
                ["inline"] = true
            },
            {
                ["name"] = "Interest Rate",
                ["value"] = tostring(interestRate) .. "%",
                ["inline"] = true
            },
            {
                ["name"] = "New Balance",
                ["value"] = "$" .. tostring(newBalance),
                ["inline"] = true
            }
        }
    })
end

function LogTaxCollected(source, accountNumber, taxAmount, transactionAmount, taxRate, transactionType)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("taxCollected", {
        title = "📊 Tax Collected",
        description = "Tax deducted from transaction",
        color = 15844367, -- Pink
        fields = {
            {
                ["name"] = "Player",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Transaction Type",
                ["value"] = transactionType,
                ["inline"] = true
            },
            {
                ["name"] = "Transaction Amount",
                ["value"] = "$" .. tostring(transactionAmount),
                ["inline"] = true
            },
            {
                ["name"] = "Tax Rate",
                ["value"] = tostring(taxRate) .. "%",
                ["inline"] = true
            },
            {
                ["name"] = "Tax Amount",
                ["value"] = "$" .. tostring(taxAmount),
                ["inline"] = true
            }
        }
    })
end

-- Log nominee added
function LogNomineeAdded(source, accountNumber, targetServerId, nomineeName)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)
    local targetIdentifier = GetPlayerIdentifier(targetServerId)

    SendWebhook("nomineeAdded", {
        title = "👥 Nominee Added",
        description = "A nominee has been added to an account",
        color = 3066993, -- Green
        fields = {
            {
                ["name"] = "Account Owner",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Owner Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Nominee",
                ["value"] = nomineeName .. " (ID: " .. targetServerId .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Nominee Identifier",
                ["value"] = "`" .. targetIdentifier .. "`",
                ["inline"] = true
            }
        }
    })
end

-- Log nominee removed
function LogNomineeRemoved(source, accountNumber, nomineeIdentifier)
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)

    SendWebhook("nomineeRemoved", {
        title = "👥 Nominee Removed",
        description = "A nominee has been removed from an account",
        color = 15158332, -- Red
        fields = {
            {
                ["name"] = "Account Owner",
                ["value"] = playerName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Owner Identifier",
                ["value"] = "`" .. identifier .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Account Number",
                ["value"] = "`" .. accountNumber .. "`",
                ["inline"] = true
            },
            {
                ["name"] = "Removed Nominee Identifier",
                ["value"] = "`" .. nomineeIdentifier .. "`",
                ["inline"] = true
            }
        }
    })
end

print("^2[Prism Banking]^0 Webhook logging system loaded. Status: " .. (Config.Webhooks.enabled and "^2ENABLED^0" or "^3DISABLED^0"))
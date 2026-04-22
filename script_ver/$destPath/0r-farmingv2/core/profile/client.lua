local profileData = {
    level = 0,
    exp = 0,
    nextLevelExp = 0,
    name = nil,
    source = -1,
}

Profile = {}

function Profile.get()
    return profileData
end

function Profile.fetch()
    local profile = lib.callback.await(_e("server:profile:get"), false)
    if not profile then
        return false
    end
    profileData = profile
    return profileData
end

function Profile.updateUI()
    client.sendReactMessage("ui:setUserProfile", profileData)
end

RegisterNetEvent(_e("client:profile:onUpdate"), function(profile)
    profileData.exp = profile.exp
    profileData.level = profile.level
    profileData.nextLevelExp = profile.nextLevelExp
    client.sendReactMessage("ui:setUserProfile", profileData)
end)

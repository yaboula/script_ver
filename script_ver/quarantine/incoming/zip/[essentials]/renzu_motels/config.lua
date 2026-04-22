config = {}
config.wardrobe = 'qb-clothing' -- choose your skin menu
config.target = false -- false = markers zones type. true = ox_target, qb-target
config.business = true -- allowed players to purchase the motel
config.autokickIfExpire = false -- auto kick occupants if rent is due. if false owner of motel must kick the occupants
config.breakinJobs = { -- jobs can break in to door using gunfire in doors
	['police'] = true,
	['sheriff'] = true,
}
config.wardrobes = { -- skin menus
	['renzu_clothes'] = function()
		exports.renzu_clothes:OpenClotheInventory()
	end,
	['fivem-appearance'] = function()
		return exports['fivem-appearance']:startPlayerCustomization()
	end,
	['illenium-appearance'] = function()
		return TriggerEvent('illenium-appearance:client:openOutfitMenu')
	end,
	['qb-clothing'] = function()
		return TriggerEvent('qb-clothing:client:openOutfitMenu')
	end,
	['esx_skin'] = function()
		TriggerEvent('esx_skin:openSaveableMenu')
	end,
}

-- Shells Offsets and model name
config.shells = {
	['standard'] = {
		shell = `standardmotel_shell`, -- kambi shell
		offsets = {
			exit = vec3(-0.43,-2.51,1.16),
			stash = vec3(1.368164, -3.134506, 1.16),
			wardrobe = vec3(1.643646, 2.551102, 1.16),
		}
	},
	['modern'] = {
		shell = `modernhotel_shell`, -- kambi shell
		offsets = {
			exit = vec3(5.410095, 4.299301, 0.9),
			stash = vec3(-4.068207, 4.046188, 0.9),
			wardrobe = vec3(2.811829, -3.619385, 0.9),
		}
	},
}

config.messageApi = function(data) -- {title,message,motel}
	local motel = GlobalState.Motels[data.motel]
	local identifier = motel.owned -- owner identifier
	-- add your custom message here. ex. SMS phone 

	-- basic notification (remove this if using your own message system)
	local success = lib.callback.await('renzu_motels:MessageOwner',false,{identifier = identifier, message = data.message, title = data.title, motel = data.motel})
	if success then
		Notify('message has been sent', 'success')
	else
		Notify('message fail  \n  owner is not available yet', 'error')
	end
end

-- @shell string (shell type)
-- @Mlo string ( toggle MLO or shell type)
-- @hour_rate int ( per hour rates)
-- @motel string (Motel Index Name)
-- @rentcoord vec3 (coordinates of Rental Menu)
-- @radius float ( total size radius of motel )
-- @maxoccupants int (total player can rent in each Rooms)
-- @uniquestash bool ( Toggle Non Sharable / Stealable Stash Storage )
-- @doors table ( lists of doors feature coordinates. ex. stash, wardrobe) wardrobe,stash coords are only applicable in Mlo. using shells has offsets for stash and wardrobes.
-- @manual boolean ( accept walk in occupants only )
-- @businessprice int ( value of motel)
-- @door int (door hash or doormodel `model`) for MLO type

config.motels = {
	[1] = { -- index name of motel
		manual = false,
		Mlo = false,
		shell = 'standard',
		label = 'Pink Cage Motel',
		rental_period = 'day',
		rate = 1000,
		businessprice = 1000000,
		motel = 'pinkcage',
		payment = 'money',
		door = `gabz_pinkcage_doors_front`,
		rentcoord = vec3(313.38,-225.20,54.212),
		coord = vec3(326.04,-210.47,54.086),
		radius = 50.0,
		maxoccupants = 5,
		uniquestash = true,
		doors = {
			[1] = {
				door = {
					[1] = {
						coord = vec3(307.21499633789,-212.79479980469,54.420265197754),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(307.01657104492,-207.91079711914,53.758548736572),
				wardrobe = vec3(302.58380126953,-207.71691894531,54.598297119141),
				fridge = vec3(305.00064086914,-206.12855529785,54.544868469238),
			},
			[2] = {
				door = {
					[1] = {
						coord = vec3(310.95474243164,-202.91288757324,54.421058654785),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(310.91235351563,-198.10073852539,53.758598327637),
				wardrobe = vec3(306.25433349609,-197.75250244141,54.564342498779),
				fridge = vec3(308.79779052734,-196.23670959473,54.440326690674),
			},
			[3] = {
				door = {
					[1] = {
						coord = vec3(316.28607177734,-194.54536437988,54.391784667969),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(321.10150146484,-194.42211914063,53.758399963379),
				wardrobe = vec3(321.42459106445,-189.79216003418,54.65941619873),
				fridge = vec3(322.92010498047,-192.31481933594,54.600353240967),
			},
			[4] = {
				door = {
					[1] = {
						coord = vec3(314.36087036133,-219.91516113281,58.151386260986),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(309.6142578125,-220.16128540039,57.557399749756),
				wardrobe = vec3(309.21203613281,-224.6675567627,58.375194549561),
				fridge = vec3(307.6989440918,-222.11755371094,58.293560028076),
			},
			[5] = {
				door = {
					[1] = {
						coord = vec3(307.22616577148,-212.77645874023,58.204700469971),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(306.89093017578,-207.88090515137,57.556159973145),
				wardrobe = vec3(302.57464599609,-207.71339416504,58.440250396729),
				fridge = vec3(305.044921875,-205.99066162109,58.394989013672),
			},
			[6] = {
				door = {
					[1] = {
						coord = vec3(311.00057983398,-202.87718200684,58.148029327393),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(310.88967895508,-198.16856384277,57.556510925293),
				wardrobe = vec3(306.09225463867,-198.40795898438,58.27188873291),
				fridge = vec3(308.73110961914,-196.40968322754,58.407859802246),
			},
			[7] = {
				door = {
					[1] = {
						coord = vec3(316.29287719727,-194.5479888916,58.212650299072),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(321.24801635742,-194.29737854004,57.556739807129),
				wardrobe = vec3(321.46688842773,-189.68632507324,58.422557830811),
				fridge = vec3(322.98544311523,-192.33996582031,58.386581420898),
			},
			[8] = {
				door = {
					[1] = {
						coord = vec3(334.43743896484,-227.5984954834,54.384216308594),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(329.67590332031,-227.8233795166,53.758399963379),
				wardrobe = vec3(329.43222045898,-232.33073425293,54.64941619873),
				fridge = vec3(327.64138793945,-229.79788208008,54.555628967285),
			},
			[9] = {
				door = {
					[1] = {
						coord = vec3(339.44650268555,-219.9709777832,54.377570343018),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(339.79351806641,-224.86245727539,53.75553817749),
				wardrobe = vec3(344.26574707031,-225.00813293457,54.602909851074),
				fridge = vec3(341.6985168457,-226.52975463867,54.367748260498),
			},
			[10] = {
				door = {
					[1] = {
						coord = vec3(347.0237121582,-200.22482299805,54.414268493652),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(347.33102416992,-205.13743591309,53.759078979492),
				wardrobe = vec3(351.68756103516,-205.30010986328,54.674419403076),
				fridge = vec3(349.34033203125,-206.6258392334,54.639694213867),
			},
			[11] = {
				door = {
					[1] = {
						coord = vec3(334.44702148438,-227.61134338379,58.205139160156),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(329.67590332031,-227.8233795166,57.556579589844),
				wardrobe = vec3(329.43222045898,-232.33073425293,58.42276763916),
				fridge = vec3(327.64138793945,-229.79788208008,58.355628967285),
			},
			[12] = {
				door = {
					[1] = {
						coord = vec3(339.44650268555,-219.9709777832,58.177570343018),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(339.79351806641,-224.86245727539,57.55553817749),
				wardrobe = vec3(344.26574707031,-225.00813293457,58.302909851074),
				fridge = vec3(341.6985168457,-226.52975463867,58.367748260498),
			},
			[13] = {
				door = {
					[1] = {
						coord = vec3(343.22320556641,-210.1229095459,58.176639556885),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(343.47412109375,-214.96145629883,57.55553817749),
				wardrobe = vec3(348.07550048828,-215.08416748047,58.288040161133),
				fridge = vec3(345.40502929688,-216.88189697266,58.281555175781),
			},
			[14] = {
				door = {
					[1] = {
						coord = vec3(347.03012084961,-200.20816040039,58.177433013916),
						model = `gabz_pinkcage_doors_front`
					},
				},
				stash = vec3(347.12841796875,-205.05494689941,57.55553817749),
				wardrobe = vec3(351.77719116211,-205.24267578125,58.351734161377),
				fridge = vec3(349.24819946289,-206.78134155273,58.326892852783),
			},
		},
	},

	-- ============================================================
	--  SANDY SHORES MOTEL - MLO (prompt_sandy_motel)
	--  Map position: 1628.05, 3787.72, 35.57
	--  26 rooms total: 15x Ground floor, 11x First floor
	--  Doorlock SQL entries: IDs 1117-1156 (ox_doorlock)
	--  NOTE: stash/wardrobe coords are offset ~2u inside each room
	--        from the door positions taken from ox_doorlock SQL.
	--        Fine-tune in-game if needed.
	-- ============================================================
	[2] = {
		manual = false,
		Mlo = true,          -- This is an MLO interior, NOT a shell
		label = 'Sandy Shores Motel',
		rental_period = 'hour',
		rate = 150,           -- cost per hour
		businessprice = 750000000,
		motel = 'sandymotel',
		payment = 'money',
		door = 718415028,     -- model hash used throughout the MLO doors (from doorlock SQL)
		rentcoord = vec3(1628.05, 3787.72, 35.57), -- reception/rent desk (MLO entrance area)
		coord = vec3(1600.0, 3765.0, 35.05),       -- approximate center of the motel complex
		radius = 120.0,
		maxoccupants = 2,
		uniquestash = true,

		-- --------------------------------------------------------
		--  GROUND FLOOR ROOMS  (z ≈ 35.04 – 35.13)
		--  Door coords from ox_doorlock SQL (IDs 1117-1133).
		--  Stash/wardrobe are estimated 2-3u inside each room —
		--  adjust in-game with a coord grabber if needed.
		-- --------------------------------------------------------
		doors = {
			-- Ground floor, row A (heading 218 = south-west facing doors)
			[1] = { -- G-1
				door = {
					[1] = {
						coord = vec3(1616.4639892578126, 3787.65478515625, 35.05494689941406),
						model = 718415028,
					},
				},
				stash    = vec3(1614.80, 3785.40, 35.05),
				wardrobe = vec3(1613.50, 3786.80, 35.05),
				fridge   = vec3(1615.20, 3784.20, 35.05),
			},
			[2] = { -- G-2
				door = {
					[1] = {
						coord = vec3(1612.069091796875, 3784.28759765625, 35.05494689941406),
						model = 718415028,
					},
				},
				stash    = vec3(1610.40, 3782.00, 35.05),
				wardrobe = vec3(1609.10, 3783.40, 35.05),
				fridge   = vec3(1610.80, 3780.80, 35.05),
			},
			[3] = { -- G-3
				door = {
					[1] = {
						coord = vec3(1607.6707763671876, 3780.892822265625, 35.05494689941406),
						model = 718415028,
					},
				},
				stash    = vec3(1606.00, 3778.60, 35.05),
				wardrobe = vec3(1604.70, 3780.00, 35.05),
				fridge   = vec3(1606.40, 3777.40, 35.05),
			},
			[4] = { -- G-4
				door = {
					[1] = {
						coord = vec3(1603.28515625, 3777.527587890625, 35.05494689941406),
						model = 718415028,
					},
				},
				stash    = vec3(1601.60, 3775.20, 35.05),
				wardrobe = vec3(1600.30, 3776.60, 35.05),
				fridge   = vec3(1602.00, 3774.00, 35.05),
			},
			[5] = { -- G-5
				door = {
					[1] = {
						coord = vec3(1584.8594970703126, 3763.412353515625, 35.05878067016601),
						model = 718415028,
					},
				},
				stash    = vec3(1583.20, 3761.10, 35.06),
				wardrobe = vec3(1581.90, 3762.50, 35.06),
				fridge   = vec3(1583.60, 3759.90, 35.06),
			},
			[6] = { -- G-6
				door = {
					[1] = {
						coord = vec3(1579.904296875, 3759.614501953125, 35.05878067016601),
						model = 718415028,
					},
				},
				stash    = vec3(1578.20, 3757.30, 35.06),
				wardrobe = vec3(1576.90, 3758.70, 35.06),
				fridge   = vec3(1578.60, 3756.10, 35.06),
			},

			-- Ground floor, row B (heading 38 = north-east facing doors)
			[7] = { -- G-7
				door = {
					[1] = {
						coord = vec3(1623.28125, 3774.53125, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1625.00, 3776.80, 35.04),
				wardrobe = vec3(1626.30, 3775.40, 35.04),
				fridge   = vec3(1624.60, 3778.00, 35.04),
			},
			[8] = { -- G-8
				door = {
					[1] = {
						coord = vec3(1618.3240966796876, 3770.7275390625, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1620.00, 3773.00, 35.04),
				wardrobe = vec3(1621.30, 3771.60, 35.04),
				fridge   = vec3(1619.60, 3774.20, 35.04),
			},
			[9] = { -- G-9
				door = {
					[1] = {
						coord = vec3(1613.3477783203126, 3766.9091796875, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1615.00, 3769.20, 35.04),
				wardrobe = vec3(1616.30, 3767.80, 35.04),
				fridge   = vec3(1614.60, 3770.40, 35.04),
			},
			[10] = { -- G-10
				door = {
					[1] = {
						coord = vec3(1608.3729248046876, 3763.091796875, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1610.00, 3765.40, 35.04),
				wardrobe = vec3(1611.30, 3764.00, 35.04),
				fridge   = vec3(1609.60, 3766.60, 35.04),
			},
			[11] = { -- G-11
				door = {
					[1] = {
						coord = vec3(1603.40185546875, 3759.27734375, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1605.10, 3761.60, 35.04),
				wardrobe = vec3(1606.40, 3760.20, 35.04),
				fridge   = vec3(1604.70, 3762.80, 35.04),
			},
			[12] = { -- G-12
				door = {
					[1] = {
						coord = vec3(1598.4222412109376, 3755.456298828125, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1600.10, 3757.80, 35.04),
				wardrobe = vec3(1601.40, 3756.40, 35.04),
				fridge   = vec3(1599.70, 3759.00, 35.04),
			},
			[13] = { -- G-13
				door = {
					[1] = {
						coord = vec3(1593.4525146484376, 3751.642822265625, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1595.10, 3754.00, 35.04),
				wardrobe = vec3(1596.40, 3752.60, 35.04),
				fridge   = vec3(1594.70, 3755.20, 35.04),
			},
			[14] = { -- G-14
				door = {
					[1] = {
						coord = vec3(1588.8453369140626, 3748.107666015625, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1590.50, 3750.40, 35.04),
				wardrobe = vec3(1591.80, 3749.00, 35.04),
				fridge   = vec3(1590.10, 3751.60, 35.04),
			},
			[15] = { -- G-15
				door = {
					[1] = {
						coord = vec3(1584.32421875, 3744.637939453125, 35.04315185546875),
						model = 718415028,
					},
				},
				stash    = vec3(1586.00, 3747.00, 35.04),
				wardrobe = vec3(1587.30, 3745.60, 35.04),
				fridge   = vec3(1585.60, 3748.20, 35.04),
			},

			-- --------------------------------------------------------
			--  FIRST FLOOR ROOMS  (z ≈ 38.65)
			--  Door coords from ox_doorlock SQL (IDs 1134-1152).
			-- --------------------------------------------------------

			-- First floor, row A (heading 218)
			[16] = { -- 1-1
				door = {
					[1] = {
						coord = vec3(1616.4639892578126, 3787.65478515625, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1614.80, 3785.40, 38.65),
				wardrobe = vec3(1613.50, 3786.80, 38.65),
				fridge   = vec3(1615.20, 3784.20, 38.65),
			},
			[17] = { -- 1-2
				door = {
					[1] = {
						coord = vec3(1612.09619140625, 3784.30712890625, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1610.40, 3782.00, 38.65),
				wardrobe = vec3(1609.10, 3783.40, 38.65),
				fridge   = vec3(1610.80, 3780.80, 38.65),
			},
			[18] = { -- 1-3
				door = {
					[1] = {
						coord = vec3(1607.700927734375, 3780.92578125, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1606.00, 3778.60, 38.65),
				wardrobe = vec3(1604.70, 3780.00, 38.65),
				fridge   = vec3(1606.40, 3777.40, 38.65),
			},
			[19] = { -- 1-4
				door = {
					[1] = {
						coord = vec3(1603.243408203125, 3777.501220703125, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1601.60, 3775.20, 38.65),
				wardrobe = vec3(1600.30, 3776.60, 38.65),
				fridge   = vec3(1602.00, 3774.00, 38.65),
			},
			[20] = { -- 1-5
				door = {
					[1] = {
						coord = vec3(1582.2303466796876, 3761.370361328125, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1580.60, 3759.10, 38.65),
				wardrobe = vec3(1579.30, 3760.50, 38.65),
				fridge   = vec3(1581.00, 3757.90, 38.65),
			},
			[21] = { -- 1-6
				door = {
					[1] = {
						coord = vec3(1577.269775390625, 3757.58642578125, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1575.60, 3755.30, 38.65),
				wardrobe = vec3(1574.30, 3756.70, 38.65),
				fridge   = vec3(1576.00, 3754.10, 38.65),
			},
			[22] = { -- 1-7
				door = {
					[1] = {
						coord = vec3(1572.290283203125, 3753.769775390625, 38.65202713012695),
						model = 718415028,
					},
				},
				stash    = vec3(1570.60, 3751.50, 38.65),
				wardrobe = vec3(1569.30, 3752.90, 38.65),
				fridge   = vec3(1571.00, 3750.30, 38.65),
			},

			-- First floor, row B (heading 38)
			[23] = { -- 1-8
				door = {
					[1] = {
						coord = vec3(1623.2734375, 3774.52490234375, 38.65088653564453),
						model = 718415028,
					},
				},
				stash    = vec3(1625.00, 3776.80, 38.65),
				wardrobe = vec3(1626.30, 3775.40, 38.65),
				fridge   = vec3(1624.60, 3778.00, 38.65),
			},
			[24] = { -- 1-9
				door = {
					[1] = {
						coord = vec3(1618.3192138671876, 3770.723388671875, 38.65088653564453),
						model = 718415028,
					},
				},
				stash    = vec3(1620.00, 3773.00, 38.65),
				wardrobe = vec3(1621.30, 3771.60, 38.65),
				fridge   = vec3(1619.60, 3774.20, 38.65),
			},
			[25] = { -- 1-10
				door = {
					[1] = {
						coord = vec3(1613.355224609375, 3766.914306640625, 38.65088653564453),
						model = 718415028,
					},
				},
				stash    = vec3(1615.00, 3769.20, 38.65),
				wardrobe = vec3(1616.30, 3767.80, 38.65),
				fridge   = vec3(1614.60, 3770.40, 38.65),
			},
			[26] = { -- 1-11
				door = {
					[1] = {
						coord = vec3(1608.390625, 3763.10498046875, 38.65088653564453),
						model = 718415028,
					},
				},
				stash    = vec3(1610.00, 3765.40, 38.65),
				wardrobe = vec3(1611.30, 3764.00, 38.65),
				fridge   = vec3(1609.60, 3766.60, 38.65),
			},
		},
	},
}

config.extrafunction = {
	['bed'] = function(data,identifier)
		TriggerEvent('luckyme')
	end,
	['fridge'] = function(data,identifier)
		TriggerEvent('ox_inventory:openInventory', 'stash', {id = 'fridge_'..data.motel..'_'..identifier..'_'..data.index, name = 'Fridge', slots = 30, weight = 20000, coords = GetEntityCoords(cache.ped)})
	end,
	['exit'] = function(data)
		local coord = LocalPlayer.state.lastloc or vec3(data.coord.x,data.coord.y,data.coord.z)
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		SendNUIMessage({
			type = 'door'
		})
		return Teleport(coord.x,coord.y,coord.z,0.0,true)
	end,
}

config.Text = {
	['stash'] = 'Stash',
	['fridge'] = 'My Fridge',
	['wardrobe'] = 'Wardrobe',
	['bed'] = 'Sleep',
	['door'] = 'Door',
	['exit'] = 'Exit',
}

config.icons = {
	['door'] = 'fas fa-door-open',
	['stash'] = 'fas fa-box',
	['wardrobe'] = 'fas fa-tshirt',
	['fridge'] = 'fas fa-ice-cream',
	['bed'] = 'fas fa-bed',
	['exit'] = 'fas fa-door-open',
}

config.stashblacklist = {
	['stash'] = {
		blacklist = {
			water = true,
		},
	},
	['fridge'] = {
		blacklist = {
			WEAPON_PISTOL = true,
		},
	},
}

PlayerData,ESX,QBCORE,zones,shelzones,blips = {},nil,nil,{},{},{}

function import(file)
	local name = ('%s.lua'):format(file)
	local content = LoadResourceFile(GetCurrentResourceName(),name)
	local f, err = load(content)
	return f()
end

if GetResourceState('es_extended') == 'started' then
	ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
	QBCORE = exports['qb-core']:GetCoreObject()
end
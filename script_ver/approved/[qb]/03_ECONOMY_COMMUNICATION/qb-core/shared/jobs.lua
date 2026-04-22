QBShared = QBShared or {}
-- Jobs
QBShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
QBShared.Jobs = {
['admin'] = {
    label = 'qb-core',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Gov',
            payment = 0
        },
    },
},
['unemployed'] = {
    label = 'Civilian',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Freelancer',
            payment = 50
        },
    },
},

-- tobaacoo shop
['cigar'] = {
    label = 'Tobacco Shop',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = { name = 'Sales', payment = 50 },
        ['1'] = { name = 'Manager', isboss = true, payment = 500 },
    },
},

['planepilot'] = {
    label = 'Delivery',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Pilot',
            payment = 10
        },
    },
},

['tatto'] = {
    label = 'Tatto',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Artist',
            payment = 450
        },
    },
},

['logistics'] = {
    label = 'Warehouse Logistics',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Trainee',
            payment = 200
        },
        ['1'] = {
            name = 'Storeman',
            payment = 350
        },
        ['2'] = {
            name = 'Manager',
            pay = 500
        },
        ['3'] = {
            name = 'Owner',
            pay = 750
        },
    },
},

['tow'] = {
    label = 'Tow',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Tow',
            payment = 90
        },
    },
},

['drugdealer'] = {
    label = 'Drugs',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Recruit', payment = 150 },
        ['1'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 200 },
    },
},

['yellowjack'] = {
    label = 'Yellow Jack Bar',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Security', payment = 1750 },
        ['1'] = { name = 'Waiter', payment = 1750 },
        ['2'] = { name = 'Bartender', payment = 1750 },
        ['3'] = { name = 'Manager', payment = 2000 },
        ['4'] = { name = 'C.E.O', isboss = true, bankAuth = true, payment = 2000 },
    },
},

--Vanilla
['vanilla'] = {
    label = 'Club77',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Security', payment = 1750 },
        ['1'] = { name = 'Waiter', payment = 1750 },
        ['2'] = { name = 'Bartender', payment = 1750 },
        ['3'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 1850 },
        ['4'] = { name = 'C.E.O', isboss = true, bankAuth = true, payment = 2000 },
    },
},

--henhouse Job
['henhouse'] = {
    label = 'The Hen House',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Recruit', payment = 150 },
        ['1'] = { name = 'Novice', payment = 165 },
        ['2'] = { name = 'Experienced', payment = 170 },
        ['3'] = { name = 'Advanced', payment = 175 },
        ['4'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 200 },
    },
},

['comic'] = {
    label = 'Comic Store',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Worker',
            payment = 55,
        },
        ['1'] = {
            name = 'Adv. Worker',
            payment = 55,
        },
        ['2'] = {
            name = 'Co Boss',
            isboss = true,
            payment = 55,
        },
        ['3'] = {
            name = 'C.E.O',
            isboss = true,
            payment = 70,
        },
    },
},

['casino'] = {
    label = 'Casino',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Worker',
            payment = 200,
        },
        ['1'] = {
            name = 'Dealer',
            payment = 200,
        },
        ['2'] = {
            name = 'Co Boss',
            isboss = true,
            payment = 200,
        },
        ['3'] = {
            name = 'Casino C.E.O',
            isboss = true,
            payment = 300,
        },
    },
},

['taco'] = {
    label = 'Mexican Restaurant',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Cook',
            payment = 1750,
        },
        ['1'] = {
            name = 'Chef',
            payment = 1750,
        },
        ['1'] = {
            name = 'Adv.Chef',
            payment = 1750,
        },
        ['2'] = {
            name = 'Manager',
            isboss = true,
            payment = 1750,
        },
        ['3'] = {
            name = 'Owner',
            isboss = true,
            payment = 2000,
        },
    },
},

['coolbeans'] = {
    label = 'Cool Beans',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Recruit',
            payment = 1750,
        },
        ['1'] = {
            name = 'Novice',
            payment = 1750,
        },
        ['1'] = {
            name = 'Experienced',
            payment = 1750,
        },
        ['2'] = {
            name = 'V.CEO',
            isboss = true,
            payment = 2000,
        },
        ['3'] = {
            name = 'CEO',
            isboss = true,
            payment = 2000,
        },
    },
},

['beanmachine'] = {
    label = 'Custom Caffe',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Recruit',
            payment = 500,
        },
        ['1'] = {
            name = 'Novice',
            payment = 500,
        },
        ['1'] = {
            name = 'Experienced',
            payment = 500,
        },
        ['2'] = {
            name = 'V.CEO',
            isboss = true,
            payment = 200,
        },
        ['3'] = {
            name = 'CEO',
            isboss = true,
            payment = 400,
        },
    },
},

-- PawnSHOP Job
['pawn'] = {
    label = 'Pawn Shop',
    defaultDuty = true,
    grades = {
        ['1'] = { name = 'Recruit', payment = 55 },
        ['2'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 70 },
    },
},

-- Catcafe Job
['catcafe'] = {
    label = 'Cat Cafe',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Recruit', payment = 1750 },
        ['1'] = { name = 'Novice', payment = 1750 },
        ['2'] = { name = 'Experienced', payment = 1750 },
        ['3'] = { name = 'Advanced', payment = 1750 },
        ['4'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 2000 },
    },
},


-- Piza This job
['pizzathis'] = {
    label = 'Drusilla Pizza',
    defaultDuty = true,
    grades = {
        ['0'] = { name = 'Recruit', payment = 200 },
        ['1'] = { name = 'Novice', payment = 200 },
        ['2'] = { name = 'Experienced', payment = 200 },
        ['3'] = { name = 'Advanced', payment = 200 },
        ['4'] = { name = 'Manager', isboss = true, bankAuth = true, payment = 300 },
    },
},

["redline"] = {
    label = "Redline",
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = "Employee",
            payment = 2000,
        },
        ['1'] = {
            name = "Head Employees",
            payment = 2000,
        },
        ['2'] = {
            name = "Owner",
            bankAuth = true,
            isboss = true,
            payment = 2500,
        },
    },
},

["mechanic"] = {
    label = "mechanic",
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = "Employee",
            payment = 2000,
        },
        ['1'] = {
            name = "Head Employees",
            payment = 2000,
        },
        ['2'] = {
            name = "Owner",
            bankAuth = true,
            isboss = true,
            payment = 2500,
        },
    },
},

-- Communications Technician job

["telco"] = {
    label = "Technician",
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = "Communications",
            payment = 50
        },
    },
},

['whitewidow'] = {
    label = 'whitewidow',
    defaultDuty = true,
    grades = {
        ['0'] = {name = 'Rookie',                                        payment = 1750},
        ['1'] = {name = 'Seller',                                        payment = 1750},
        ['2'] = {name = 'V.CEO',                           isboss = true,    bankAuth = true,                 payment = 1750},
        ['3'] = {name = 'CEO',                isboss = true,    bankAuth = true,            payment = 2000},
    },
},

-- Police Job
['police'] = {
    label = 'Police',
    type = 'leo',
    defaultDuty = true,
    grades = {
        ['0'] = {name = "Cadet",                                                   payment = 1500},
        ['1'] = {name = "Solo Cadet",                                                 payment = 1500},
        ['2'] = {name = "Officer",                                              payment = 1500},
        ['3'] = {name = "Ranger",                                                 payment = 1500},
        ['4'] = {name = "Trooper",                                                    payment = 1500},
        ['5'] = {name = "Deputy",                                             payment = 1500},
        ['6'] = {name = "Sr.Officer",                                                  payment = 1500},
        ['7'] = {name = "Sr.Ranger",                                               payment = 1500},
        ['8'] = {name = "Sr.Deputy",                                               payment = 1500},
        ['9'] = {name = "Corporal",                                                 payment = 1500},
        ['10'] = {name = "Corporal BCSO",                                             payment = 1500},
        ['11'] = {name = "Corporal SASP",                                         payment = 1500},
        ['12'] = {name = "Corporal SASPR",                                               payment = 1500},
        ['13'] = {name = "Sergeant",                                               payment = 1500},
        ['14'] = {name = "Sergeant SDSO",                                               payment = 1500},
        ['15'] = {name = "Sergeant SASP",                           isboss = true, bankAuth = true,  payment = 1500},
        ['16'] = {name = "Sergeant SASPR",                         isboss = true, bankAuth = true,   payment = 1500},
        ['17'] = {name = "Lieutenant",                              isboss = true, bankAuth = true,   payment = 1500},
        ['18'] = {name = "Lieutenant BCSO",                                           payment = 1500},
        ['19'] = {name = "Lieutenant SASP",                                           payment = 1500},
        ['20'] = {name = "Lieutenant SASPR",                                         payment = 1500},
        ['21'] = {name = "Captain",                          isboss = true, bankAuth = true,    payment = 1500},
        ['22'] = {name = "Captain BCSO",                             isboss = true, bankAuth = true,   payment = 1500},
        ['23'] = {name = "Captain SASP",                       isboss = true, bankAuth = true,   payment = 1500},
        ['24'] = {name = "Captain SASPR",                       isboss = true, bankAuth = true,   payment = 1500},
        ['25'] = {name = "Commander",                          isboss = true, bankAuth = true,    payment = 1500},
        ['26'] = {name = "Undersheriff",                       isboss = true, bankAuth = true,   payment = 1500},
        ['27'] = {name = "Sheriff",                       isboss = true, bankAuth = true,   payment = 1500},
        ['28'] = {name = "Assistant C.O.P",                       isboss = true, bankAuth = true,   payment = 1500},
        ['29'] = {name = "C.O.P",                       isboss = true, bankAuth = true,   payment = 1500},
        ['30'] = {name = "Colonel",                       isboss = true, bankAuth = true,   payment = 1500},
        ['31'] = {name = "Commissioner",                       isboss = true, bankAuth = true,   payment = 1500},
        ['32'] = {name = "D. Supervisor",                       isboss = true, bankAuth = true,   payment = 1500},
        ['33'] = {name = "Game Warden",                       isboss = true, bankAuth = true,   payment = 1500},
        ['34'] = {name = "D. Game Warden",                       isboss = true, bankAuth = true,   payment = 1500},
       },
    },

-- EMS job
['ambulance'] = {
    label = 'EMS',
    defaultDuty = true,
    grades = {
        ['0'] = {name = "Trainee", payment = 1500},
        ['1'] = {name = "Paramedic", payment = 2000},
        ['2'] = {name = "Senior Paramedic", payment = 2500},
        ['3'] = {name = "Lead Paramedic", payment = 3000},
        ['4'] = {name = "Supervisor", isboss = true, bankAuth = true, payment = 3500},
        ['5'] = {name = "Chief Medical Officer", isboss = true, bankAuth = true, payment = 4000},
    },
},

    -- Corrections Job
['corrections'] = {
    label = 'Corrections',
    defaultDuty = true,
    grades = {
        ['0'] = {name = "Cadet",                                                   payment = 20},
        ['1'] = {name = "Solo Cadet",                                                 payment = 20},
        ['2'] = {name = "Warden",                                              payment = 20},
        ['3'] = {name = "Advanced Warden",                                                 payment = 20},
        ['4'] = {name = "Warden In Charge",                                                    payment = 20},
        ['5'] = {name = "Responsible For Departments",                                             payment = 20},
        ['6'] = {name = "Prison Commander",                       isboss = true, bankAuth = true,   payment = 20},
       },
    },

['realestate'] = {
    label = 'Real Estate',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Recruit',
            payment = 200
        },
        ['1'] = {
            name = 'House Sales',
            payment = 200
        },
        ['2'] = {
            name = 'Business Sales',
            payment = 200
        },
        ['3'] = {
            name = 'Broker',
            payment = 200
        },
        ['4'] = {
            name = 'Manager',
            isboss = true,
            bankAuth = true,
            payment = 300
        },
    },
},
    ['bus'] = {
    label = 'Bus',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Driver',
            payment = 150
        },
    },
},
['taxi'] = {
    label = 'Taxi',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Driver',
            payment = 60
        },
    },
},
['tuner'] = {
    label = 'Tuner',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Tuner Employee',
            payment = 100
        },
        ['1'] = {
            name = 'Tuner UnderBoss',
            payment = 150
        },
        ['2'] = {
            name = 'Tuner Boss',
            isboss = true,
            bankAuth = true,
            payment = 300
        },
    },
},
['judge'] = {
    label = 'DOJ',
    defaultDuty = true,
    grades = {
        ['1'] = {
            name = 'Lawyer',
            payment = 3000
        },
        ['2'] = {
            name = 'Judge',
            payment = 3000
        },
        ['3'] = {
            name = 'Sr. Judge',
            payment = 3000
        },
        ['4'] = {
            name = 'Justice',
            payment = 3000
        },
        ['5'] = {
            name = 'Chief Justice',
            isboss = true,
            payment = 3000
        },
        ['6'] = {
            name = 'Deputy Mayor',
            isboss = true,
            payment = 3000
        },
        ['7'] = {
            name = 'Mayor',
            isboss = true,
            payment = 3000
        },
        ['8'] = {
            name = 'Senator',
            isboss = true,
            payment = 3000
        },
    },
},
['lawyer'] = {
    label = 'Lawyer',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Associate',
            payment = 200
        },
    },
},
['reporter'] = {
    label = 'Reporter',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Journalist',
            payment = 50
        },
    },
},
['trucker'] = {
    label = 'Trucker',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Rookie',
            payment = 50
        },
    },
},
['garbage'] = {
    label = 'Garbage',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Collector',
            payment = 150
        },
    },
},
["tequilala"] = {
    label = "Tequi-la-la",
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = "DJ",
            payment = 200
        },
        ['1'] = {
            name = "Bartender",
            payment = 200
        },
        ['2'] = {
            name = "Bouncer",
            payment = 200
        },
        ['3'] = {
            name = "Manager",
            payment = 200
        },
        ['4'] = {
            name = "Owner",
            bankAuth = true,
            isboss = true,
            payment = 300
        },
    },
},
["burgershot"] = {
    label = "Up n Atom Burger",
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = "Employee",
            payment = 1750,
        },
        ['1'] = {
            name = "Waiter",
            payment = 1750,
        },
        ['2'] = {
            name = "Cooker",
            payment = 1750,
        },
        ['3'] = {
            name = "Manager",
            payment = 1750,
        },
        ['4'] = {
            name = "Owner",
            bankAuth = true,
            isboss = true,
            payment = 2000,
        },
    },
},

['cardealer'] = {
    label = 'cardealer',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Dealer',
            payment = 200,
        },
        ['1'] = {
            name = 'Manager',
            isboss = true,
            payment = 200,
        },
    },
},

['motodealer'] = {
    label = 'motodealer',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Dealer',
            payment = 200,
        },
        ['1'] = {
            name = 'Manager',
            isboss = true,
            payment = 200,
        },
    },
},

['vipdealer'] = {
    label = 'vipdealer',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Dealer',
            payment = 200,
        },
        ['1'] = {
            name = 'Manager',
            isboss = true,
            payment = 200,
        },
    },
},

}

let ls = {
    weed: [
        "ls_plain_jane_bud", "ls_plain_jane_joint", "ls_plain_jane_bag",
        "ls_banana_kush_bud", "ls_banana_kush_joint", "ls_banana_kush_bag",
        "ls_blue_dream_bud", "ls_blue_dream_joint", "ls_blue_dream_bag",
        "ls_purple_haze_bud", "ls_purple_haze_joint", "ls_purple_haze_bag",
        "ls_orange_crush_bud", "ls_orange_crush_joint", "ls_orange_crush_bag",
        "ls_cosmic_kush_bud", "ls_cosmic_kush_joint", "ls_cosmic_kush_bag",
    ],
    meth: [
        "ls_liquid_meth", "ls_meth_tray", "ls_meth_box", "ls_meth",
    ],
    coke: [
        "ls_coca_base_unf", "ls_coca_base", "ls_cocaine_brick", "ls_crack_brick",
        "ls_cocaine_bag", "ls_crack_bag",
    ],
    diving: [
        "ls_scuba_gear_1", "ls_scuba_gear_2", "ls_scuba_gear_3", "ls_scuba_gear_4",
        "ls_scuba_gear_5", "ls_oxygen_tank",
    ],
    tools: [
        "ls_watering_can", "ls_fertilizer", "ls_ammonia",
        "ls_iodine", "ls_acetone", "ls_gasoline", "ls_cement",
    ]
};
let backpackMeta = ['backpack', 'backpack1', 'backpack2', 'backpack3'];
let phoneMeta = ['phone', 'black_phone', 'yellow_phone', 'red_phone', 'green_phone'];
let clothingItem = ["tshirt_1", "torso_1", "arms", "pants_1", "shoes_1", "mask_1", "bproof_1", "chain_1", "helmet_1", "glasses_1", "watches_1", "bracelets_1", "bags_1"];

export function sendInfoData(item) {
    let iteminfo = item.info || {};
    let returnString = "";

    if (item.name == "id_card") {
        let man = iteminfo.gender === 1 ? "Woman" : "Man";
        let infoData = [
            { label: "Firstname", value: iteminfo.firstname || "Unknown" },
            { label: "Lastname", value: iteminfo.lastname || "Unknown" },
            { label: "Birthdate", value: iteminfo.birthdate || "Unknown" },
            { label: "Nationality", value: iteminfo.nationality || "Unknown" },
            { label: "Gender", value: man },
            { label: "Citizen", value: iteminfo.citizenid || "Unknown" }
        ];
        returnString = infoData;
    } else if (item.name.match("driver_license")) {
        let infoData = [
            { label: "Firstname", value: iteminfo.firstname || "Unknown" },
            { label: "Lastname", value: iteminfo.lastname || "Unknown" },
            { label: "Birthdate", value: iteminfo.birthdate || "Unknown" },
            { label: "Licenses", value: iteminfo.type || "Unknown" },
        ];
        returnString = infoData;
    } else if (phoneMeta.includes(item.name)) {
        let charinfo = iteminfo.charinfo || {};
        let infoData = [
            { label: "Firstname", value: charinfo.firstname || "Unknown" },
            { label: "Lastname", value: charinfo.lastname || "Unknown" },
            { label: "Number", value: charinfo.phoneNumber || "Unknown" }
        ];
        returnString = infoData;
    } else if (item.name.match("lawyerpass")) {
        let infoData = [
            { label: "ID", value: iteminfo.id || "Unknown" },
            { label: "Firstname", value: iteminfo.firstname || "Unknown" },
            { label: "Lastname", value: iteminfo.lastname || "Unknown" },
            { label: "Citizen", value: iteminfo.citizenid || "Unknown" }
        ];
        returnString = infoData;
        } else if (ls.weed.includes(item.name) || ls.coke.includes(item.name)) {
    let infoData = [
        { label: "Purity", value: iteminfo.purity ? iteminfo.purity + "%" : "Unknown" }
    ];
    returnString = infoData;
} else if (ls.meth.includes(item.name)) {
    let infoData = [
        { label: "Strain", value: iteminfo.strain || "Unknown" },
        { label: "Purity", value: iteminfo.purity || "Unknown" }
    ];
    returnString = infoData;
} else if (ls.diving.includes(item.name)) {
    let infoData = [
        { label: "Remaining", value: iteminfo.quality || "Empty" }
    ];
    returnString = infoData;
} else if (ls.tools.includes(item.name)) {
    let infoData = [
        { label: "Remaining", value: iteminfo.quality || "Empty" }
    ];
    returnString = infoData;
    } else if (item.name.match("harness")) {
        let infoData = [
            { label: "USES : ", value: iteminfo.uses || "Unknown" },
        ];
        returnString = infoData;
    } else if (item.name.match("weapon")) {
        let infoData = [
            { label: "Serial", value: iteminfo.series || "Unknown" },
            { label: "Ammo", value: iteminfo.ammo || "Unknown" },
            { label: 'Quality', value: iteminfo.quality ? iteminfo.quality.toFixed(1) : 0 },
            { label: 'Repair Count', value: iteminfo.repair && iteminfo.maxrepair ? iteminfo.repair + ' / ' + iteminfo.maxrepair : "Unknown" },
        ];
        returnString = infoData;
    } else if (backpackMeta.includes(item.name)) {
        let infoData = [
            { label: "Info", value: iteminfo.series || "Unknown" },
            { label: "Slot", value: iteminfo.slot || "Unknown" },
            { label: "Weight", value: iteminfo.weight || "Unknown" },
        ];
        returnString = infoData;
    } else if (clothingItem.includes(item.name)) {
        let infoData = [
            { label: "Clothing ID", value: iteminfo.skin || "Unknown" },
            { label: "Texture", value: iteminfo.texture || "Unknown" },
        ];
        returnString = infoData;
    }
    return returnString;
}

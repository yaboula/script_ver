const useNotifyInsteadOfChat = false;

const vehicleStates = {
    0: "On the Streets",
    1: "In Garage",
    2: "In Police Impound",
    3: "Unknown",
};

module.exports = {
    name: "vehicle",
    description: "Give user a vehicle with a fixed plate",
    role: "god",

    options: [
        {
            type: "SUB_COMMAND",
            name: "give",
            description: "grant a car to a player",
            options: [
                {
                    name: "id",
                    description: "Player's current id",
                    required: true,
                    type: "INTEGER",
                },
                {
                    name: "model",
                    description: "Vehicle's spawn name (ex: t20)",
                    required: true,
                    type: "STRING",
                },
                {
                    name: "plate",
                    description: "Plate (max 8 characters)",
                    required: false,
                    type: "STRING",
                },
            ],
        },
        {
            type: "SUB_COMMAND",
            name: "lookup",
            description: "lookup vehicle by plate",
            options: [
                {
                    name: "plate",
                    description: "Plate to look for",
                    required: true,
                    type: "STRING",
                },
            ],
        },
    ],

    run: async (client, interaction, args) => {
        try {

            // =============================
            // GIVE VEHICLE
            // =============================
            if (args.give) {

                if (!GetPlayerName(args.id)) {
                    return interaction.reply({ content: "Invalid player ID.", ephemeral: true });
                }

                const player = client.QBCore.Functions.GetPlayer(args.id);
                if (!player) {
                    return interaction.reply({ content: "Player not found in QBCore.", ephemeral: true });
                }

                const model = args.model.toLowerCase();
                const hash = GetHashKey(model);

                if (!hash || hash === 0) {
                    return interaction.reply({
                        content: `Invalid vehicle model: \`${args.model}\``,
                        ephemeral: true
                    });
                }

                const plate = args.plate ? args.plate.toUpperCase() : await createPlate();

                if (plate.length > 8) {
                    return interaction.reply({
                        content: "Plate max length is 8 characters.",
                        ephemeral: true
                    });
                }

                const exists = await getVehicleByPlate(plate);
                if (exists.length > 0) {
                    return interaction.reply({
                        content: "Plate already exists.",
                        ephemeral: true
                    });
                }

                const save = await global.exports.oxmysql.insert_async(
                    "INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                        player.PlayerData.license,
                        player.PlayerData.citizenid,
                        model,
                        hash,
                        "{}",
                        plate,
                        1,
                        "pillboxgarage"
                    ]
                );

                if (!save) {
                    return interaction.reply({
                        content: "Failed to save vehicle to database.",
                        ephemeral: true
                    });
                }

                const playerMessage = `${model} has been added to your garage (Plate: ${plate})`;

                if (useNotifyInsteadOfChat)
                    emitNet("QBCore:Notify", args.id, playerMessage);
                else
                    client.utils.chatMessage(args.id, "Government", playerMessage, { color: [65, 105, 225] });

                client.utils.log.info(`[${interaction.member.displayName}] Gave ${GetPlayerName(args.id)} (${args.id}) a ${model} (${plate})`);

                return interaction.reply({
                    content: `${GetPlayerName(args.id)} (${args.id}) received a ${model}. Plate: ${plate}`,
                    ephemeral: false
                });
            }

            // =============================
            // LOOKUP VEHICLE
            // =============================
            else if (args.lookup) {

                let vehicle = await getVehicleByPlate(args.plate.toUpperCase());

                if (vehicle.length < 1) {
                    return interaction.reply({
                        content: "Vehicle not found.",
                        ephemeral: true
                    });
                }

                vehicle = vehicle[0];

                const embed = new client.Embed();
                embed.setDescription(`
**Plate:** ${vehicle.plate}
**Owner ID:** ${vehicle.citizenid}
**Vehicle:** ${vehicle.vehicle}
**Garage:** ${vehicle.garage}
**State:** ${vehicleStates[vehicle.state] ?? "Unknown"}
**Fuel:** ${vehicle.fuel ?? 100}/100
**Body:** ${vehicle.body ?? 1000}/1000
**Status:** ${vehicle.status ?? "N/A"}
**Odometer:** ${vehicle.drivingdistance ?? 0}

**Financing Details**
Balance: $${vehicle.balance ?? 0}
Payment: $${vehicle.paymentamount ?? 0}
Payments Left: ${vehicle.paymentsleft ?? 0}
Finance Time: ${vehicle.financetime ?? 0}
                `);

                return interaction.reply({ embeds: [embed], ephemeral: false });
            }

        } catch (error) {
            console.error("Vehicle command error:", error);
            return interaction.reply({
                content: "An internal error occurred. Check server console.",
                ephemeral: true
            });
        }
    },
};

async function getVehicleByPlate(plate) {
    return await global.exports.oxmysql.query_async(
        "SELECT * FROM player_vehicles WHERE plate = ?",
        [plate]
    );
}

async function createPlate() {
    let plate;
    let taken = true;

    while (taken) {
        plate = generatePlate();
        const exists = await getVehicleByPlate(plate);
        if (exists.length === 0) taken = false;
    }

    return plate;
}

function generatePlate() {
    return `${random(1, false)}${random(2)}${random(3, false)}${random(2)}`;
}

const random = (length = 8, alphabetical = true) => {
    const chars = alphabetical
        ? "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        : "0123456789";

    let str = "";
    for (let i = 0; i < length; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return str;
};

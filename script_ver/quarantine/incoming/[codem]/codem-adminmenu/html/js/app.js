const store = Vuex.createStore({
    components: {},

    state: {},
    getters: {},
    mutations: {},
    actions: {}
});
let audioPlayer = null;

const app = Vue.createApp({
    components: {},
    data: () => ({
        show: false,
        showCoords: false,
        showLaser: false,
        onlinePlayersCount: 0,
        serverTime: 12,
        spaceCount: 0,
        modalData: {
            ["addItemModal"]: false,
            ["changeJobModal"]: false,
            ["addMoneyModal"]: false,
            ["addvehicletoplayer"]: false,
            ["givevehicle"]: false,
            ["kickModal"]: false,
            ["sendPMModal"]: false,
            ["banModal"]: false,
            ["searchBanModal"]: false,
            ["bannedPlayersModal"]: false,
            ["unbanModal"]: false
        },
        inputData: {
            ["changejobName"]: "",
            ["changejobGrade"]: "",
            ["playerId"]: "",
            ["giveVehicleName"]: "",
            ["addItemName"]: "",
            ["addMoneyCash"]: "",
            ["addMoneyBank"]: "",
            ["addItemCount"]: "",
            ["sendPmText"]: "",
            ["kickTextModel"]: "",
            ["banTextModel"]: "",
            ["banTime"]: 1,
            ["searchBanText"]: ""
        },
        playerData: false,
        entityViewModeType: "",
        laserInfo: false,
        coords: {
            value: false,
            heading: false
        },
        notifications: [],
        timeout: false,
        selectedIndexMainCategory: 0,
        selectedIndexCategoryElement: 0,
        playerSelectedIndex: 0,
        playerSelected: false,
        weatherSelected: false,
        spawnVehicleSelected: false,
        giveVehicleDatabaseSelected: false,
        announcementModal: false,
        announementTextModel: "",
        playerInfoModal: false,
        playerInfoPlayerData: false,
        disableArrowKeyboard: false,
        playerInfoPage: "inventory",
        ItemImagesFolder: false,
        lastPlayerData: false,
        permissionSelected: false,
        selectedIndexPermissionCategoryElement: 0,
        searchBarAdmin: "",
        allowPermission: [],
        Locales: false,

        playerCheckedData: {
            ["invisible"]: false,
            ["adminoutfit"]: false,
            ["noclip"]: false,
            ["playername"]: false,
            ["playerlocation"]: false,
            ["godmode"]: false,
            ["showcoords"]: false,
            ["devlaser"]: false,
            ["adminduty"]: false,
            ["showmouse"]: false
        },
        playerInfoCategory: [],
        onlineOverviews: [],

        mainCategory: false,

        playerModalOption: false,
        weatherModalOption: false,
        laserKeyBind: false,
        noclipKeyBind: false,
        categoryElements: [],
        categoryPage: "main",
        selectedIndexBanSettings: 0,
        banSettings: [],
        offlineBanData: [],
        selectedBanIndex: 0,
        activeMenuName: false,
        bannedPlayers: [],
        selectedIndexBannedPlayers: 0,
        selectBannedPlayersData: false,
        vehicleDeleteDisantance: 5
    }),
    computed: {
        filterByTermCategoryData() {
            if (this.categoryPage == "adminoption") {
                const searchBarAdminItem = this.categoryElements.find(element => element.name === "searchbaradmin");

                const filteredElements = this.categoryElements.filter(
                    element => element.name !== "searchbaradmin" && element.label.toLowerCase().includes(this.searchBarAdmin.toLowerCase())
                );

                return [searchBarAdminItem, ...filteredElements].filter(Boolean);
            } else if (this.categoryPage == "playeroption") {
                const searchBarAdminItem = this.categoryElements.find(element => element.name === "searchbarplayer");

                const filteredElements = this.categoryElements.filter(element =>
                    element.name !== "searchbarplayer" &&
                    (element.name.toLowerCase().includes(this.searchBarAdmin.toLowerCase()) ||
                        String(element.id).toLowerCase().includes(this.searchBarAdmin.toLowerCase()))
                );


                return [searchBarAdminItem, ...filteredElements].filter(Boolean);
            } else {
                return this.categoryElements;
            }
        },
        getMenuHeaderText() {
            if (this.categoryPage == "main") {
                return "Main Menu";
            } else {
                return this.activeMenuName;
            }
        }
    },

    watch: {},

    beforeDestroy() { },
    mounted() {
        window.addEventListener("keyup", this.keyHandler);
        window.addEventListener("message", this.eventHandler);
    },

    methods: {
        checkInput() {
            if (this.inputData.addItemCount.length > 0) {
                this.inputData.addItemCount = this.inputData.addItemCount.replace(/[^0-9]/g, "");
            }
            if (this.inputData.addMoneyBank.length > 0) {
                this.inputData.addMoneyBank = this.inputData.addMoneyBank.replace(/[^0-9]/g, "");
            }
            if (this.inputData.addMoneyCash.length > 0) {
                this.inputData.addMoneyCash = this.inputData.addMoneyCash.replace(/[^0-9]/g, "");
            }
        },
        changeInfoPage(page) {
            this.playerInfoPage = page;
        },
        onInputFocus() {
            postNUI("OnInputFocus");
        },
        onInputFocusRemove() {
            postNUI("OnInputFocusRemove");
        },
        notification(text, value) {
            clicksound("notification_sound.mp3");
            let timeout = 3000;
            let id = Date.now();
            if (this.notifications.some(notification => notification.text === text)) {
                return;
            }

            if (value == "announcement") {
                timeout = 10000;
                let newNotification = {
                    id: id,
                    text: text,
                    icon: "announcementiconlarg",
                    header: "ANNOUNCEMENT",
                    timeout: setTimeout(() => {
                        this.notifications = this.notifications.filter(notification => notification.id != id);
                    }, timeout)
                };
                this.notifications.push(newNotification);
            }
            if (value == "notification") {
                let newNotification = {
                    id: id,
                    text: text,
                    icon: "notificationicon",
                    header: "NOTIFICATION",
                    timeout: setTimeout(() => {
                        this.notifications = this.notifications.filter(notification => notification.id != id);
                    }, timeout)
                };
                this.notifications.push(newNotification);
            }
            if (value == "pm") {
                timeout = 10000;
                let newNotification = {
                    id: id,
                    text: text.pm,
                    icon: "pmnotificationicon",
                    header: "PM FROM " + text.playername,
                    timeout: setTimeout(() => {
                        this.notifications = this.notifications.filter(notification => notification.id != id);
                    }, timeout)
                };
                this.notifications.push(newNotification);
            }
        },
        keyHandler(e) {
            switch (e.keyCode) {
                case 18:
                    this.handleAlt();
                    break;
                case 38:
                    this.handleUpArrow();
                    break;
                case 40:
                    this.handleDownArrow();
                    break;
                case 13:
                    this.handleEnter();
                    break;
                case 39:
                    this.handleRightArrow();
                    break;
                case 37:
                    this.handleLeftArrow();
                    break;
                case 8:
                    this.handleBackspace();
                    break;
                case 46:
                    this.handleDelete();
                    break;
                case 120:
                    this.handleF9();
                    break;
            }
        },
        handleF9() {
            if (this.playerCheckedData.devlaser) {
                let modelHash, entityId, objectName, coords;
                this.laserInfo[this.entityViewModeType].elements.forEach(el => {
                    if (el.name === "modelhash") modelHash = el.value;
                    if (el.name === "entityid") entityId = el.value;
                    if (el.name === "objectname") objectName = el.value;
                    if (el.name === "coords") coords = el.value;
                });
                let dataInfo = [modelHash, entityId, objectName, coords];
                postNUI("devlaserDiscordLog", dataInfo);
            }
        },
        handleAlt() {
            clicksound("tiz-button.mp3");
            this.playerCheckedData.showmouse = !this.playerCheckedData.showmouse;
            postNUI("mouseaction", this.playerCheckedData.showmouse);
        },

        handleUpArrow() {
            clicksound("tiz-button.mp3");
            if (this.modalData.searchBanModal) {
                this.searchBanModalSubmitUp("up");
                return;
            }

            if (this.modalData.changeJobModal) {
                this.changeJobModalSubmitDown();
                return;
            }
            if (this.modalData.addvehicletoplayer) {
                this.addVehicleToPlayerSubmit();
                return;
            }
            if (this.modalData.addItemModal) {
                this.addItemModalSubmit();
                return;
            }
            if (this.modalData.addMoneyModal) {
                this.addMoneyModalSubmit();
                return;
            }
            if (this.modalData.banModal) {
                this.banPlayerModalSubmit();
                return;
            }

            if (this.disableArrowKeyboard) {
                return;
            }
            if (this.$refs.searchbaradmin && this.$refs.searchbaradmin.length > 0) {
                this.$refs.searchbaradmin[0].blur();
            }
            if (this.permissionSelected) {
                this.selectedIndexPermissionCategoryElement =
                    this.selectedIndexPermissionCategoryElement > 0
                        ? this.selectedIndexPermissionCategoryElement - 1
                        : this.allowPermission.length - 1;
                this.scrollToItem();
                return;
            }

            if (this.modalData.bannedPlayersModal) {
                this.selectedIndexBannedPlayers =
                    this.selectedIndexBannedPlayers > 0 ? this.selectedIndexBannedPlayers - 1 : this.bannedPlayers.length - 1;
                return;
            }

            if (this.playerSelected) {
                this.playerSelectedIndex = this.playerSelectedIndex > 0 ? this.playerSelectedIndex - 1 : this.playerModalOption.length - 1;
                this.scrollToItem();
                return;
            }
            if (this.weatherSelected) {
                this.selectedIndexCategoryElement =
                    this.selectedIndexCategoryElement > 0 ? this.selectedIndexCategoryElement - 1 : this.weatherModalOption.length - 1;

                this.scrollToItem();
                return;
            }

            if (this.hasCategoryElements()) {
                this.selectedIndexCategoryElement =
                    this.selectedIndexCategoryElement > 0 ? this.selectedIndexCategoryElement - 1 : this.categoryElements.length - 1;
                this.scrollToItem();
            } else {
                this.selectedIndexMainCategory =
                    this.selectedIndexMainCategory > 0 ? this.selectedIndexMainCategory - 1 : this.mainCategory.length - 1;
                this.scrollToItem();
            }
        },

        searchBanModalSubmitUp(val) {
            if (val == "up") {
                this.selectedBanIndex = this.selectedBanIndex > 0 ? this.selectedBanIndex - 1 : this.offlineBanData.length - 1;
            }
            if (val == "down") {
                this.selectedBanIndex = this.selectedBanIndex < this.offlineBanData.length - 1 ? this.selectedBanIndex + 1 : 0;
            }
        },

        changeJobModalSubmitDown() {
            this.$nextTick(() => {
                if (this.$refs.changeJobNameInput.classList.contains("activechangejob")) {
                    this.$refs.changeJobGradeInput.focus();
                    this.$refs.changeJobGradeInput.classList.add("activechangejob");
                    this.$refs.changeJobNameInput.classList.remove("activechangejob");
                } else if (this.$refs.changeJobGradeInput.classList.contains("activechangejob")) {
                    this.$refs.changeJobNameInput.focus();
                    this.$refs.changeJobNameInput.classList.add("activechangejob");
                    this.$refs.changeJobGradeInput.classList.remove("activechangejob");
                }
            });
        },
        addVehicleToPlayerSubmit() {
            this.$nextTick(() => {
                if (this.$refs.playeridinput.classList.contains("active")) {
                    this.$refs.vehiclecodeinput2.focus();
                    this.$refs.vehiclecodeinput2.classList.add("active");
                    this.$refs.playeridinput.classList.remove("active");
                } else if (this.$refs.vehiclecodeinput2.classList.contains("active")) {
                    this.$refs.playeridinput.focus();
                    this.$refs.playeridinput.classList.add("active");
                    this.$refs.vehiclecodeinput2.classList.remove("active");
                }
            });
        },
        addItemModalSubmit() {
            this.$nextTick(() => {
                if (this.$refs.addItemNameInput.classList.contains("activeadditem")) {
                    this.$refs.addItemCountInput.focus();
                    this.$refs.addItemCountInput.classList.add("activeadditem");
                    this.$refs.addItemNameInput.classList.remove("activeadditem");
                } else if (this.$refs.addItemCountInput.classList.contains("activeadditem")) {
                    this.$refs.addItemNameInput.focus();
                    this.$refs.addItemNameInput.classList.add("activeadditem");
                    this.$refs.addItemCountInput.classList.remove("activeadditem");
                }
            });
        },
        addMoneyModalSubmit() {
            this.$nextTick(() => {
                if (this.$refs.addMoneyCashInput.classList.contains("activeaddmoney")) {
                    this.$refs.addMoneyBankInput.focus();
                    this.$refs.addMoneyBankInput.classList.add("activeaddmoney");
                    this.$refs.addMoneyCashInput.classList.remove("activeaddmoney");
                } else if (this.$refs.addMoneyBankInput.classList.contains("activeaddmoney")) {
                    this.$refs.addMoneyCashInput.focus();
                    this.$refs.addMoneyCashInput.classList.add("activeaddmoney");
                    this.$refs.addMoneyBankInput.classList.remove("activeaddmoney");
                }
            });
        },
        banPlayerModalSubmit() {
            this.$nextTick(() => {
                if (this.$refs.banTextModelInput.classList.contains("activeban")) {
                    this.$refs.banTimeInput.focus();
                    this.$refs.banTimeInput.classList.add("activeban");
                    this.$refs.banTextModelInput.classList.remove("activeban");
                } else if (this.$refs.banTimeInput.classList.contains("activeban")) {
                    this.$refs.banTextModelInput.focus();
                    this.$refs.banTextModelInput.classList.add("activeban");
                    this.$refs.banTimeInput.classList.remove("activeban");
                }
            });
        },

        handleDownArrow() {
            clicksound("tiz-button.mp3");
            if (this.modalData.changeJobModal) {
                this.changeJobModalSubmitDown();
                return;
            }
            if (this.modalData.searchBanModal) {
                this.searchBanModalSubmitUp("down");
                return;
            }
            if (this.modalData.addvehicletoplayer) {
                this.addVehicleToPlayerSubmit();
                return;
            }
            if (this.modalData.addItemModal) {
                this.addItemModalSubmit();
                return;
            }
            if (this.modalData.addMoneyModal) {
                this.addMoneyModalSubmit();
                return;
            }
            if (this.modalData.banModal) {
                this.banPlayerModalSubmit();
                return;
            }
            if (this.disableArrowKeyboard) {
                return;
            }

            if (this.$refs.searchbaradmin && this.$refs.searchbaradmin.length > 0) {
                this.$refs.searchbaradmin[0].blur();
            }
            if (this.modalData.bannedPlayersModal) {
                this.selectedIndexBannedPlayers =
                    this.selectedIndexBannedPlayers < this.bannedPlayers.length - 1 ? this.selectedIndexBannedPlayers + 1 : 0;
                return;
            }
            if (this.permissionSelected) {
                this.selectedIndexPermissionCategoryElement =
                    this.selectedIndexPermissionCategoryElement < this.allowPermission.length - 1
                        ? this.selectedIndexPermissionCategoryElement + 1
                        : 0;

                this.scrollToItem();
                return;
            }
            if (this.playerSelected) {
                this.playerSelectedIndex = this.playerSelectedIndex < this.playerModalOption.length - 1 ? this.playerSelectedIndex + 1 : 0;

                this.scrollToItem();
                return;
            }
            if (this.weatherSelected) {
                this.selectedIndexCategoryElement =
                    this.selectedIndexCategoryElement < this.weatherModalOption.length - 1 ? this.selectedIndexCategoryElement + 1 : 0;

                this.scrollToItem();
                return;
            }
            if (this.hasCategoryElements()) {
                this.selectedIndexCategoryElement =
                    this.selectedIndexCategoryElement < this.categoryElements.length - 1 ? this.selectedIndexCategoryElement + 1 : 0;
                this.scrollToItem();
            } else {
                this.selectedIndexMainCategory =
                    this.selectedIndexMainCategory < this.mainCategory.length - 1 ? this.selectedIndexMainCategory + 1 : 0;
                this.scrollToItem();
            }
        },
        async handleEnter() {
            clicksound("tiz-button.mp3");
            if (this.modalData.unbanModal) {
                if (this.selectBannedPlayersData) {
                    postNUI("unbanPlayer", this.selectBannedPlayersData.profiledata.identifier);
                    this.modalData.unbanModal = false;
                    this.selectedIndexBannedPlayers = 0;
                    this.selectBannedPlayersData = false;
                    let response = await postNUI("bannedPlayers");
                    this.bannedPlayers = [];
                    setTimeout(() => {
                        this.modalData.bannedPlayersModal = true;
                        this.bannedPlayers = response;
                    }, 1000);
                }

                return;
            }

            if (this.modalData.bannedPlayersModal) {
                this.modalData.unbanModal = true;
                this.selectBannedPlayersData = this.bannedPlayers[this.selectedIndexBannedPlayers];
                return;
            }

            if (this.offlineBanData.length > 0) {
                if (!this.modalData.banModal) {
                    this.modalData.searchBanModal = false;
                    this.modalData.banModal = true;
                    this.$nextTick(() => {
                        if (this.$refs.banTextModelInput) {
                            this.$refs.banTextModelInput.focus();
                        }
                    });
                    return;
                } else {
                    postNUI("offlineBanData", {
                        functiondata: "CodemAdminMenuOfflineBan",
                        playeridentifier: this.offlineBanData[this.selectedBanIndex].profiledata.identifier,
                        reason: this.inputData.banTextModel.replace(/\n/g, ""),
                        time: this.banSettings[this.selectedIndexBanSettings]
                    });
                    this.modalData.banModal = false;
                    this.inputData.searchBanText = "";
                    this.selectedBanIndex = 0;
                    this.modalData.searchBanModal = false;
                    this.offlineBanData = [];
                    this.disableArrowKeyboard = false;
                    return;
                }
                return;
            }
            if (this.modalData.searchBanModal) {
                if (this.inputData.searchBanText.length > 0) {
                    this.offlineBanData = [];
                    let result = await postNUI("searchBan", this.inputData.searchBanText);
                    if (result.length > 0) {
                        this.offlineBanData = result;
                        this.inputData.searchBanText = "";
                        this.selectedBanIndex = 0;
                    } else {
                        this.notification("No result found", "notification");
                        this.inputData.searchBanText = "";
                        this.selectedBanIndex = 0;
                    }
                    return;
                }
            }

            if (this.announcementModal) {
                let data = {
                    name: "announcement",
                    text: this.announementTextModel.replace(/\n/g, ""),
                    functionname: "CodemAdminMenuAnnouncement"
                };
                postNUI("adminOptions", data);
                this.announementTextModel = "";
                this.announcementModal = false;
                this.disableArrowKeyboard = false;
                return;
            }
            if (this.modalData.givevehicle) {
                let data = {
                    name: "givevehicle",
                    text: this.inputData.giveVehicleName,
                    functionname: "CodemAdminMenuGiveVehicle"
                };
                postNUI("adminOptions", data);
                this.disableArrowKeyboard = false;
                this.modalData.givevehicle = false;
                this.inputData.giveVehicleName = "";
                return;
            }
            if (this.modalData.addvehicletoplayer) {
                let data = {
                    name: "addvehicletoplayer",
                    text: {
                        name: this.inputData.giveVehicleName,
                        id: this.inputData.playerId
                    },
                    functionname: "CodemAdminMenuGiveVehicleToPlayer"
                };
                postNUI("adminOptions", data);
                this.disableArrowKeyboard = false;
                this.modalData.addvehicletoplayer = false;
                this.inputData.giveVehicleName = "";
                this.inputData.playerId = false;
                return;
            }
            if (this.permissionSelected) {
                let data = {
                    name: this.allowPermission[this.selectedIndexPermissionCategoryElement].name,
                    value: this.allowPermission[this.selectedIndexPermissionCategoryElement].enabled,
                    playerid: this.lastPlayerData.id
                };
                postNUI("adminOptionsPermission", data);
                return;
            }
            if (this.weatherSelected) {
                let data = {
                    functionname: "CodemAdminMenuWeather",
                    name: "weather",
                    value: this.weatherModalOption[this.selectedIndexCategoryElement].name
                };
                postNUI("adminOptions", data);
                return;
            }

            if (this.playerSelected) {
                this.selectMenuItem2(this.playerModalOption[this.playerSelectedIndex]);
                return;
            }
            if (this.hasCategoryElements()) {
                this.selectMenuItem2(this.categoryElements[this.selectedIndexCategoryElement]);
            } else {
                this.selectMenuItem(this.mainCategory[this.selectedIndexMainCategory]);
            }
        },
        handleRightArrow() {
            if (this.modalData.banModal) {
                clicksound("tiz-button.mp3");
                this.selectedIndexBanSettings = this.selectedIndexBanSettings < this.banSettings.length - 1 ? this.selectedIndexBanSettings + 1 : 0;
            }

            if (this.disableArrowKeyboard) {
                return;
            }
            clicksound("tiz-button.mp3");
            if (this.categoryPage == "serveroption") {
                let time = this.categoryElements[this.selectedIndexCategoryElement].name;
                if (time == "servertime") {
                    clicksound("tiz-button.mp3");
                    this.serverTime = this.serverTime + 1;
                    if (this.serverTime > 23) {
                        this.serverTime = 0;
                    }
                }
                if (time == "clearvehicle") {
                    clicksound("tiz-button.mp3");
                    this.vehicleDeleteDisantance = this.vehicleDeleteDisantance + 5;
                }
            }
        },
        handleLeftArrow() {
            if (this.modalData.banModal) {
                clicksound("tiz-button.mp3");
                this.selectedIndexBanSettings = this.selectedIndexBanSettings > 0 ? this.selectedIndexBanSettings - 1 : this.banSettings.length - 1;
            }
            if (this.disableArrowKeyboard) {
                return;
            }
            clicksound("tiz-button.mp3");
            if (this.categoryPage == "serveroption") {
                let time = this.categoryElements[this.selectedIndexCategoryElement].name;
                if (time == "servertime") {
                    clicksound("tiz-button.mp3");
                    this.serverTime = this.serverTime - 1;
                    if (this.serverTime < 0) {
                        this.serverTime = 23;
                    }
                }
                if (time == "clearvehicle") {
                    clicksound("tiz-button.mp3");
                    this.vehicleDeleteDisantance = this.vehicleDeleteDisantance - 5;
                    if (this.vehicleDeleteDisantance < 5) {
                        this.vehicleDeleteDisantance = 5;
                    }
                }
            }
        },
        handleDelete() {
            clicksound("tiz-button.mp3");

            if (this.modalData.changeJobModal) {
                this.clearInputData("changeJob", "changeJobModal");
            } else if (this.modalData.addItemModal) {
                this.clearInputData("addItem", "addItemModal");
            } else if (this.modalData.addMoneyModal) {
                this.clearInputData("addMoney", "addMoneyModal");
            } else if (this.modalData.addvehicletoplayer) {
                this.clearInputData("addvehicletoplayer", "addvehicletoplayer");
            } else if (this.modalData.givevehicle) {
                this.clearInputData("givevehicle", "givevehicle");
            } else if (this.modalData.sendPMModal) {
                this.clearInputData("sendPM", "sendPMModal");
            } else if (this.modalData.kickModal) {
                this.clearInputData("kick", "kickModal");
            } else if (this.announcementModal) {
                this.clearInputData("announcement");
            } else if (this.modalData.banModal) {
                this.clearInputData("ban", "banModal");
                this.modalData.searchBanModal = false;
                this.inputData.searchBanText = "";
                this.modalData.banModal = false;
                this.inputData.searchBanText = "";
                this.selectedBanIndex = 0;
                this.offlineBanData = [];
            } else if (this.modalData.searchBanModal) {
                this.clearInputData("searchban", "searchBanModal");
            } else if (this.modalData.unbanModal) {
                this.modalData.unbanModal = false;
                this.disableArrowKeyboard = true;
            }
        },

        clearInputData(modalType, modalDataName) {
            const inputFields = {
                changeJob: ["changeJobName", "changeJobGrade"],
                addItem: ["addItemName", "addItemCount"],
                addMoney: ["addMoneyCash", "addMoneyBank"],
                addvehicletoplayer: ["giveVehicleName", "playerId"],
                givevehicle: ["giveVehicleName"],
                sendPM: ["sendPmText"],
                kick: ["kickTextModel"],
                ban: ["banTextModel"],
                searchban: ["searchBanText"],
                announcement: ["announementTextModel"]
            };

            inputFields[modalType].forEach(field => {
                this.inputData[field] = "";
            });

            this.modalData[modalDataName] = false;
            this.announcementModal = false;
            this.disableArrowKeyboard = false;
        },
        handleBackspace() {
            if (this.modalData.unbanModal) {
                return;
            }
            if (this.modalData.givevehicle) {
                return;
            }
            if (this.modalData.addvehicletoplayer) {
                return;
            }

            if (this.modalData.bannedPlayersModal) {
                this.modalData.bannedPlayersModal = false;
                this.disableArrowKeyboard = false;
                return;
            }

            if (this.categoryPage == "playeroption") {
                if (this.permissionSelected) {
                    this.permissionSelected = false;
                    return;
                }
            }
            if (this.modalData.searchBanModal) {
                return;
            }

            var dummyEl = document.querySelector("input");
            var isFocused = document.activeElement === dummyEl;
            if (isFocused) {
                if (this.searchBarAdmin.length <= 0) {
                    var focusedElement = document.querySelector("input");
                    if (focusedElement) {
                        focusedElement.blur();
                    }
                }
                return;
            }
            if (this.isAnyModalActive()) {
                return;
            }
            this.closeModalsAndResetState();
        },

        isAnyModalActive() {
            return (
                (this.searchBarAdmin && this.searchBarAdmin.length > 0) ||
                this.announcementModal ||
                Object.values(this.modalData).some(value => value)
            );
        },

        closeModalsAndResetState() {
            if (this.playerInfoModal) {
                this.playerInfoModal = false;
                this.disableArrowKeyboard = false;
                return;
            }
            if (this.playerSelected) {
                this.playerSelected = false;
                return;
            }

            if (this.categoryPage === "main") {
                this.spaceCount++;
                if (this.spaceCount >= 2) {
                    this.closeMenu();
                }
            } else {
                this.resetCategorySelection();
            }
        },

        closeMenu() {
            this.show = false;
            this.spaceCount = 0;
            postNUI("closeMenu");
        },

        resetCategorySelection() {
            this.playerInfoModal = this.permissionSelected = this.playerSelected = this.weatherSelected = false;
            this.disableArrowKeyboard = false;
            this.categoryElements = [];
            this.categoryPage = "main";
            this.selectedIndexCategoryElement = 0;
        },
        hasCategoryElements() {
            return this.categoryElements && this.categoryElements.length > 0;
        },
        async selectMenuItem2(item) {
            if (item && item.player) {
                this.lastPlayerData = item;
            }

            // console.log("select menu item 2", JSON.stringify(item));
            if (this.playerSelected) {
                if (item.name == "permission") {
                    this.permissionSelected = true;
                    return;
                }
                if (item.name == "sendpm") {
                    if (!this.modalData.sendPMModal) {
                        this.modalData.sendPMModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.sendpmtextarea) {
                                this.$refs.sendpmtextarea.focus();
                            }
                        });
                    } else {
                        if (this.inputData.sendPmText.length <= 1) {
                            this.notification("Type something....", "notification");
                            return;
                        }
                        if (this.inputData.sendPmText.length > 0) {
                            this.modalData.sendPMModal = false;
                            this.disableArrowKeyboard = false;
                            postNUI("adminPlayerOptions", {
                                functiondata: item,
                                playerid: this.lastPlayerData.id,
                                pm: this.inputData.sendPmText
                            });
                            this.inputData.sendPmText = "";
                        }
                    }
                    return;
                }
                if (item.name == "addmoney") {
                    if (!this.modalData.addMoneyModal) {
                        this.modalData.addMoneyModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.addMoneyCashInput) {
                                this.$refs.addMoneyCashInput.focus();
                            }
                        });
                    } else {
                        if (
                            (this.inputData.addMoneyCash.length == 0 && this.inputData.addMoneyBank.length == 0) ||
                            (this.inputData.addMoneyCash.length > 0 && this.inputData.addMoneyBank.length > 0)
                        ) {
                            this.notification("You can enter at most one parameter", "notification");
                            return;
                        }
                        if (this.inputData.addMoneyCash.length > 0) {
                            this.modalData.addMoneyModal = false;
                            this.disableArrowKeyboard = false;
                            postNUI("adminPlayerOptions", {
                                functiondata: item,
                                playerid: this.lastPlayerData.id,
                                moneyData: {
                                    name: "cash",
                                    count: this.inputData.addMoneyCash
                                }
                            });
                            this.inputData.addMoneyCash = "";
                        }
                        if (this.inputData.addMoneyBank.length > 0) {
                            this.modalData.addMoneyModal = false;
                            this.disableArrowKeyboard = false;
                            postNUI("adminPlayerOptions", {
                                functiondata: item,
                                playerid: this.lastPlayerData.id,
                                moneyData: {
                                    name: "bank",
                                    count: this.inputData.addMoneyBank
                                }
                            });

                            this.inputData.addMoneyBank = "";
                        }
                    }
                    return;
                }
                if (item.name == "giveitem") {
                    if (!this.modalData.addItemModal) {
                        this.modalData.addItemModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.addItemNameInput) {
                                this.$refs.addItemNameInput.focus();
                            }
                        });
                    } else {
                        this.modalData.addItemModal = false;
                        this.disableArrowKeyboard = false;

                        if (this.inputData.addItemName.length > 0 && this.inputData.addItemCount.length > 0) {
                            postNUI("adminPlayerOptions", {
                                functiondata: item,
                                playerid: this.lastPlayerData.id,
                                itemData: {
                                    name: this.inputData.addItemName,
                                    count: this.inputData.addItemCount
                                }
                            });

                            this.inputData.addItemName = "";
                            this.inputData.addItemCount = "";
                        }
                    }

                    return;
                }
                if (item.name == "ban") {
                    if (!this.modalData.banModal) {
                        this.modalData.banModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.banTextModelInput) {
                                this.$refs.banTextModelInput.focus();
                            }
                        });
                    } else {
                        this.modalData.banModal = false;
                        this.disableArrowKeyboard = false;

                        postNUI("adminPlayerOptions", {
                            functiondata: item,
                            playerid: this.lastPlayerData.id,
                            reason: this.inputData.banTextModel.replace(/\n/g, ""),
                            time: this.banSettings[this.selectedIndexBanSettings]
                        });
                        this.inputData.banTextModel = "";
                    }

                    return;
                }
                if (item.name == "kick") {
                    if (!this.modalData.kickModal) {
                        this.modalData.kickModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.kicktextarea) {
                                this.$refs.kicktextarea.focus();
                            }
                        });
                    } else {
                        this.modalData.kickModal = false;
                        this.disableArrowKeyboard = false;

                        postNUI("adminPlayerOptions", {
                            functiondata: item,
                            playerid: this.lastPlayerData.id,
                            reason: this.inputData.kickTextModel.replace(/\n/g, "")
                        });
                        this.inputData.kickTextModel = "";
                    }

                    return;
                }

                if (item.name == "changejob") {
                    if (!this.modalData.changeJobModal) {
                        this.modalData.changeJobModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.changeJobNameInput) {
                                this.$refs.changeJobNameInput.focus();
                            }
                        });
                    } else {
                        this.modalData.changeJobModal = false;
                        this.disableArrowKeyboard = false;

                        if (this.inputData.changejobName.length > 0 && this.inputData.changejobGrade.length > 0) {
                            postNUI("adminPlayerOptions", {
                                functiondata: item,
                                playerid: this.lastPlayerData.id,
                                jobData: {
                                    name: this.inputData.changejobName,
                                    grade: this.inputData.changejobGrade
                                }
                            });

                            this.inputData.changejobName = "";
                            this.inputData.changejobGrade = "";
                        }
                    }

                    return;
                }

                if (item.name == "playerinfo") {
                    let response = await postNUI("playerInfo", this.lastPlayerData.id);
                    if (response == false) {
                        this.playerInfoModal = false;
                        return;
                    }
                    this.playerInfoModal = true;
                    this.disableArrowKeyboard = true;
                    this.playerInfoPlayerData = response;
                    return;
                }
                postNUI("adminPlayerOptions", {
                    functiondata: item,
                    playerid: this.lastPlayerData.id
                });
            }
            if (this.categoryPage == "playeroption") {
                if (item.name == "searchbarplayer") {
                    this.$nextTick(() => {
                        if (this.$refs.searchbarplayer && this.$refs.searchbarplayer.length > 0) {
                            this.$refs.searchbarplayer[0].focus();
                        }
                    });
                    return;
                }

                this.selectedIndexCategoryElement = 0;
                this.playerSelected = true;
            }
            if (this.categoryPage == "adminoption") {
                if (item.name == "bannedplayers") {
                    let response = await postNUI("bannedPlayers");
                    this.modalData.bannedPlayersModal = true;
                    this.bannedPlayers = response;
                    return;
                }
                if (item.name == "searchbaradmin") {
                    if (this.$refs.searchbaradmin && this.$refs.searchbaradmin.length > 0) {
                        this.$refs.searchbaradmin[0].focus();
                    }
                    return;
                }
                if (item.name == "announcement") {
                    this.announcementModal = !this.announcementModal;
                    if (this.announcementModal) {
                        this.$nextTick(() => {
                            this.disableArrowKeyboard = true;
                            if (this.$refs.announcementtextarea) {
                                this.$refs.announcementtextarea.focus();
                            }
                        });
                    }
                    return;
                }
                if (item.name == "offlineban") {
                    this.modalData.searchBanModal = true;
                    this.disableArrowKeyboard = true;
                    this.$nextTick(() => {
                        if (this.$refs.searchbanTextModelInput) {
                            this.$refs.searchbanTextModelInput.focus();
                        }
                    });

                    return;
                }
                if (item.name == "allkick") {
                    if (!this.modalData.kickModal) {
                        this.modalData.kickModal = true;
                        this.disableArrowKeyboard = true;
                        this.$nextTick(() => {
                            if (this.$refs.kicktextarea) {
                                this.$refs.kicktextarea.focus();
                            }
                        });
                    } else {
                        this.modalData.kickModal = false;
                        this.disableArrowKeyboard = false;

                        postNUI("adminOptions", {
                            functiondata: item,
                            reason: this.inputData.kickTextModel.replace(/\n/g, "")
                        });
                        this.inputData.kickTextModel = "";
                    }

                    return;
                }
                postNUI("adminOptions", item);
            }
            if (this.categoryPage == "serveroption") {
                if (item.name == "weather") {
                    this.weatherSelected = true;
                    this.selectedIndexCategoryElement = 0;
                    return;
                }
                if (item.name == "servertime") {
                    postNUI("adminOptions", {
                        functionname: "CodemAdminMenuTime",
                        name: "servertime",
                        value: this.serverTime
                    });
                    return;
                }
                if (item.name == "clearvehicle") {
                    postNUI("adminOptions", {
                        functionname: "CodemAdminMenuClearVehicle",
                        name: "clearvehicle",
                        value: this.vehicleDeleteDisantance
                    });
                    return;
                }
                postNUI("adminOptions", item);
            }
            if (this.categoryPage == "vehicleoption") {
                if (item.name == "givevehicle" || item.name == "addvehicletoplayer") {
                    this.modalData[item.modal] = true;
                    this.$nextTick(() => {
                        if (this.$refs.vehiclecodeinput) {
                            this.disableArrowKeyboard = true;
                            this.$refs.vehiclecodeinput.focus();
                        }
                        if (this.$refs.playeridinput) {
                            this.disableArrowKeyboard = true;
                            this.$refs.playeridinput.focus();
                        }
                    });
                    return;
                }
                postNUI("adminOptions", item);
            }
            if (this.categoryPage == "developeroption") {
                postNUI("adminOptions", item);
            }
        },

        scrollToItem() {
            if (this.playerSelected) {
                if (this.permissionSelected) {
                    const ContainerItem2 =
                        document.querySelectorAll(".category-element-permissionoption")[this.selectedIndexPermissionCategoryElement];
                    if (ContainerItem2) {
                        ContainerItem2.scrollIntoView({
                            behavior: "smooth",
                            block: "center"
                        });
                    }
                    return;
                }
                const ContainerItem = document.querySelectorAll(".category-element-playeroption")[this.playerSelectedIndex];
                if (ContainerItem) {
                    ContainerItem.scrollIntoView({
                        behavior: "smooth",
                        block: "center"
                    });
                }

                return;
            } else {
                const menuItem = document.querySelectorAll(".menu-item")[this.selectedIndexMainCategory];
                if (menuItem) {
                    menuItem.scrollIntoView({
                        behavior: "smooth",
                        block: "center"
                    });
                }
                const CategoryItems = document.querySelectorAll(".category-element")[this.selectedIndexCategoryElement];
                if (CategoryItems) {
                    CategoryItems.scrollIntoView({
                        behavior: "smooth",
                        block: "center"
                    });
                }
            }
        },
        selectMenuItem(item) {
            this.categoryPage = item.name;
            this.activeMenuName = item.label;
            this.categoryElements = item.elements;
        },
        copyPlayerInfo(text) {
            this.copy(text);
        },
        copy(text) {
            const el = document.createElement("textarea");
            el.value = text;
            document.body.appendChild(el);
            el.select();
            document.execCommand("copy");
            document.body.removeChild(el);
            this.notification(`${text} is copied to clipboard.`, "notification");
        },
        eventHandler(event) {
            switch (event.data.action) {
                case "CHECK_NUI":
                    postNUI("loaded");
                    break;
                case "copy":
                    this.copy(event.data.payload);
                    break;
                case "showCoords":
                    this.showCoords = event.data.payload;
                    break;
                case "toggleLaser":
                    this.showLaser = event.data.payload;
                case "setCoords":
                    this.coords.value = event.data.payload.coords;
                    this.coords.heading = event.data.payload.heading;

                    break;
                case "openMenu":
                    this.show = true;
                    this.playerData = event.data.payload.playerData;
                    this.onlineOverviews.forEach(overview => (overview.count = 0));
                    this.mainCategory.find(obj => {
                        if (obj.name === "playeroption") {
                            const searchBarPlayer = obj.elements.find(element => element.name === "searchbarplayer");
                            let players = Object.values(event.data.payload.onlinePlayersData).map(player => {
                                const jobOverview = this.onlineOverviews.find(overview => overview.name === player.job);
                                if (jobOverview) {
                                    jobOverview.count += 1;
                                }
                                return {
                                    name: player.name,
                                    id: player.id,
                                    identifier: player.identifier,
                                    player: true,
                                    avatar: player.avatar,
                                    permissiondata: player.permissiondata,
                                    job: player.job,
                                    jobicon: player.jobicon
                                };
                            });
                            players.sort((a, b) => a.id - b.id);
                            obj.elements = [searchBarPlayer, ...players];
                            this.onlinePlayersCount = obj.elements.length - 1;
                        }
                    });

                    break;
                case "loadData":
                    this.onlineOverviews.forEach(overview => (overview.count = 0));

                    this.mainCategory.find(obj => {
                        if (obj.name === "playeroption") {
                            const searchBarPlayer = obj.elements.find(element => element.name === "searchbarplayer");

                            let players = Object.values(event.data.payload).map(player => {
                                const jobOverview = this.onlineOverviews.find(overview => overview.name === player.job);
                                if (jobOverview) {
                                    jobOverview.count += 1;
                                }

                                return {
                                    name: player.name,
                                    id: player.id,
                                    identifier: player.identifier,
                                    player: true,
                                    avatar: player.avatar,
                                    permissiondata: player.permissiondata,
                                    job: player.job,
                                    jobicon: player.jobicon
                                };
                            });

                            players.sort((a, b) => a.id - b.id);

                            obj.elements = [searchBarPlayer, ...players];
                        }
                    });

                    break;
                case "UPDATE_PLAYER_PERMISSION":
                    let targetIdentifier = event.data.payload.identifier;
                    let targetPermission = event.data.payload.permissiondata;
                    if (this.lastPlayerData.identifier === targetIdentifier) {
                        this.lastPlayerData.permissiondata = targetPermission;
                    }
                    this.mainCategory.forEach(obj => {
                        if (obj.name === "playeroption") {
                            const searchBarPlayer = obj.elements.find(element => element.name === "searchbarplayer");
                            const updatedElements = obj.elements.map(player => {
                                if (player.identifier === targetIdentifier) {
                                    return {
                                        ...player,
                                        permissiondata: {
                                            ...player.permissiondata,
                                            ...targetPermission
                                        }
                                    };
                                } else {
                                    return player;
                                }
                            });
                            obj.elements = [searchBarPlayer, ...updatedElements];
                        }
                    });
                    break;
                case "setAdminCheckedData":
                    if (this.playerCheckedData[event.data.payload.name] !== undefined) {
                        this.playerCheckedData[event.data.payload.name] = event.data.payload.value;
                    }
                    break;
                case "NOTIFICATION":
                    this.notification(event.data.payload.message, event.data.payload.value);
                    break;
                case "ItemImagesFolder":
                    this.ItemImagesFolder = event.data.payload;
                    break;
                case "setEntityViewModeType":
                    this.entityViewModeType = event.data.payload;
                    break;
                case "setEntityViewModeInfo":
                    event.data.payload.elements.forEach(data => {
                        let laserInfo = this.laserInfo[event.data.payload.type].elements.find(el => el.name == data.name);
                        if (laserInfo) {
                            laserInfo.value = data.value;
                        }
                    });
                    break;
                case "CONFIG_ALLOWPERM":
                    this.allowPermission = event.data.payload;
                    break;
                case "CONFIG_LOCALES":
                    this.Locales = event.data.payload;
                    break;
                case "CONFIG_ONLINEOVER":
                    this.onlineOverviews = event.data.payload;
                    break;
                case "CONFIG_PLAYERINFO":
                    this.playerInfoCategory = event.data.payload;
                    break;
                case "CONFIG_PLAYEROPTIONS":
                    this.playerModalOption = event.data.payload;
                    break;
                case "CONFIG_BANSETTINGS":
                    this.banSettings = event.data.payload;
                    break;
                case "CONFIG_LASERINFO":
                    this.laserInfo = event.data.payload;
                    break;
                case "CONFIG_NOCLIP":
                    this.noclipKeyBind = event.data.payload;
                    break;
                case "CONFIG_WEATHER":
                    this.weatherModalOption = event.data.payload;
                    break;
                case "CONFIG_LASERKEYBIND":
                    this.laserKeyBind = event.data.payload;
                    break;
                case "maincategory":
                    this.mainCategory = event.data.payload;
                    break;
                default:
                    break;
            }
        }
    }
});

app.use(store).mount("#app");
var resourceName = "codem-adminmenu";

if (window.GetParentResourceName) {
    resourceName = window.GetParentResourceName();
}

window.postNUI = async (name, data) => {
    try {
        const response = await fetch(`https://${resourceName}/${name}`, {
            method: "POST",
            mode: "cors",
            cache: "no-cache",
            credentials: "same-origin",
            headers: {
                "Content-Type": "application/json"
            },
            redirect: "follow",
            referrerPolicy: "no-referrer",
            body: JSON.stringify(data)
        });
        return !response.ok ? null : response.json();
    } catch (error) {
        // console.log(error)
    }
};

function clicksound(val) {
    let audioPath = `./sound/${val}`;
    audioPlayer = new Howl({
        src: [audioPath]
    });
    audioPlayer.volume(0.7);
    audioPlayer.play();
}

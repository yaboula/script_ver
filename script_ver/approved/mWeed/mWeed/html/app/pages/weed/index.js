import importTemplate from '../../utils/importTemplate.js'
import menuheader from '../../components/header.js'
import process from '../../components/process.js'
import progressbar from '../../components/progressbar.js'

export default {
    data() {
        return {
            selectedField: {
                block: false,
                index: false,
                nearArea: false,
                tempBlock: false,
                tempIndex: false
            },
            progressbar: {
                text: false,
                time: false,
                remainTime: false,
                interval: false,
                percentage: false,
            },
            weedData: {},
            items: {
                ["2"]: [
                    "fertilizer",
                    "quality_fertilizer",
                ],
                ["3"]: [
                    "indica_seed",
                    "sativa_seed",
                ]
            },
            selectedItem: 0,
        }
    },
    components: {
        menuheader,
        process,
        progressbar
    },
    computed: {
        ...Vuex.mapState({
            translation : state => state.translation,
            itemNames : state => state.itemNames,

        }),
        weedTranslation(){
            return this.translation["WEED"]
        },
        GetSelectedWeedData() {
            if (this.selectedField.block &&
                this.selectedField.index) {
                return this.weedData?.[this.selectedField.block]?.[this.selectedField.index.toString()]
            }

            return false
        },
        GetCompletedProgress() {
            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.growth != false) {
                    return this.GetSelectedWeedData.growth
                }
                return this.GetSelectedWeedData.currentProgress
            }

            return 1
        },
        GetProgressImg() {
            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.growth != false) {
                    return `./assets/images/weed-growth-${this.GetSelectedWeedData.growth}.png`
                }
                return `./assets/images/plant-process-${this.GetSelectedWeedData.currentProgress}.png`
            }
            return './assets/images/dirt.png'
        },
        GetRequiredItemImage() {
            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.currentProgress == 2) {
                    if (this.items["2"][this.selectedItem] == 'fertilizer') {
                        return [`./assets/item_images/${this.itemNames['fertilizer'].name}.png`, this.itemNames['fertilizer'].label]
                    } else if (this.items["2"][this.selectedItem] == 'quality_fertilizer') {
                        return [`./assets/item_images/${this.itemNames['quality_fertilizer'].name}.png`, this.itemNames['quality_fertilizer'].label]
                    }
                } else if (this.GetSelectedWeedData.currentProgress == 3) {
                    if (this.items["3"][this.selectedItem] == 'indica_seed') {
                        return [`./assets/item_images/${this.itemNames['indica_seed'].name}.png`, this.itemNames['indica_seed'].label]
                    } else if (this.items["3"][this.selectedItem] == 'sativa_seed') {
                        return [`./assets/item_images/${this.itemNames['sativa_seed'].name}.png`, this.itemNames['sativa_seed'].label]
                    }
                } else if (this.GetSelectedWeedData.currentProgress == 4) {
                    return [`./assets/item_images/${this.itemNames['grubber'].name}.png`, this.itemNames['grubber'].label]
                }
            }
            return [`./assets/item_images/${this.itemNames['grubber'].name}.png`, this.itemNames['grubber'].label]
        },
        GetProgressLabel() {

            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.currentProgress == 2) {
                    return this.weedTranslation["POUR"]

                }
                if (this.GetSelectedWeedData.currentProgress == 3) {
                    return this.weedTranslation["PUT_SEED"]

                }
                if (this.GetSelectedWeedData.currentProgress == 4) {
                    return this.weedTranslation["CLOSE_AREA"]
                }

            }

            return this.weedTranslation["DIG"] 
        },
        GetProgressDesc() {
            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.currentProgress == 2) {
                    return this.weedTranslation["PROGRESS_DESC_2"]

                }
                if (this.GetSelectedWeedData.currentProgress == 3) {
                    return this.weedTranslation["PROGRESS_DESC_3"]

                }
                if (this.GetSelectedWeedData.currentProgress == 4) {
                    return this.weedTranslation["PROGRESS_DESC_4"]
                }
            }
            return this.weedTranslation["PROGRESS_DESC_1"]
        },
        GetProgressTitle() {

            if (this.GetSelectedWeedData) {
                if (this.GetSelectedWeedData.growth != false) {
                    return this.weedTranslation["GROWTH"]
                }
                return this.weedTranslation["PLANT_PROCESS"]
            }

            return this.weedTranslation["PLANT_PROCESS"]
        },

    },
    methods: {
        ...Vuex.mapMutations({
            SetShowDestroyModal: 'SetShowDestroyModal',
            SetSeedType : 'SetSeedType',
        }),
        GetWeedDataByIndex(block, index) {
            return this.weedData?.[block]?.[index.toString()]
        },
        GetWeedClass(block, index) {
            return {
                active: (this.selectedField.block == block && index == this.selectedField.index),
                temp: this.selectedField.tempBlock == block && index == this.selectedField.tempIndex,
                blue: this.GetWeedDataByIndex(block, index) ? this.GetWeedDataByIndex(block, index).water <= 2 ? true : false : false,
                green: this.GetWeedDataByIndex(block, index) ? this.GetWeedDataByIndex(block, index).flounder <= 2 ? true : false : false,
                completed: this.GetWeedDataByIndex(block, index) ? this.GetWeedDataByIndex(block, index).growth >= 4 ? true : false : false,
            }
        },
        GetWeedImg(block, index) {
            if(this.GetWeedDataByIndex(block, index) && this.GetWeedDataByIndex(block, index).growth >= 4){
                return "./assets/images/weed-icon-completed.png"
            }
             
            if (this.selectedField.tempBlock == block && index == this.selectedField.tempIndex) {
                return "./assets/images/selected-weed-icon.png"
            }
            if ((this.selectedField.block == block && index == this.selectedField.index)) {
                return "./assets/images/selected-weed-icon.png"
            }

            if (this.GetWeedDataByIndex(block, index)) {
                return "./assets/images/selected-weed-icon.png"
            }

            return './assets/images/weed-icon.png'
        },
        NextItem() {
            if (this.GetSelectedWeedData && this.items[this.GetSelectedWeedData.currentProgress.toString()]) {
                this.selectedItem += 1
                if (this.selectedItem > this.items[this.GetSelectedWeedData.currentProgress.toString()].length - 1) {
                    this.selectedItem = 0
                }
            }

        },
        PrevItem() {
            if (this.GetSelectedWeedData && this.items[this.GetSelectedWeedData.currentProgress.toString()]) {
                this.selectedItem -= 1
                if (this.selectedItem < 0) {
                    this.selectedItem = this.items[this.GetSelectedWeedData.currentProgress.toString()].length - 1
                }
            }
        },
        async SelectField(block, index) {
            this.selectedField.nearArea = false
            this.selectedField.block = false
            this.selectedField.index = false    
            this.selectedField.tempBlock = block
            this.selectedField.tempIndex = index
            const nearArea = await postNUI('selectField', {
                block,
                index
            })

            this.selectedField.nearArea = nearArea
            if (nearArea) {
                this.selectedField.block = block
                this.selectedField.index = index             
            }
            this.selectedField.tempBlock = false
            this.selectedField.tempIndex = false

        },
        WeedAction(actionType) {
            postNUI('weedAction', {
                actionType: this.GetSelectedWeedData && this.GetSelectedWeedData.growth == false  ? this.GetSelectedWeedData.currentProgress : actionType,
                requiredItem: (this.GetSelectedWeedData && this.GetSelectedWeedData.growth == false) ? this.items[this.GetSelectedWeedData?.currentProgress?.toString()]?.[this.selectedItem] : false,
            })
        },
        messageHandler(event) {
            switch (event.data.action) {
                case "PROGRESS_BAR":
                    if (!this.progressbar.interval) {
                        this.progressbar.text = event.data.payload.text
                        this.progressbar.remainTime = 0
                        this.progressbar.time = event.data.payload.time
                        this.progressbar.percentage = (this.progressbar.remainTime / this.progressbar.time) * 100

                        this.progressbar.interval = setInterval(() => {
                            this.progressbar.remainTime += 1000
                            if (this.progressbar.remainTime >= this.progressbar.time) {
                                this.progressbar.remainTime = this.progressbar.time
                                setTimeout(() => {
                                    this.progressbar.remainTime = false
                                    this.progressbar.time = false
                                    this.progressbar.text = false
                                    clearInterval(this.progressbar.interval)
                                    this.progressbar.interval = false
                                }, 500)
                            }
                            this.progressbar.percentage = (this.progressbar.remainTime / this.progressbar.time) * 100
                        }, 1000)

                    }
                    break;
                case "UPDATE_WEED_DATA":
                    this.weedData = event.data.payload
                    break
                default:
                    break;
            }
        },
    },
    mounted() {
        window.addEventListener('message', this.messageHandler);
    },
    beforeDestroy() {
        window.removeEventListener('message', this.messageHandler);
    },
    watch: {

    },
    template: await importTemplate('./app/pages/weed/index.html')
}
import importTemplate from '../../utils/importTemplate.js'
import menuheader from '../../components/header.js'
import progressbar from '../../components/progressbar.js'

export default {
    data() {
        return {
            rollReward: false,
            rollRewardItemIndex: 0,
            grindWeedItemIndex: 0,
            grindedWeedItemIndex: 0,
            timeout: false,
            progressbar: {
                text: false,
                time: false,
                remainTime: false,
                interval: false,
                percentage: false,
            },
            grindWeedItems: [
                {
                    label: 'Indica Weed',
                    name: 'indica_weed',
                },
                {
                    label: 'Sativa Weed',
                    name: 'sativa_weed',
                },
            ],
            grindedWeedItems: [
                {
                    label: 'Grinded Indica',
                    name: 'grinded_indica',
                },
                {
                    label: 'Grinded Sativa',
                    name: 'grinded_sativa',
                },
            ],
        }
    },
    methods: {
        NextGrindWeedItem() {
            this.grindWeedItemIndex += 1
            if (this.grindWeedItemIndex > this.grindWeedItems.length - 1) {
                this.grindWeedItemIndex = 0
            }
        },
        PrevGrindWeedItem() {
            this.grindWeedItemIndex -= 1
            if (this.grindWeedItemIndex < 0) {
                this.grindWeedItemIndex = this.grindWeedItems.length - 1
            }
        },
        NextGrindedWeedItem() {
            this.grindedWeedItemIndex += 1
            if (this.grindedWeedItemIndex > this.grindedWeedItems.length - 1) {
                this.grindedWeedItemIndex = 0
            }
        },
        PrevGrindedWeedItem() {
            this.grindedWeedItemIndex -= 1
            if (this.grindedWeedItemIndex < 0) {
                this.grindedWeedItemIndex = this.grindedWeedItems.length - 1
            }
        },
        NextRollRewardWeedItem() {
            if(this.rollReward){
                this.rollRewardItemIndex += 1
                if (this.rollRewardItemIndex > this.rollReward.length - 1) {
                    this.rollRewardItemIndex = 0
                }
            }
        },
        PrevRollRewardWeedItem() {
            if(this.rollReward){            
                this.rollRewardItemIndex -= 1
                if (this.rollRewardItemIndex < 0) {
                    this.rollRewardItemIndex = this.rollReward.length - 1
                }
            }
        },
        Action(actionType) {
            let requiredItem = this.GetCurrentGrindWeedItem.name
            if (actionType == 'roll') {
                requiredItem = this.GetCurrentGrindedWeedItem.name
            }
            postNUI('weedAction', { actionType, requiredItem })
        },
        messageHandler(event) {
            switch (event.data.action) {
                case "SHOW_ROLL_REWARD":
                    this.rollReward = event.data.payload
                    this.rollRewardItemIndex = 0
                    if(this.timeout){
                        clearInterval(this.timeout)
                        this.timeout = false
                    }
                    this.timeout = setTimeout(() => {
                        this.rollReward = false
                        this.timeout = false
                    }, 60000)
                    break
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
                default:
                    break
            }
        }
    },
    computed: {
        ...Vuex.mapState({
            translation : state => state.translation,
            itemNames : state => state.itemNames,

        }),
        getBGOVerlay(){
            return this.rollReward ? {backgroundImage : "url(./assets/images/overl-weed.png)"} : {backgroundImage :  "url(./assets/images/overlay-weed.png)"} 
        },
        grinderTranslation(){
            return this.translation["GRINDER"]
        },
        GetCurrentGrindWeedItem() {
            return this.grindWeedItems[this.grindWeedItemIndex]
        },
        GetCurrentGrindedWeedItem() {
            return this.grindedWeedItems[this.grindedWeedItemIndex]

        },
        GetRollRewardItem() {
            if(this.rollReward){
                return this.rollReward[this.rollRewardItemIndex]
            }
            return false
        },
    },
    mounted() {
        window.addEventListener('message', this.messageHandler);
        for(let key in this.itemNames){
            let data = this.itemNames[key]
            this.grindWeedItems.forEach((item) =>{
                if(item.name == key){
                    item.label = data.label
                }
            })
            this.grindedWeedItems.forEach((item) =>{
                if(item.name == key){
                    item.label = data.label
                }
            })

        }
    },
    beforeDestroy() {
        window.removeEventListener('message', this.messageHandler);
    },
  
    components: {
        menuheader,
        progressbar
    },
    template: await importTemplate('./app/pages/grinder/index.html')
}
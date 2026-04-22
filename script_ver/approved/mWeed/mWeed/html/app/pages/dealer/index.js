import importTemplate from '../../utils/importTemplate.js'
import menuheader from '../../components/header.js'

export default {
    data() {
        return {
            hoverItemData: false,
            buyItemCart: [],
            sellItemCart: [],
            currentDealerAction: 'buy',
            selectedItem: false,
            timeout : false,
        }
    },
    components: {
        menuheader,

    },
    computed: {
        ...Vuex.mapState({
            dealerName: state => state.dealer.dealerName,
            buyableItems: state => state.dealer.buyableItems,
            sellableItems: state => state.dealer.sellableItems,
            playerCash: state => state.playerCash,
            playerInventory: state => state.playerInventory,
            playerName: state => state.playerName,
            itemNames : state => state.itemNames,
            translation : state => state.translation,
        }),
        dealerTranslation(){
            return this.translation["DEALER"]
        },
        getBuyItemCartTotalAmount() {
            let total = 0
            this.buyItemCart.forEach((i) => {
                total += this.getBuyableItemByName(i.name).price * i.amount
            })
            return total
        },
        getSellItemCartTotalAmount() {
            let total = 0
            this.sellItemCart.forEach((i) => {
                total += this.getSellableItemByName(i.name).price * i.amount
            })
            return total
        },
    },
    methods: {
        ...Vuex.mapMutations({
            SendNotification: 'SendNotification',
        }),
        addToBuyItemCart(item) {
            let data = this.buyItemCart.find((i) => i.name == item.name)
            if (data) {
                data.amount += 1
            } else {
                this.buyItemCart.push({
                    name: item.name,
                    amount: 1,
                })
            }
        },
        removeFromBuyItemCart(item) {
            let data = this.buyItemCart.find((i) => i.name == item.name)
            if (data) {
                data.amount -= 1
                if (data.amount <= 0) {
                    this.buyItemCart = this.buyItemCart.filter((i) => i.name != item.name)
                }
            }
        },
        removeFromSellItemCart(item) {
            let data = this.sellItemCart.find((i) => i.name == item.name)
            if (data) {
                data.amount -= 1
                if (data.amount <= 0) {
                    this.sellItemCart = this.sellItemCart.filter((i) => i.name != item.name)
                }
            }
        },
        addToSellItemCart(item, amount) {
            item = this.getPlayerItemByName(item.name) || item
            let data = this.sellItemCart.find((i) => i.name == item.name)
            amount = amount || 1
            if (data) {
                if (item.amount > 0) {
                    if (item.amount >= data.amount + amount) {
                        data.amount += amount
                        this.selectedItem = item

                    } else {
                        data.amount = item.amount
                        this.selectedItem = item
                    }
                } else {
                    this.SendNotification("You don't have enough item")
                }
            } else {
                if (item.amount > 0) {
                    if (item.amount >= amount) {
                        this.sellItemCart.push({
                            name: item.name,
                            amount
                        })
                        this.selectedItem = item
                    } else {
                        this.sellItemCart.push({
                            name: item.name,
                            amount: item.amount
                        })
                        this.selectedItem = item
                    }

                } else {
                    this.SendNotification("You don't have enough item")
                }

            }
        },

        async buyItems() {
            if (this.buyItemCart.length > 0) {
                let success = await postNUI('buy', {
                    cart: this.buyItemCart,
                })
                if (success) {
                    this.SendNotification("You bought the items")
                    this.buyItemCart = []
                }

            }
        },
        async sellItems() {
            if (this.sellItemCart.length > 0) {
                let success = await postNUI('sell', {
                    cart: this.sellItemCart,
                })
                if (success) {
                    this.SendNotification("You sold the items")
                    this.sellItemCart = []
                } 

            }
        },
        getBuyableItemByName(name) {
            let data = this.buyableItems.find((i) => i.name == name)
            return data
        },
        getSellableItemByName(name) {
            let data = this.sellableItems.find((i) => i.name == name)
            return data
        },
        getPlayerItemByName(name) {
            let data = this.playerInventory.find((i) => i.name == name)
            return data
        },
        hoverItem(item) {
            if(this.timeout){
                clearTimeout(this.timeout)
                this.timeout = false
                this.hoverItemData = false
            }
            let data = this.playerInventory.find((itemData) => itemData.name == item.name)
            if (data) {
                this.hoverItemData = data
            } else {
                this.hoverItemData = {
                    label: item.label,
                    amount: 0,
                    name: item.name        
                }
            }

        },
        unHoverItem() {
            if(this.timeout){
                clearTimeout(this.timeout)
                this.timeout = false
            }
            this.timeout = setTimeout(() =>{
                this.hoverItemData = false
                this.timeout = false
            }, 700)

        },
        setCurrentDealerAction(val) {
            this.currentDealerAction = val
            if(this.timeout){
                clearTimeout(this.timeout)
                this.timeout = false
            }
            this.hoverItemData = false
            this.selectedItem = false
        },
        numberWithSpaces(x) {
            return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        },
    },
    mounted() {

    },
    watch: {
        playerInventory(newData, oldData) {
            let found = false
            newData.forEach((item) => {
                if (this.selectedItem && item.name == this.selectedItem.name) {
                    found = true                    
                    this.selectedItem.amount = item.amount
                }
            })
            if(!found){
                this.selectedItem = false
            }
        }
    },
    template: await importTemplate('./app/pages/dealer/index.html')
}
const module = {
    namespaced: true,
    state: {
        dealerName: "MARK BULLSEYE",
        buyableItems: [],
        sellableItems: [],
    },
    mutations: {
        setDealerName(state, payload) {
            state.dealerName = payload
        },
        setBuyableItems(state, payload) {
            state.buyableItems = payload
        },
        setSellableItems(state, payload) {
            state.sellableItems = payload
        },
    },
}

export default module
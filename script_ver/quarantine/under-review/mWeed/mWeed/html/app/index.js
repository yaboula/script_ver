const { createApp } = Vue
import dealer from './pages/dealer/index.js'
import weeds from './pages/weed/index.js'
import grinder from './pages/grinder/index.js'

import dealerModule from './modules/dealer.js'


const Modules = {
  dealer: dealerModule
}

const store = Vuex.createStore({
  state: {
    activePage: false,
    logo: './assets/images/logo.png',
    playerCash: 0,
    playerName: 'Lucid Test',
    pp: './assets/images/example-pp.png',
    playerInventory: [],
    notifications: [],
    timeout: false,
    showDestroyModal : false,
    seedType : false,
    translation : {},
    itemNames : {},
  },
  mutations: {
    SetActivePage(state, payload) {
      state.activePage = payload
    },
    SetItemNames(state, payload){
      state.itemNames = payload
    },
    SetTranslation(state, payload){
      state.translation = payload
    },
    SetShowDestroyModal(state, payload){
      state.showDestroyModal = payload  
    },
    SetSeedType(state, payload){
      state.seedType = payload
    },
    setLogo(state, payload) {
      state.logo = payload
    },
    setPP(state, payload) {
      state.pp = payload
    },
    setPlayerName(state, payload) {
      state.playerName = payload
    },
    setPlayerCash(state, payload) {
      state.playerCash = payload
    },

    setPlayerInventory(state, payload) {
      state.playerInventory = payload
    },
    SendNotification(state, text) {
      const time = 3000;
      let id = Date.now();
      if (state.notifications.length > 0) {
        if (state.timeout) {
          clearTimeout(state.timeout)
          state.timeout = false
        }
        state.notifications = []
      }
      state.notifications.push({
        id: id,
        text: text,
        time: time,
      });
      state.timeout = setTimeout(() => {
        state.notifications = state.notifications.filter(notification => notification.id != id);
      }, time);
    },

  },
  actions: {},
  modules: Modules
});

createApp({
  data() {
    return {
    }
  },
  components: { dealer, weeds, grinder },
  computed: {
    ...Vuex.mapState({
      activePage: state => state.activePage,
      logo: state => state.logo,
      playerCash: state => state.playerCash,
      playerName: state => state.playerName,
      pp: state => state.pp,
      notifications: state => state.notifications,
      showDestroyModal: state => state.showDestroyModal,
      itemNames : state => state.itemNames,
      translation : state => state.translation,
      seedType : state => state.seedType,
      
    }),
    weedTranslation(){
      return this.translation["WEED"]
    },
  },
  methods: {
    ...Vuex.mapMutations({
      SetActivePage: 'SetActivePage',
      setLogo: 'setLogo',
      setPP: 'setPP',
      setPlayerName: 'setPlayerName',
      setPlayerCash: 'setPlayerCash',
      setPlayerInventory: 'setPlayerInventory',
      SendNotification: 'SendNotification',
      setDealerName: 'dealer/setDealerName',
      setBuyableItems: 'dealer/setBuyableItems',
      setSellableItems: 'dealer/setSellableItems',
      SetShowDestroyModal : 'SetShowDestroyModal',
      SetTranslation: 'SetTranslation',
      SetItemNames : 'SetItemNames',
    }),
    DestroyWeed(){
      postNUI('weedAction', {actionType:'trash'})
      this.SetShowDestroyModal(false)
    },
    close() {
      this.SetActivePage(false)
      postNUI('close')

    },
    messageHandler(event) {
      switch (event.data.action) {
        case "SET_LOGO":
          this.setLogo(event.data.payload)
          break
        case "SET_TRANSLATION":
          this.SetTranslation(event.data.payload)
          break
        case "SET_PLAYER_INFORMATIONS":
          this.setPP(event.data.payload.avatar)
          this.setPlayerName(event.data.payload.name)
          break
        case "REFRESH_PLAYER_CASH":
          this.setPlayerCash(event.data.payload)
          break
        case "REFRESH_PLAYER_INVENTORY":
          this.setPlayerInventory(event.data.payload)
          break
        case "CHECK_NUI":
          postNUI('loaded')
          break
        case "OPEN_DEALER":
          this.SetActivePage('dealer')
          this.setSellableItems(event.data.payload.sellableItems)
          this.setBuyableItems(event.data.payload.buyableItems)
          this.setDealerName(event.data.payload.name)
          break;
        case "OPEN_WEEDS":
          this.SetActivePage('weeds')
          break;
        case "OPEN_GRINDER":  
          this.SetActivePage('grinder')
          break
        case "SEND_NOTIFICATION":
          this.SendNotification(event.data.payload)
          break
        case "SET_ITEM_NAMES":
          this.SetItemNames(event.data.payload)
          break
        default:
          break;
      }
    }
  },
  mounted() {
    window.addEventListener('message', this.messageHandler);
    document.querySelector('#app').style.display = 'block';
  },
  beforeDestroy() {
    window.removeEventListener('message', this.messageHandler);
  },
  created() {
    this.keyHandler = (e) => {
      if (e.which == 27) {
        this.close()
      }
    }
    window.addEventListener('keyup', this.keyHandler);
  },
}).use(store).mount('#app')


let resourceName = 'mWeed'

if (window.GetParentResourceName) {
  resourceName = window.GetParentResourceName()

}

window.postNUI = async (name, data) => {
  try {
    const response = await fetch(`https://${resourceName}/${name}`, {
      method: 'POST',
      mode: 'cors',
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow',
      referrerPolicy: 'no-referrer',
      body: JSON.stringify(data)
    });
    return !response.ok ? null : response.json();
  } catch (error) {
    // console.log(error)
  }
}

String.prototype.format = function() {
  let formatted = this;
  for (let i = 0; i < arguments.length; i++) {
    let regexp = new RegExp('\\{'+i+'\\}', 'gi');
    formatted = formatted.replace(regexp, arguments[i]);
  }
  return formatted;
};
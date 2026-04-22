export default {
    props : ["title"],
    data() {
        return {
        }
    },
    computed: {
        ...Vuex.mapState({
            logo: state => state.logo,
            playerCash: state => state.playerCash,
            playerName: state => state.playerName,
            pp: state => state.pp,
        })
    },
    methods: {
        numberWithSpaces(x) {
            return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        },
    },
    mounted() {
    },
    template: /*html*/`
        <header>
            <img class="logo" :src="logo">
            <h1>{{title}}</h1>
            <div class="profile-picture-container">
                <div>
                    <p>{{playerName}}</p>
                    <p>$ {{numberWithSpaces(playerCash)}}</p>
                </div>
                <img class="profile-picture-image" :src="pp">
            </div>
        </header>

`
}
export default {
    props : ["text", "progress"],
    data() {
        return {
        }
    },
    computed: {
        ...Vuex.mapState({

        })
    },
    methods: {
 
    },
    mounted() {
    },
    template: /*html*/`
       <div class="progressbar-container">
            <p v-if="text">{{text}}</p>
            <div class="progressbar">
                <div :style="{width:Number(progress)+'%'}">
                </div>
            </div>
       </div>
`
}
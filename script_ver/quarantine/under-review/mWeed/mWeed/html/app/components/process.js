export default {
    props : ["maxProgress", "completedProgress", "title", "color","shadow", "fontSize"],
    data() {
        return {
        }
    },
    computed: {
       
    },
    methods: {
        GetStyle(n){
         

            return {
                boxShadow: n <= Number(this.completedProgress) ? this.shadow : "",
                background: n <= Number(this.completedProgress) ? this.color : "rgba(217, 217, 217, 0.14)",
            }
        },
    },
    mounted() {
    },
    template: /*html*/`
        <div class="process-container">
            <h1 :style="{['font-size']:fontSize, color:color}">{{title}} </h1>
            <div class="process-flex">
                <div v-for="n in Number(maxProgress)" :style="GetStyle(n)"></div>
            </div>
        </div>

    `
}
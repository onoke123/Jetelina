const { createApp } = Vue

const app = createApp({
  data() {
    return {
        enterNumber: 0,
      message: 'Hi. ',
      usertext: ''
    };
  },
  mounted() {
    window.onload = () => {
      const s = 'Hello, welcome and who are you?';
      this.$refs.userInput.focus();
      this.typing(0, s );
    };
  },
  methods: {
    typing: function (i, m) {
      let ii = i;
      if (i < m.length) {
        ii++;
        app.message = app.message + m[i]
      } else {
        return;
      }

      setTimeout(this.typing, 100, ii,m);
    },

    onKeyDown:function(){
        if( this.enterNumber == 0 ){
            app.message = "";
            this.enterNumber++;
            let ut = this.userText.trim();
            let chunk = "";
            if( 0 < ut.length ){
                if( ut.indexOf( ' ' ) != -1 ){
                    let p = ut.split( ' ' );
                    chunk = p[p.length-1];
                }else{
                    chunk = ut;
                }
            }

            const m = `Hi ${chunk}, how are you?`;
            this.typing(0,m);
        }else{
            this.$refs["userInput"].value = "";
            this.enterNumber = 0;
        }
    }
  }
}).mount('#jetelina') /* 実行タイミングの問題か、mount()はここでやるべきらしい */

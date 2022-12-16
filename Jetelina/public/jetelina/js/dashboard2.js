const { createApp } = Vue

const app = createApp({
  data() {
    return {
      message: 'Hi. '
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
      app.message = "";
      const m="hi keiji, how are you?";
      this.typing(0,m);
    }
  }
}).mount('#jetelina') /* 実行タイミングの問題か、mount()はここでやるべきらしい */


const app = new Vue({
  el: '#app',
  data: {
    ui:false,
    loading:false,
    select:0,
    firstname:"",
    lastname:"",
    dateofbirth:"",
    sex:"Male",
    nui:false,
    creater:false,
    playerinfo:[], 
    gecmis:null,
    multicharacter:[

    ],
    selectcharacter:0,
    selectionmenu: true,
    selectcharacterdata:null,
  },
  
  methods: {
    addSpace(data){
      this.creater = false;
      this.select = data.age
      this.selectcharacter = data.identifier
      this.selectcharacterdata = data
      this.playerinfo = []
      sex = data.sex
      if (sex == "M") {
        sex = "Male"
      } else {
        sex = "Female"
      }
      birth = data.dateofbirth
      yil = birth.split("-", 1);

      todayDate = new Date();
      todayYear = todayDate.getFullYear();
      todayMonth = todayDate.getMonth();
      todayDay = todayDate.getDate();
      age = todayYear - yil;
  
      $.post(`https://${GetParentResourceName()}/loadPed`, JSON.stringify({
        id: data.identifier
      }));
      let accounts = JSON.parse(data.accounts)
      return this.playerinfo.push(
        {
        firstname:data.firstname,
         lastname:data.lastname,
          dateofbirth:age,
           sex:sex,
            height:data.height,
             bank:accounts.bank,
              cash:accounts.money,
               onlinetime:data.onlinetime,
                level:data.level,
                 levelcount:data.levelcount
        }

      )
     

    },
    Menu(ui, sj){
      if (ui == "open"){
      
        this.nui = true
        this.multicharacter = sj
        this.selectcharacte = 0;
        this.playerinfo = [];
      } else if (ui == "loading") {
        this.loading = true
        var originalText = "Retrieving player data";
        var loadingProgress = 0;
        var loadingDots = 0;
        $("#loading-text").html(originalText);
        var DotsInterval = setInterval(function() {
          $("#loading-text").append(".");
          loadingDots++;
          loadingProgress++;
          if (loadingProgress == 3) {
              originalText = "Validating player data"
              $("#loading-text").html(originalText);
          }
          if (loadingProgress == 4) {
              originalText = "Retrieving characters"
              $("#loading-text").html(originalText);
          }
          if (loadingProgress == 6) {
              originalText = "Validating characters"
              $("#loading-text").html(originalText);
          }
          if(loadingDots == 4) {
              $("#loading-text").html(originalText);
              loadingDots = 0;
          }
        }, 1000);
        setTimeout(function(){
            setTimeout(function(){
              clearInterval(DotsInterval);
              loadingProgress = 0;
              originalText = "Retrieving data";
              $.post('https://qb-multicharacter/setupCharacters');

            }, 4000);
        }, 4000);
      }
    },
    MenuCreate(ui, sj){
      if (ui == "open"){
        this.nui = true

        this.selectionmenu = false
        this.creater = true;
        this.selectcharacte = 0;
        this.playerinfo = [];
        $.post(`https://${GetParentResourceName()}/newcharacter`, JSON.stringify({}));
        this.select = 0;
      }
    },
    addCharacter(){
      this.creater = true;
      this.selectcharacte = 0;
      this.playerinfo = [];
      $.post(`https://${GetParentResourceName()}/newcharacter`, JSON.stringify({}));
      this.select = 0;

    },
    createCharacter(){
      if (this.firstname !== "" && this.lastname !== "" && this.sex !== "" && this.date !== "") {
        let data = {
          firstname: this.firstname,
          lastname: this.lastname,
          sex: this.sex,
          date: this.dateofbirth
        }
        $.post(`https://${GetParentResourceName()}/addnewcharacter`, JSON.stringify({data: data}));
      }
      

    },
    deleteCharacter(){
      if(this.selectcharacter !== 0) {
        this.multicharacter.splice(this.multicharacter.indexOf(this.selectcharacterdata), 1);
        this.playerinfo = []
        $.post(`https://${GetParentResourceName()}/delecharacter`, JSON.stringify({
          id: this.selectcharacter
        }));
      }
   
    },
    startcharacter(){
      $.post(`https://${GetParentResourceName()}/startGame`, JSON.stringify({
        id: this.selectcharacter
      }));
    }
  }
})

window.addEventListener('message', function (event) {
  var item = event.data;
  if (item.type == "ui"){
    let data = item.data
    if (data == null) {
      app.Menu("loading", data)

    } else {
      app.Menu("open", data)
      app.loading = false

    }
  } else if(item.type == "createui") {
    app.MenuCreate("open")
    app.loading = false
  } else if(item.type == "exit") {
    app.nui = false

  }
})
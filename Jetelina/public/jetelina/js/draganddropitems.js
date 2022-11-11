$(function() {
      
    let selectedItemsArr = [];

    $('.item_area').selectable({
      cancel: "p",
      selected: function(e, ui) {
        $(ui.selected).draggable().draggable('enable');
      }
    });
    $('.item').draggable({
      snap: true,
      drag: function(e,ui){
        $('.ui-selected').each(function(){
          $(this).css({
            top: ui.position.top,
            left: ui.position.left
          });
        });
      },
      stop: function(e,ui) {
        $('.ui-selected').each(function(){
          $(this).selectable().selectable('destroy');
          $(this).draggable().draggable('disable');
        });
      }
    }).draggable('disable');

    $('.drop_area').droppable({
      activate: function(e,ui) {
        $(this)
          .find("p")
          .html("ドラッグが開始されました");
      },
      over: function(e,ui) {
        $(this)
          .css('background', '#e0ffff')
          .css('border', '2px solid #00bfff')
          .find("p")
          .html("ドロップエリアに入りました" );
      },
      out: function(e,ui) {
        $(this)
          .css('background', '#ffffe0')
          .css('border', '2px solid #ffff00')
          .find("p")
          .html("ドロップエリアから外れました");

        let item = $( ui.draggable ).text();
        console.log( "out item: ", item );
        //指定した項目を配列から削除する。なんかもっと上手い方法がないものか？
        let ret = selectedItemsArr.filter( function(a){
            return a !== item;
        });

        selectedItemsArr = ret;
        console.log("after out obj:", selectedItemsArr);
      },
      drop: function(e,ui) {
        $(this)
          .addClass("ui-state-highlight")
          .css('background', '#fdf5e6')
          .css('border', '2px solid #ffa07a')
          .find( "p" )
          .html( "ドロップされました" );

        //指定した項目を配列に格納する
        let item = $( ui.draggable ).text();
        console.log( "in item: ",  item );
        selectedItemsArr.push(item);
        console.log( "obj: ", selectedItemsArr);
      }
    });

    $( "#post" ).on( "click", function(){
        let pd = {};
        pd["item"] = selectedItemsArr;
        console.log("post: ", selectedItemsArr, " -> ", pd );
        let dd = JSON.stringify( pd );
        
        $.ajax( {
            url: "/putitems",
            type: "POST",
            data: dd,
            contentType: 'application/json',
            dataType: "json"
        }).done(function(result, textStatus, jqXHR) {
            console.log( result );
        }).fail( function( result ){
        });
    });
  });

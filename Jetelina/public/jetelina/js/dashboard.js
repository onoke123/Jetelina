$(window).load(function () {
  /* jetelinalib.jsのgetAjaxData()を呼び出して、DB上の全tableリストを取得する
     ajaxのurlは'getalldbtable'
   */
  getAjaxData("getalldbtable");

  /*
     action by button click, then do fileupload()
   */
  $("#upbtn").on("click", function () {
    fileupload();
    // clean up d&d items
    $( ".item_area .item" ).remove();
    // clean up selectbox of the table list
    $( "#d_tablelist .tables" ).remove();
  });

  /*
    select DB table then get the columns and be defined SQL(API) list
  */
  $("#d_tablelist").change(function () {
    let tablename = $( "#d_tablelist" ).val();
    console.log("selected", tablename);
    getColumn( tablename );
    // clean up d&d items
    $( ".item_area .item" ).remove();

    // get the column list
    // get the SQL(API) list
  });

  /*
    tooltip for columns list
  */
  $(document).on({
    mouseenter: function () {
      let d = $(this).attr("d");

      $('div#pop-up').text(d).show();
    },
    mouseleave: function () {
      $('div#pop-up').hide();
    }
  }, ".item");

  let moveLeft = 20;
  let moveDown = 10;
  $(document).on({
    mousemove: function (e) {
      $("div#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);
    }
  }, ".item");
  /*
  $('.item').mousemove(function (e) {
    $("div#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);
  });
  */
});
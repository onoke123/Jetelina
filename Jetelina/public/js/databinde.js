$( function(){ console.log("chk");
    $.ajax( {
        url: "/getalldbdata",
        type: "GET",
        data: "",
        dataType: "json",
    }).done(function(result, textStatus, jqXHR) {
        console.log("chk1");
        $( "#d_data" ).text( result );
    }).fail( function( result ){
    });    
});

$(document).ready(function(){
	
//variables de control
var menuId = "menu";
var menu = $("#"+menuId);
// funciones privadas de el menu

	function start() {
		var out = document.getElementById("OUTPUT");
		var load= document.getElementById("loadGif");
		var menu_n= document.getElementById("menu_nuevo");
		var menu_c= document.getElementById("menu_compilar");
		out.style.display = "none";
		load.style.display = "block";
		setTimeout(function() {
			load.style.display = "none";
			//block compile
			alert(main);
			main.call(this);
			menu_n.className="";
			menu_c.className="disabled";
			out.readOnly = true;
			out.style.display = "block";
		},2000);
	}
	function new_tree(){
		var out = document.getElementById("OUTPUT");
		var menu_n= document.getElementById("menu_nuevo");
		var menu_c= document.getElementById("menu_compilar");
		out.value="";
		out.readOnly = false;
		menu_n.className="disabled";
		menu_c.className="";
	}



// funciones y eventos de el menu
$(document).bind("contextmenu", function(e){
	menu.css({'display':'block', 'left':e.pageX, 'top':e.pageY});
	return false;
});
	

	$(document).click(function(e){
		if(e.button == 0 && e.target.parentNode.parentNode.id != menuId){
			menu.css("display", "none");
		}
	});
	$(document).keydown(function(e){
		if(e.keyCode == 27){
			menu.css("display", "none");
		}
	});
	//----------
	
	menu.click(function(e){
		if(e.target.className == "disabled"){
			return false;
		}else{
			switch(e.target.id){
				case "menu_nuevo":
					new_tree();
					break;
				case "menu_compilar":
					//no hacer nada , lo hace main.coffee
					start();
					break;
				case "menu_link":
					alert("test");
					break;
				case "menu_link":
					alert("test");
					break;
				case "menu_link":
					alert("test");
					break;
				//links de la página
				case "menu_plus":
					var url = "http://pl05.herokuapp.com";
					//link to google+
					break;
			}
			menu.css("display", "none");
		}
	});

});
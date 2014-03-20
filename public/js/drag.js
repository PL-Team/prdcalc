var dropZone = document.getElementById('drop_zone')
var output = document.getElementById("OUTPUT");

function processFiles(files) {
		var file = files[0];
		var reader = new FileReader();
		reader.onload = function (e) {
				output.value = e.target.result;
		};
		reader.readAsText(file);
}
function handleFileSelect(evt) {
	var menu = document.getElementById("menu_compilar");
	handleDragVisualOFF(evt);
    evt.stopPropagation();
    evt.preventDefault();
    var files = evt.dataTransfer.files;
	if(menu.className==""){
		processFiles(files);
	}
}
function handleDragOver(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    evt.dataTransfer.dropEffect = 'copy';
}
function handleDragVisualON(evt){
	evt.stopPropagation();
    evt.preventDefault();
	dropZone.className = "ondrag";
}
function handleDragVisualOFF(evt){
	evt.stopPropagation();
    evt.preventDefault();
	dropZone.className = "wdrag";
}

if(dropZone.addEventListener){
		if (document.body.addEventListener) {
			document.body.addEventListener('dragover', handleDragVisualON, false);
		}
		dropZone.addEventListener('drop', handleFileSelect, false);
		dropZone.addEventListener('dragover', handleDragOver, false);
		dropZone.addEventListener('dragleave', handleDragVisualOFF, false);
}
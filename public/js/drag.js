 var dropZone = document.getElementById('drop_zone')
var output = document.getElementById("outputText");

function processFiles(files) {
		var file = files[0];
		var reader = new FileReader();
		reader.onload = function (e) {
				output.value = e.target.result;
		};
		reader.readAsText(file);
}
function handleFileSelect(evt) {
	handleDragVisualOFF(evt);
    evt.stopPropagation();
    evt.preventDefault();
    var files = evt.dataTransfer.files;
    var output = [];
    for (var i = 0, f; f = files[i]; i++) {
      output.push('<li><strong>', escape(f.name), '</strong> (', f.type || 'n/a', ') - ',
                  f.size, ' bytes, last modified: ',
                  f.lastModifiedDate.toLocaleDateString(), '</li>');
                  processFiles(files);
    }
    document.getElementById('list').innerHTML = '<ul>' + output.join('') + '</ul>';
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
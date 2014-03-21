var expect = chai.expect;
var tagsToReplace = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;'
};

function replaceTag(tag) {
    return tagsToReplace[tag] || tag;
}

function safe_tags_replace(str) {
    return str.replace(/[&<>]/g, replaceTag);
}


describe('Generador de arbol', function() {
    'use strict';
    var converted1,converted2,converted3,converted4,converted5,converted6;
    var ourQuiz, form;
    var contestData = {
        question1: 'a=1+2',
        answer1: 'hhhh',
    };

    before(function() {
        //ourQuiz = new Quiz(contestData);
        //form = jQuery('body').append(formMarkup);
    });

    after(function() {
        jQuery('#fixture').remove();
    });

    beforeEach(function() {
		document.getElementById('OUTPUT').value = contestData.question1;
		document.getElementById('menu_compilar').click();
		window.main();
		converted1 = document.createElement("div");
		converted1.innerHTML = document.getElementById('OUTPUT').value;
	
    });
    
    it('Ejemplo simple de sentencia: a=1+2', function() {
	expect(converted1.innerHTML).to.equal(contestData.answer1);
	document.getElementById('test_output1').innerHTML=safe_tags_replace(contestData.answer1);
    });
});



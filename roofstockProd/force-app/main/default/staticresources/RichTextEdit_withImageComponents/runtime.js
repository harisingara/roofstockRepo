(function(skuid) {
	skuid.componentType.register("RichTextEdit_withImage__richTextEdit_withImage", function(element, xmlDef, /*component*/) {
		element.addClass("hello-content").html("<b>Hello " + xmlDef.attr("person") + "</b>");
	});
})(skuid);
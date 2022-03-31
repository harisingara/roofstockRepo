(function(skuid) {
	var bc = skuid.builder.core;
	var componentId = "RichTextEdit_withImage__richTextEdit_withImage";
	bc.registerBuilder(new bc.Builder({
		id: componentId,
		name: "Say Hello",
		icon: "sk-icon-contact",
		description: "This component says Hello to someone",
		componentRenderer: function(component) {
			component.setTitle(component.builder.name);
			component.body.html('<div class="hello-content">Hello ' + component.state.attr("person") + '!</div>');
		},
		propertiesRenderer: function (propViewer, component) {
			propViewer.setTitle("Say Hello Component properties");
			var state = component.state;
			var propCategories = [];
			var propsList = [
				{
					id: "person",
					type: "string",
					label: "Person to say Hello to",
					helptext: "Pick a name, any name!",
					onChange: function(){
						component.refresh();
					}
				}
			];
			propCategories.push({
				name: "",
				props: propsList,
			});
			propViewer.applyPropsWithCategories(propCategories, state);
		},
		defaultStateGenerator: function() {
			return skuid.utils.makeXMLDoc("<" + componentId + ' person="' + skuid.utils.userInfo.firstName + '"/>');
		},
	}));
})(skuid);
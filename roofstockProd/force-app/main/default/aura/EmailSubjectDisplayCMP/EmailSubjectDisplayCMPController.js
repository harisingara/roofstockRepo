({
	select : function(component, event, helper) {
		/*console.log(event);
            var id = event.currentTarget.dataset.id; //it will return thisDiv
         alert(event.target.dataset.div);*/
         var selectedCategory = event.target.getAttribute("data-produto");
        console.log(selectedCategory);
        component.set('v.isSelected',selectedCategory); 
       //cmp.set("v.selectedItem", "Component at index "+dataEle+" has value "+target.value);
        var lstSubject = component.get('v.lstSubject');
        var i;
        for (i = 0; i < lstSubject.length; i++) {
            if(lstSubject[i].Subject === selectedCategory){
                component.set('v.selectedSubject',lstSubject[i]); 
                break;
            }
        }
	}
})
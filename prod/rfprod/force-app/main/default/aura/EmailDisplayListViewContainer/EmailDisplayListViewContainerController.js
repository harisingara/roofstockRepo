({   

doInit : function(component, event) {       

var action = component.get("c.getActivityHistory");       

// Callback which will fetch the response from Apex and set the value to Component       
  action.setCallback(this, function(a) {   

// Set the value in the Accounts List an attribute that we created into Apex Controller        

console.log('check', a.getReturnValue());  
      var subjectlst = a.getReturnValue(); 
      component.set('v.lstSubject',a.getReturnValue());
      if(subjectlst.length <= 0 ){
          component.set('v.nomessage',true);
      }
});       

// Place the Action in the Queue    

$A.enqueueAction(action);   

}

})
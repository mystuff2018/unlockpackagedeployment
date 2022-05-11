({
	doInit : function(component, event, helper) {		
        helper.doInit(component, event, helper);
	},
    
    leftClick : function(component, event, helper) {		
        helper.leftClick(component, event, helper);  
	},
    
    rightClick : function(component, event, helper) {		
        helper.rightClick(component, event, helper);  
	},
    
    highlightAvailable : function(component, event, helper) {		
        helper.highlightAvailable(component, event, helper);  
	},
    
    highlightSelected : function(component, event, helper) {		
        helper.highlightSelected(component, event, helper);  
	},
    
    availDblClick :  function(component, event, helper) {		
        helper.highlightAvailable(component, event, helper); 
        helper.rightClick(component, event, helper);  
	},
    
    selectDblClick : function(component, event, helper) {		
        helper.highlightSelected(component, event, helper); 
        helper.leftClick(component, event, helper);  
	},
    
    save : function(component,event, helper){
    helper.save(component, event, helper);
}
    
})
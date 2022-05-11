({        
     fetchRecords2 : function(component, event, helper) {
         helper.helperMethod(component, event);
        
     },      
     closeWindow : function(component, event, helper) {
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
     }
     
 })
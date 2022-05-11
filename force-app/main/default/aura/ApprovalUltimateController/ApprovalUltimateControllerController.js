({
    handleSubmit : function(component, event, helper) {
        component.find('editform').submit();
    },
    
    handleSuccess : function(component, event, helper) {
         var action = component.get("c.notifyEmail");
         action.setParams(
             { dealIds : component.get("v.strRecordId")
             });
         $A.enqueueAction(action);
        
        var strAccName = component.find("accName").get("v.value");
        component.find('notifLib').showToast({
            "variant": "success",
            "title": strAccName,
            "message": "deal Updated Successfully!!"
        });
        
        component.find("overlayLibDemos1").notifyClose();
        
        
	},
})
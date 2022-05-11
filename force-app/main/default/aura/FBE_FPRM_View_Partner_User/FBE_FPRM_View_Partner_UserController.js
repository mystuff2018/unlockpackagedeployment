({
    doInit: function(component, event, helper) {
       helper.getContactUserData(component);
    },
    EditUser: function(component, event, helper) {
        component.set("v.isViewMode",false); 
    },
    onCancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire(); 
    },
    successHandler: function(component, event, helper) {  
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "User data has been updated successfully."
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})
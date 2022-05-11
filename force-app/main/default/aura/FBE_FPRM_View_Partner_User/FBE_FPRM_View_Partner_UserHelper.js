({
	getContactUserData : function(component) {
		var action = component.get('c.getPartnerUser'); 
        action.setParams({
            "contactId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var data = JSON.parse(a.getReturnValue());
                console.log('data===' + a.getReturnValue());
                if(data.user){
                    component.set("v.isPartnerUser",true); 
                    component.set("v.partnerUserId",data.user.Id);  
                }
                else{
                    component.set("v.isPartnerUser",false); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Partner User",
                        "type": "error",
                        "message": "Partner user is not on-boarded yet."
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            }
        });
        $A.enqueueAction(action);
	},
})
({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRelatedActConts");
        action.setParams({ actId : component.get('v.accountId') });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                console.log("related ActConts: ",response.getReturnValue());
                component.set('v.contactList' ,response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    selectedRadio: function(component, event, helper) {  
        console.log('inside selectedRadio');
        var selectedRecId = event.target.value;
        component.set('v.contactId',selectedRecId);
        component.find("lookupContId").set("v.value", "");//

    },
    selectedlookupCont: function(component, event, helper) {   
        console.log('inside lookupChange');
        var selectedRecId = component.find('lookupContId').get('v.value');
        component.set('v.contactId',selectedRecId);
        
        var inputs = document.querySelectorAll('input[type="radio"]');
        for (var i = 0; i < inputs.length; i++) {
            if(inputs[i].id == "radioId"){
                 inputs[i].checked = false;
            }
        }
        
    },
})
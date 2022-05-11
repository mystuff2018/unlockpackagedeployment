({
    handleYes : function(component, event, helper) {
        console.log('inside Handle Yes');
        //helper.checkBoxUpdate(component, event);//
        var appEvent = $A.get("e.c:OppRevenueCheckEvent");
        appEvent.setParams({"message" : "first yes"});
        appEvent.fire();
        component.find("overlayLib1").notifyClose();
    },
    
    handleNo : function(component, event, helper) {
        console.log('inside Handle No');
        component.set("v.boolean", false);
        helper.getOptyLineItems(component, event);
    },
    
    onSubmitAction : function(component, event, helper) {
        var amnt = $A.get("$Label.c.Opportunity_Revenue_Alert");
        var label = parseFloat(amnt);
        console.log('label: ', label);
        console.log('inside onSubmitAction');
        component.set("v.showSpinner", true);
        
        var action = component.get("c.updateOptyLineItems");
        action.setParams({
            "actList": component.get("v.relatedProducts")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state', state);
            component.set("v.showSpinner", false);
            if (state === "SUCCESS") {
                console.log('onSubmitAction update success');
                //helper.updateRevenueAlertCheckBox(component, event);
                helper.checkBoxUpdate(component, event);//
                
                component.find("overlayLib1").notifyClose();
                $A.get('e.force:refreshView').fire(); //
                if(response.getReturnValue() >= label){
                    console.log('response.getReturnValue() >= label');
                    console.log('inside logging event**');
                    var appEvent = $A.get("e.c:OppRevenueCheckEvent");
                    appEvent.setParams({});
                    appEvent.fire();
                }else{
                    $A.get('e.force:refreshView').fire();//
                    console.log('updating checkBox*');
                }
            }
            else {
                console.log('update failed');
            }
            
        });
        $A.enqueueAction(action);
    },
    
    cancelAction: function(component, event, helper) {
        console.log('inside cancelAction');
    },
    
    removeOLI: function(component, event, helper) {
        console.log('inside removeOLI');
        component.set("v.showSpinner", true);
        var selectedItem = event.currentTarget;
        var recIndex = selectedItem.dataset.row;
        console.log('====',recIndex);
        
        var originalData = component.get("v.relatedProducts2");
        var lstOLIs = component.get("v.relatedProducts");
        lstOLIs.splice(recIndex, 1);
        
        component.set("v.relatedProducts", lstOLIs);
        var recordIdToDelete = originalData[recIndex].Id;
        console.log('recordIdToDelete',recordIdToDelete);
        
        helper.deleteOptyLineItem(component, event, recordIdToDelete);
    }
})
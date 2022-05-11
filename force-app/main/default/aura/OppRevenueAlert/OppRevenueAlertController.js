({
    doInit : function(component, event, helper) {
        //alert('Opportunity amount is:::: >=1000'); 	
        var oppId = component.get('v.recordId');
        console.log('inside 1st comp Init:',oppId);
        
        
        if(oppId.startsWith("006")){
            console.log('this is an opty');
            helper.createComponent(component, event, oppId);
            
        }else{
            console.log('this is an optyLineItem');
            var callAction = component.get("c.getOptyId");
            var optliId = component.get('v.recordId');
            console.log('optliId:: ',optliId);
            callAction.setParams({
                "oplId": optliId
            });
            
            callAction.setCallback(this, function(response){
                var state = response.getState();
                console.log('state', state);
                
                if (state === "SUCCESS") {
                    console.log('Got OptyId from LineItemId:');
                    console.log('And the OptyId: ',response.getReturnValue());
                    component.set("v.optyId", response.getReturnValue());
                    helper.createComponent(component, event, response.getReturnValue());
                   
                }
                else {
                    console.log('Failed in getting OptyId from LineItemId');
                }
                
            });
            $A.enqueueAction(callAction);
        }
    },
    
    handleRevenueCheck : function(component, event, helper) {
        console.log('inside handleRevenueCheck');
        var message = event.getParam("message");
        console.log('message- ',message);
        //alert(message);
        //helper.updateRevenueAlertCheckBox(component, event);
        helper.checkBoxUpdate(component, event, message);
    }
})
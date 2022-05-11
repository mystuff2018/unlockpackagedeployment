({
    checkBoxUpdate : function(component, event, mess) {
        console.log('mess: ',mess);
        var bool = true;
        if(mess == "first yes"){
            console.log('inside mess');
            bool = false;
        }
        console.log('inside checkBoxUpdate');
        var callAction = component.get("c.updateRevenueCheckBox");
        var oppId = component.get('v.recordId');
        var currentRecordId = component.get('v.recordId');
        console.log('optyId record Id: ',component.get('v.optyId'));
        if(oppId.startsWith("006")){
            oppId = oppId;
        }else{
            console.log('inside else');
            oppId = component.get('v.optyId');
        }
        
        console.log('oppId-- ',oppId);
        callAction.setParams({
            "optyId": oppId,
            "boo" : bool
        });
        
        callAction.setCallback(this, function(response){
            var state = response.getState();
            console.log('state', state);
            
            if (state === "SUCCESS") {
                console.log('update sucess-1');
                //$A.get('e.force:refreshView').fire();
                
                if(currentRecordId.startsWith("00k")){
                    console.log('inside 00k');
                    $A.get('e.force:refreshView').fire();
                }else{
                    if(mess == "first yes"){
                        console.log('first yes');
                        $A.get('e.force:refreshView').fire();
                    }else{
                        console.log('inside calling Init');
                        var a = component.get('c.doInit');
                        $A.enqueueAction(a);
                    }
                }
            }
            else {
                console.log('update failed-1: ', response.getReturnValue());
            }
            
        });
        $A.enqueueAction(callAction);
    },
    
    createComponent : function(component, event, opporId) {
        console.log('opporId: ',opporId);
        $A.createComponent("c:OppProductsUpdate", 
                           {optyId : opporId,
                            modalId : "overlayLibDemo"},
                           function(result, status) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLibDemo').showCustomModal({
                                       header: "Revenue Confirmation",
                                       body: result, 
                                       showCloseButton: false,
                                       cssClass: "mymodal", 
                                   })
                               }                               
                           });
        
    }
})
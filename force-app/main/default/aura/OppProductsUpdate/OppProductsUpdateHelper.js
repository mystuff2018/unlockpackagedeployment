({
    getOptyLineItems : function(component, event) {
        console.log('inside getOptyLineItems');
        console.log('opId in getOptyLineItems: '+component.get("v.optyId"));
        
        var action = component.get('c.getOptyLineItems');
        action.setParams({
            "opId" : component.get("v.optyId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT'){
                console.log('line items list: ',response.getReturnValue());
                component.set('v.relatedProducts', response.getReturnValue());
                component.set('v.relatedProducts2', response.getReturnValue());
            }else{
                console.log('Error in getting line Items');
            }
        });
        $A.enqueueAction(action);
    },
    
    checkBoxUpdate : function(component, event) {
        console.log('inside checkBoxUpdate : 2');
            var callAction = component.get("c.updateRevenueCheckBox");
            var oppId = component.get("v.optyId");
        console.log('oppId---- ',oppId);
            callAction.setParams({
                "optyId": component.get("v.optyId"),
                "boo" : false
            });
            
            callAction.setCallback(this, function(response){
                alert('checkBox made to False:');
                var state = response.getState();
                console.log('state', state);
                if (state === 'SUCCESS' || state === 'DRAFT') {
                    console.log('update sucess::2');
                    //$A.get('e.force:refreshView').fire();
                    //var a = component.get('c.doInit');
                    //$A.enqueueAction(a);
                }
                else {
                    console.log('update failed-2');
                }
            });
            $A.enqueueAction(callAction);
        },
    
    deleteOptyLineItem : function(component, event, recordIdToDelete) {
        console.log('inside deleteOptyLineItem:');
        console.log('recordIdToDelete: ',recordIdToDelete);
        
        var action = component.get('c.deleteOptyLineItem');
        action.setParams({
            "oplId" : recordIdToDelete
        });
        action.setCallback(this,function(response){
            component.set("v.showSpinner", false);
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT'){
                console.log('Success - deleteOptyLineItem ',response.getReturnValue());
            }else{
                console.log('Failure - deleteOptyLineItem ');
            }
        });
        $A.enqueueAction(action);
    }
})
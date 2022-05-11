({
    doInit : function(component, event, helper) {
        console.log('inside init');
        console.log('aId ',component.get('v.acntId'));
        console.log('oId ',component.get('v.optId'));
        console.log('cId',component.get('v.conId'));
        var action = component.get("c.getUpdateValues");
        action.setParams({
            "aId": component.get('v.acntId'),
            "oId" : component.get('v.optId'),
            "cId" : component.get('v.conId') 
        });
       
        action.setCallback(this,function(response){
             console.log('values are#####',response.getReturnValue());
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Got the updated values');
                console.log('values are:',response.getReturnValue());
                console.log('response.getReturnValue()[0] ',response.getReturnValue()[0]);
                console.log('response.getReturnValue()[1] ',response.getReturnValue()[1]);
                console.log('response.getReturnValue()[2] ',response.getReturnValue()[2]);
                
                component.set('v.accountRec' ,response.getReturnValue()[0]);
                component.set('v.contRec' ,response.getReturnValue()[1]);
                
                
                if($A.util.isEmpty(response.getReturnValue()[2])){
                    console.log('inside without opportunity:');
                    component.set('v.hasOpty' ,false);
                }else{
                    console.log('inside opportunity:');
                    component.set('v.hasOpty' ,true);
                    component.set('v.oppRec' ,response.getReturnValue()[2]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToLead : function(component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Lead"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})
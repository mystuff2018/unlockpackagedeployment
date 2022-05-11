({
	fetchOpptyRecs : function(component, event, helper) {
        var action = component.get("c.getRelatedOppty");
        console.log('action ', action);
        var accid = component.get("v.accountId");
        console.log('accid' , accid);
        action.setParams({ accountId : component.get("v.accountId") });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state' ,state);
            if(state == "SUCCESS"){
                component.set("v.filtereddata",response.getReturnValue());
                console.log('oppty values ' ,response.getReturnValue());
                console.log('opties lenghth: ',response.getReturnValue().length);
                component.set("v.optysize",response.getReturnValue().length);
               
                    
            }else{
                console.log('Error occured');
            }
        });
        $A.enqueueAction(action);
	},
    
    searchKeyChange: function(component,event,helper) {  
     
        var Name = component.get("v.searchName");
        var action = component.get("c.getSearchedOppty");
        action.setParams({ accountId : component.get("v.accountId"), sname : Name });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state = "SUCCESS"){
                component.set("v.filtereddata",response.getReturnValue());
                component.set("v.optysize",response.getReturnValue().length);
            }
        });
        $A.enqueueAction(action);
    }

})
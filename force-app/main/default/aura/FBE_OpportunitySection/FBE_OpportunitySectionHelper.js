({
	fetchOpptyRecs : function(component, event, helper) {
        var action = component.get("c.getRelatedOppty");
        action.setParams({ accountId : component.get("v.accountId") });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.filtereddata",response.getReturnValue());
                console.log('opties lenght: ',response.getReturnValue().length);
                console.log('filtereddata: ',response.getReturnValue());
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
            }
        });
        $A.enqueueAction(action);
    }

})
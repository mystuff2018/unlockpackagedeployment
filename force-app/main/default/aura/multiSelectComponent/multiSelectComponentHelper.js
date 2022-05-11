({
	doInit : function(component, event, helper) {		
        //Get the available list
        var action = component.get("c.getAllAvailValues");
        action.setParams({"taskId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")   {
                component.set("v.AvailableList", response.getReturnValue());
            }
            else
            { 
             
            }
        });
        $A.enqueueAction(action);	  
 		
        //Get the selected list
        var actionSelect = component.get("c.getAllSelectValues");
        actionSelect.setParams({"taskId": component.get("v.recordId")});
        actionSelect.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")   {
                component.set("v.SelectedList", response.getReturnValue());
            }
            else
            { 
             
            }
        });
        $A.enqueueAction(actionSelect);

        component.set("v.HighlightedAvail", "");
        component.set("v.HighlightedSelect", "");
	},
    	
    leftClick : function(component, event, helper) {		
		if(component.get("v.HighlightedSelect") != "")
        {
            var textval = component.get("v.HighlightedSelect");
            var availarray = component.get("v.SelectedList");
            var index = availarray.indexOf(textval);
            availarray.splice(index, 1);
            component.set("v.SelectedList", availarray);
            
            var selectArray = component.get("v.AvailableList");
            selectArray.push(textval);
            component.set("v.AvailableList", selectArray);
            
            component.set("v.HighlightedSelect", "");
    	}
	},
    
    rightClick : function(component, event, helper) {		 
		if(component.get("v.HighlightedAvail") != "")
        {
            var textval = component.get("v.HighlightedAvail");
            var availarray = component.get("v.AvailableList");
            var index = availarray.indexOf(textval);
            availarray.splice(index, 1);
            component.set("v.AvailableList", availarray);
            
            var selectArray = component.get("v.SelectedList");
            selectArray.push(textval);
            component.set("v.SelectedList", selectArray);
            
            component.set("v.HighlightedAvail", "");
    	}
	},
    
    highlightAvailable : function(component, event, helper) {
		var temp = event.currentTarget.dataset.record;
        component.set("v.HighlightedAvail", temp); 
	},
    
    highlightSelected :  function(component, event, helper) {
        var temp1 = event.currentTarget.dataset.record;
		component.set("v.HighlightedSelect", temp1);    
	},
    
    save : function(component, event, helper){
        console.log("start");
        var action = component.get("c.updateTaskRec");
        var selList = component.get("v.SelectedList");
        action.setParams({"selectedVal": selList,
        				"taskId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")   {
                console.log("passed");
                alert("Product Added!");
                $A.get('e.force:refreshView').fire();
            }
            else
            { 
             console.log("fail");
                console.log(component.get("v.SelectedList").toString());
            }
        });
        $A.enqueueAction(action);
        component.set("v.HighlightedAvail", "");
        component.set("v.HighlightedSelect", "");
    }
})
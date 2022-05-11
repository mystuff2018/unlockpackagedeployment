({
    onInit: function(component, event, helper) {
        component.set("v.url", window.location.origin);
        component.set("v.finish", false);
        component.set("v.association", true);
    },
    associate: function(component, event, helper)
    {
        component.set("v.association", false);

        var action = component.get("c.associateOrderToEngagement");
               
        action.setParams({
            pOrderId: component.get('v.orderNumber'),
            pEngagementId: component.get("v.proj.Id")
        });
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                component.set("v.finish", true);
            }
        });

        $A.enqueueAction(action);
    },
    refreshScreen: function (component, event, helper)
    {
        $A.get('e.force:refreshView').fire();
    },
    handleStatusChange : function (component, event) {
      if(event.getParam("status") === "FINISHED") {
          
         // Get the output variables and iterate over them
         var outputVariables = event.getParam("outputVariables");
         var resultOutput;
         if(outputVariables[0] != null && outputVariables[0].name === 'result')
         {
         	resultOutput = outputVariables[0];   
         }
         else if(outputVariables[1] != null && outputVariables[1].name === 'result')
         {
             resultOutput = outputVariables[1];
         }
                   
         if(resultOutput.name === 'result' && resultOutput.value === true)
         {
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
				"recordId": component.get('v.orderNumber'),
                "isredirect": "true"
			});
            urlEvent.fire();
         }
         //outputVar.value
         //outputVar.name
      }
   }
})
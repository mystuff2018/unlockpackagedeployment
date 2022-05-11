({
	loadSuggestions : function(component, event, helper) 
    {
        var action = component.get("c.getProjectSuggestions");
        component.set("v.association", true);
        component.set("v.diassociationProcess", false);  
        component.set("v.createProjectProcess", false);  
        action.setParams({
            orderId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) 
        {
            var suggestions = data.getReturnValue();
            component.set("v.Projects", suggestions);
            helper.sort(component);
        });
        $A.enqueueAction(action);
		
	},
    
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    
    openModal: function(component,event,helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    
    createProjectClick: function(component,event,helper) {
        component.set("v.createProjectProcess", true); 
        console.log('createProject');
        var action = component.get("c.createProject");
        action.setParams({
            orderId: component.get("v.recordId")
        });
        
		action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != null && result.length > 0){
                    helper.showToast(component, 'Error', result.join('; \n'), 'Error');
                }
                else{
                    helper.showToast(component, 'Success', 'Project creation process has started...', 'Success');
                    $A.get('e.force:refreshView').fire();
                }
                component.set("v.createProjectProcess", false);        
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(component, 'Error', errors[0].message, 'Error');
                        component.set("v.createProjectProcess", false);
                    }
                }
            }

        });

        $A.enqueueAction(action);        
        
    },
    
    unassociateOrder: function(component,event,helper) {
        /*var flow = component.find("unassociateOrder");
        var inputVariables = [
            {
                name : "OrderId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("IDS_Unassociate_Order", inputVariables);*/
        component.set("v.diassociationProcess", true); 
        console.log('disassociationOrder');
        var action = component.get("c.disassociationOrder");
               
        action.setParams({
            orderId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != null && result.length > 0){
                    helper.showToast(component, 'Error', result.join('; \n'), 'Error');
                }
                else{
                    helper.showToast(component, 'Success', 'Order Dissociation Successful', 'Success');
                    $A.get('e.force:refreshView').fire();
                }
                component.set("v.diassociationProcess", false);        
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(component, 'Error', errors[0].message, 'Error');
                        component.set("v.diassociationProcess", false);
                    }
                }
            }

        });

        $A.enqueueAction(action);

        
    },
    
    goToProject : function (component, event) {
             // Get the output variables and iterate over them
             console.log(event.getParam("outputVariables"));
             var outputVariables = event.getParam("outputVariables");
             var outputVar;
             for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "projectId" && outputVar.value) {
                    var urlEvent = $A.get("e.force:navigateToSObject");
                    
                    urlEvent.setParams({
                        "recordId": outputVar.value,
                        "isredirect": "true"
                    });

                    urlEvent.fire();
                }
             }
       },
    
    gotoList : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Order"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})
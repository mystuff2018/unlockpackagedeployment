({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Order #', fieldName: 'Order_Number__c', type: 'text'},
            {label: 'Business Unit ID', fieldName: 'BUID__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes:{ year: "numeric", month: "2-digit", day: "2-digit", hour:"2-digit", minute:"2-digit" }},
            {label: 'Status', fieldName: 'status', type: 'text', cellAttributes: { class: {fieldName: 'category'}, iconName:'utility:record', iconPosition: 'left' }},
            {label: 'Integration Message', fieldName: 'FBE_Siebel_Integration_Message__c', type: 'text', wrapText: true}
        ]);
        
        $A.enqueueAction(component.get('c.getQueue'));
    },
    
    validate: function(component, event, helper) {
        var validateImportOrder = component.get("c.validateImportOrder");
        
        var orderNumber = component.find("orderNumber");
        var buid = component.find("buid");
        
        var isValidOrderNumber = orderNumber.get("v.validity").valid;
        var isValidBuid = buid.get("v.validity").valid;
        
        if (!isValidOrderNumber) {
            orderNumber.showHelpMessageIfInvalid();
        }
        
        if (!isValidBuid) {
			buid.showHelpMessageIfInvalid();
        }
        
        if (!isValidOrderNumber || !isValidBuid) {
            return;
        }
        
		component.set("v.isLoading", true);
        
        validateImportOrder.setParams({
            orderNumber: component.find("orderNumber").get("v.value"),
            buid: component.find("buid").get("v.value"),
            projectId: component.get("v.recordId")
        });
        
        validateImportOrder.setCallback(this, function(data){
            var returnValue = data.getReturnValue();
            
            component.set("v.hasErrors", returnValue.HasErrors);
            component.set("v.errors", returnValue.Errors);
            
            if (returnValue.ValidOrders && returnValue.ValidOrders.length > 0) {
                component.set("v.validOrders", returnValue.ValidOrders);
                
        		$A.enqueueAction(component.get('c.import'));
            }
            else {
				component.set("v.isLoading", false);
            }
        });
        
        $A.enqueueAction(validateImportOrder);
    },
     
    import: function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var importOrder = component.get("c.importOrder");
        var validOrders = component.get("v.validOrders");
        
        importOrder.setParams({
            orderNumbers: validOrders,
            buid: component.find("buid").get("v.value"),
            projectId: component.get("v.recordId")
        });
        
        importOrder.setCallback(this, function(data){
			if (data.getState() === "SUCCESS") {
                var title = "Successfully queued " + validOrders.length + (validOrders.length > 1 ? " orders" : " order") + " for import process:";
                
				component.find('notifLib').showToast({
                    "title": title,
                    "message": validOrders.join(),
                    "variant": "success"
        		});
                
				$A.enqueueAction(component.get('c.getQueue'));
  			}
            else if (data.getState() === "ERROR") {
                component.set("v.isLoading", false);
                var error = data.getError();
                
                if (error && error.length > 0 && error[0].pageErrors && error[0].pageErrors.length > 0) {
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": error[0].pageErrors[0].statusCode,
                        "message": error[0].pageErrors[0].message,
                    });
                }
                
  			}
        });
        
        $A.enqueueAction(importOrder);	
    },
    
    getQueue: function(component, event, helper) {
        component.set("v.isLoading", true);

    	var importQueue = component.get("c.getImportQueue");

    	importQueue.setParams({ 
    		projectId: component.get("v.recordId") 
		});
        
		importQueue.setCallback(this, function(data) {    
			var queueItems = data.getReturnValue();
                
            queueItems.forEach(function(item) {    
                if (item.ProcessedDate__c != null) {
                    item.status = item.Order_Import_Response_Status__c;
                    item.category = 'green';
                }
                else {
                    item.status = item.Order_Import_Response_Status__c;
                    if(item.Order_Import_Response_Status__c == 'Error'){
                        item.category = 'red';
                    }
                    else{
                        item.category = 'yellow';
                    }
                } 
            });
                
			component.set("v.orderImportItems", queueItems);
            
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(importQueue);
	}
})
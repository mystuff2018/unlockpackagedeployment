({
    
    init: function (component, event, helper) {

        component.set('v.columns', helper.COLUMNS);

        // Set default value for from/to date
        var toDate = new Date();
        var fromDate = new Date(new Date().setDate(toDate.getDate() - 30));
        
        // Set the dates to the initial hour
        toDate = $A.localizationService.startOf(toDate, 'day');
        fromDate = $A.localizationService.startOf(fromDate, 'day');

        component.set("v.dateCreatedStart", fromDate.toISOString());
        component.set("v.dateCreatedEnd", toDate.toISOString());
    },

    search: function(component, event, helper) {
        
        var formIsValid = helper.formValidation(component);

        if(!formIsValid){
            return;
        }

        helper.searchHelper(component, event);
    },
    
    handleRowAction: function (component, event, helper) {

        // Don't let associate the order again
        var isAlreadyAssociated = component.get("v.simpleRecord.Project__c") != null; 

        if(isAlreadyAssociated){
            component.set("v.messageResultList", [helper.MESSAGES.OrderAlreadyAssociated]);
            component.set("v.messageResultVisible", true);
            return;
        }

        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'associateOrder':
                helper.associationHelper(component, row);
                break;
            default:
                break;
        }
    },

    handleRowToggle: function(component, event, helper) {

        var engagementId = event.getParam('name');
        var hasChildrenContent = event.getParam('hasChildrenContent');
        
        if (hasChildrenContent === false) {
            helper.retrieveChildProjects(component, engagementId);
        }
    }
})
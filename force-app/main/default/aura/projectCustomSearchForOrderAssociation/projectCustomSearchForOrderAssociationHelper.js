({
    COLUMNS: [
        {label: 'Project Id', fieldName: 'projectId', type: 'text'},
        {label: 'Project Name', fieldName: 'projectName', type: 'text'},
        {label: 'Account Name', fieldName: 'accountName', type: 'text'},
        {label: 'Practice', fieldName: 'practiceName', type: 'text'},
        {type: 'button', initialWidth: 50, typeAttributes:
            { 
                label: { fieldName: 'actionLabel'}, 
                title: 'Click to Associate', 
                variant: "base",
                name: 'associateOrder', 
                iconName: 'utility:link', 
                disabled: {fieldName: 'actionDisabled'}}}
    ],

    MESSAGES: {
        AssociationComplete: {
            message: 'The selected order(s) have been successfully associated. Close this window to continue.',
            severity: 'confirm' 
        },
        UnknownError: {
            message: 'Something went wrong!',
            severity: 'error'
        },
        NoRecordsFound: {
            message: 'No records found!',
            severity: 'warning'
        },
        OrderAlreadyAssociated: {
            message: 'This order is already associated.',
            severity: 'error'
        },
        NoOrderToAssociate: {
            message: 'No order available to associate!',
            severity: 'error'
        },
        FieldRequired: {
            message: 'At least one field should be filled!',
            severity: 'error'
        },
        FieldMinLength: {
            message: 'Information provided should have more than 3 characters!',
            severity: 'error'
        },
        EndDateGreater: {
            message: 'End date should be greater than start date!',
            severity: 'error'
        },
        DateRange: {
            message: 'Dates should be in a range of 30 days!',
            severity: 'error'
        },
    },

    searchHelper: function(component, event) {
        
        component.set("v.searchResult", []);
        component.set("v.messageResultVisible", false);
        
        // Show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');

        var action = component.get("c.searchEngagements");
        var stageList = component.get("v.inclusionList");
        var hasProject = component.get("v.simpleRecord.Project__c") != null;
        
        action.setParams({
            'projectInfo': component.get("v.projectInfo"),
            'customerName': component.get("v.customerName"),
            'startDate': (component.get("v.dateCreatedStart") !== null && component.get("v.dateCreatedStart") !== '') ? new Date(component.get("v.dateCreatedStart")).toJSON() : '',
            'endDate': (component.get("v.dateCreatedEnd") !== null && component.get("v.dateCreatedEnd") !== '') ? new Date(component.get("v.dateCreatedEnd")).toJSON() : '',
            'includeCancelled': stageList.includes('cancelled'),
            'includeClosure': stageList.includes('closure')
        });

        action.setCallback(this, function(response) {
            // Hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');

            var errorList = [];
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = JSON.parse(response.getReturnValue());

                // If return zero records show message
                if(result.length === 0){
                    errorList.push(this.MESSAGES.NoRecordsFound);
                }
                else{

                    // Assign correct values to _children key and remove null values
                    result.forEach((item, index, object) => {

                        if(item.Id === null){
                            object.splice(index, 1);
                            return;
                        }
    
                        item['_children'] = item['childrenProjectList'];
                    });
    
                    component.set("v.searchResult", result);
                    console.log(result);
                }
            }
            else {
                errorList.push(this.MESSAGES.UnknownError);
            }

            if(errorList.length > 0){
                component.set("v.messageResultList", errorList);
                component.set("v.messageResultVisible", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    associationHelper: function (component, row) {
        component.set("v.associationComplete", false);
        
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');

        var action = component.get("c.associateOrdersToProject");
        
        action.setParams({
            'orderId': component.get("v.recordId"),
            'projectId': row.Id
        });
        
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            
            var errorList = [];
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.associationComplete", true); 
                errorList.push(this.MESSAGES.AssociationComplete);
                $A.get('e.force:refreshView').fire();
            }
            else {
                errorList.push(this.MESSAGES.UnknownError.message);
            }

            if(errorList.length > 0){
                component.set("v.messageResultList", errorList);
                component.set("v.messageResultVisible", true);
            }
        });
        $A.enqueueAction(action);
    },

    formValidation: function(component){

        var projectInfo = component.get('v.projectInfo');
        var customerName = component.get('v.customerName');
        var dateCreatedStart = component.get('v.dateCreatedStart');
        var dateCreatedEnd = component.get('v.dateCreatedEnd');

        component.set("v.errorVisible", false);

        var errorList = [];

        // VALIDATION TO NULL FIELD
        if(!projectInfo && !customerName){
            errorList.push(this.MESSAGES.FieldRequired);
        }

        // VALIDATION TO FIELD SIZE    
        if ((customerName != null && customerName.length > 0 && customerName.length < 3) ||
            (projectInfo != null && projectInfo.length > 0 && projectInfo.length < 3)) {
            errorList.push(this.MESSAGES.FieldMinLength);
        }

        if(dateCreatedEnd < dateCreatedStart){
            errorList.push(this.MESSAGES.EndDateGreater);
        }
        
        // VALIDATION TO DATE
        var subDays = Math.round((new Date(dateCreatedEnd).getTime() - new Date(dateCreatedStart).getTime())/86400000);
        if(subDays > 30) {
            errorList.push(this.MESSAGES.DateRange);
        }

        if(errorList.length > 0){
            component.set("v.errorList", errorList);
            component.set("v.errorVisible", true);
            return false;
        }

        return true;

    },

    retrieveChildProjects: function(component, engagementId) {
        
        // Show loading spinner
        component.find("Id_spinner").set("v.class" , 'slds-show');
        
        var action = component.get("c.retrieveChildProjects");

        action.setParams({
            'engagementId': engagementId            
        });

        action.setCallback(this, function(response) {
            // Hide spinner
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            
            var errorList = [];
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = JSON.parse(response.getReturnValue());

                var data = component.get("v.searchResult");
                
                // Add children projects to the correct engagement
                data.forEach(engagement => {
                    if(engagement.Id === engagementId){
                        engagement['_children'] = result;
                    }
                });

                component.set("v.searchResult", data);
                
            }
            else {
                errorList.push(this.MESSAGES.UnknownError);
            }

            if(errorList.length > 0){
                component.set("v.messageResultList", errorList);
                component.set("v.messageResultVisible", true);
            }
        });
        $A.enqueueAction(action);
       
    }
})
({
	init : function(component, event, helper) {
		helper.getRecords(component, event, helper);
        helper.initColumnsAndActions(component, event, helper);
	},
    
    handleColumnsChange: function (component, event, helper) {
        helper.initColumnsAndActions(component, event, helper)
    },
    
    goToViewAll : function (component, event, helper) {
       /* var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": component.get("v.parentRelationshipApiName"),
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire(); */

        component.set("v.enableInfiniteLoading", true);
        console.log("Enable Inifite Loading: "+component.get("v.enableInfiniteLoading"));
        var environment = component.get('v.environmentType');
        if(environment === 'Community'){
            let navService = component.find("navService");           
            // Sets the route to [Org url]/[Community uri]/[pageName]
            let pageReference = {
                type: "comm__namedPage", // community page.
                attributes: {
                    pageName: component.get("v.navigateToPage") // pageName must be lower case,
                },
                state:{
                    recordId: component.get("v.recordId"),
                    viewAllRecords:false
                }
            }
            
            sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));
            navService.navigate(pageReference);
        }
        else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:FBE_FPRM_ContactsRelatedList",
                componentAttributes: {
                    environmentType: "Standard",
                    viewAllRecords:false,
                    recordId: component.get("v.recordId"),
                    enableInfiniteLoading:true
                }
            });
            evt.fire();
        }
    },
    
    handleSearch : function (component, event, helper) {
        helper.searchRecordsBySearchPhrase(component, event, helper);
    },
    
    handleCreateRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": component.get("v.objectApiName"),
            "defaultFieldValues": {
                [component.get("v.conditionFieldApiName")] : component.get("v.recordId")
            },
            "navigationLocation": "RELATED_LIST"
        });
        createRecordEvent.fire();
    },
    
    handleLoadMore : function(component,event,helper){
        console.log("in handle load more");
        console.log("Current Count in HandleLoadMore: "+component.get("v.currentCount"));
        
        if(!(component.get("v.currentCount") >= component.get("v.totalRows"))){
            event.getSource().set("v.isLoading", true);
            helper.loadData(component, event, helper).then(function(data){
                var currentData = component.get("v.filteredRecords");
                //console.log("data in handle load more: "+currentData);
                var newData = currentData.concat(data);
                //component.set("v.records", newData);
                component.set("v.filteredRecords", newData);

            });
        }
        else{
            component.set("v.enableInfiniteLoading",false);
        }
    },
    
    navigateToRecordId: function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
        });
        navEvt.fire();
    }
})
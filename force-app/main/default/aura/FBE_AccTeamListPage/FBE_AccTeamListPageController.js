({
doinit : function(component, event, helper) {
        
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__accountId;
        var LeadName = myPageRef.state.c__LeadName;
        var LeadId = myPageRef.state.c__LeadId;
        console.log('Account Id from PageReference ==> ' +id);
        console.log('LeadId from PageReference ==> ' +LeadId);
        console.log('LeadName from PageReference ==> ' +LeadName);
        component.set("v.accountId", id);
        component.set("v.LeadName", LeadName);
        component.set("v.LeadId", LeadId);
        var accid = component.get("v.accountId");
        
        helper.fetchAccTeam(component, event, helper);
        
    },
    
    navtoRec: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.LeadId")
        });
        navEvt.fire();
    },
    
    navtoLeadList: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": '/lightning/o/Lead/list?filterName=Recent'
        });
        navEvt.fire();
    },
    updateColumnSorting: function(component, event, helper) {
    var fieldName = event.getParam('fieldName');
    var sortDirection = event.getParam('sortDirection');
    // assign the latest attribute with the sorted column fieldName and sorted direction
    component.set("v.sortedBy", event.getParam("fieldName"));
    component.set("v.sortedDirection", event.getParam("sortDirection"));
    helper.sortData(component, fieldName, sortDirection);
    }
})
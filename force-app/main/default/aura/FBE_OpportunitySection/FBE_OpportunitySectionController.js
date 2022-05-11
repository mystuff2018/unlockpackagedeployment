({
    doinit : function(component, event, helper) {
        helper.fetchOpptyRecs(component, event, helper);
    },
    
    dofilter : function(component, event, helper) {
        helper.searchKeyChange(component, event, helper);       
    },
    
    selectedRadioOppty: function(component, event, helper) {     
        var selectedRecId =  event.target.value;
        component.set('v.opportunityId',selectedRecId);   
    }
    
    
})
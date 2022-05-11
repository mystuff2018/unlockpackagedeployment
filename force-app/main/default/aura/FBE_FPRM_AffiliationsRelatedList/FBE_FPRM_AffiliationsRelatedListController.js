({
    init : function(component, event, helper) {
        component.set('v.affiliationsCols', [
            { label: 'Affiliated Account', fieldName: 'FBE_Affilitated_Account__r_LinkName', type: 'url', typeAttributes: {label: { fieldName: "FBE_Affilitated_Account__r_Name" }, target: '_top'}},
            { label: 'Relationship', fieldName: 'FBE_Relationship__c', type: 'text'}
        ]);
    },
})
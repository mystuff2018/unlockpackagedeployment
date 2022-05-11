({
    init : function(component, event, helper) {
        /*var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set('v.currentUserId', $A.get("$SObjectType.CurrentUser.Id"));
        console.log('Contacts Related List >> User Id: '+component.get('v.currentUserId')) */
       if(component.get("v.viewAllRecords")== true)
       {
           component.set('v.contactCols', [
            { label: 'Contact Name', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
            { label: 'Email', fieldName: 'Email', type: 'email'},
            { label: 'Reseller Account', fieldName: 'FBE_FPRM_Reseller_Account__r_LinkName', type: 'url', typeAttributes: {label: { fieldName: "FBE_FPRM_Reseller_Account__r_Name" }, target: '_top'}},
            // { label: 'Reseller', fieldName: 'FBE_FPRM_Reseller_Flag__c', type:"boolean" },
            //{ label: 'Country Code', fieldName: 'Country_Code_CAM__c', type:"text" },
            //{ label: 'Work Phone', fieldName: 'Phone', type:"phone" },
            //{ label: 'Extension', fieldName: 'Extension_CAM__c', type:"text" },
          ]);
       }
       else{
            component.set('v.contactCols', [
                { label: 'Contact Name', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
                { label: 'Email', fieldName: 'Email', type: 'email'},
                { label: 'Reseller Account', fieldName: 'FBE_FPRM_Reseller_Account__r_LinkName', type: 'url', typeAttributes: {label: { fieldName: "FBE_FPRM_Reseller_Account__r_Name" }, target: '_top'}},
                 { label: 'Reseller', fieldName: 'FBE_FPRM_Reseller_Flag__c', type:"boolean" },
                { label: 'Country Code', fieldName: 'Country_Code_CAM__c', type:"text" },
                { label: 'Work Phone', fieldName: 'Phone', type:"phone" },
                { label: 'Extension', fieldName: 'Extension_CAM__c', type:"text" },
            ]);
            }
    },
})
({
	getContactUserData : function(component) {
		var action = component.get('c.getPartnerUser'); 
        action.setParams({
            "contactId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var data = JSON.parse(a.getReturnValue());
                console.log('data===' + a.getReturnValue());
                if(data.user){ 
                   this.showToastMessage(component,'Partner User is already on-boarded.','error');
                }
                else if(data.userRole.length === 0){
                    this.showToastMessage(component,'Kindly update contact primary account to Distributor Account and Reseller account to Disty Managed account before on-boarding.','error');
                }
                 else if(!data.contPhone){
                    this.showToastMessage(component,'Enter the work phone number before enabling the user.','error');
                }
                else{
                    this.setUpUserFormData(component, data);  
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    setUpUserFormData : function(component, contactData)
    {
        var createUserEvent = $A.get("e.force:createRecord");
        var contactFullName = contactData.contact.FirstName.concat(contactData.contact.LastName);
        var usernameFPRM = contactData.contact.Email;
        var aliasName = contactFullName.split(" ").join(""); 
        createUserEvent.setParams({
            "entityApiName": "User",  
            "defaultFieldValues": { 
                'ContactId' : component.get("v.recordId"),
                'FirstName' : contactData.contact.FirstName,
                'LastName' : contactData.contact.LastName,
                'Email' : contactData.contact.Email,
                'Username' : usernameFPRM+'.fprm',
                'UserRoleId' : contactData.userRole[0].Id, 
                'Alias' : aliasName.substring(0, 8),
                'Phone' : contactData.contPhone
            }
        });
        createUserEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    showToastMessage: function(component,msg,msgType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Partner User",
            "type": msgType,
            "message": msg
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
   
})
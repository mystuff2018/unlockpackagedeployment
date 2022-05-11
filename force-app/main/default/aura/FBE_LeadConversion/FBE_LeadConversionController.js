({
    onInit : function(component, event, helper) {        
        var recOwner = $A.get("$SObjectType.CurrentUser.Id");
        component.set('v.RecordType', $A.get("$Label.c.OpptyStandardRecTypeId"));
        component.set("v.recordOwner",recOwner);
        //Get Lead Record
        var action1 = component.get("c.getLeadDetails");
        action1.setParams({ leadId : component.get("v.recordId") });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Lead Record " + response.getReturnValue());
                var leadRec = response.getReturnValue();
                component.set('v.leadRec',leadRec);
                component.set('v.OpptyName',leadRec.Company);
                if(leadRec.FBE_End_User_Account__c!=null && leadRec.FBE_End_User_Account__r.Name!='' && leadRec.FBE_End_User_Account__r.Name!=undefined){
                    component.set('v.enduser',leadRec.FBE_End_User_Account__r.Name);
                    component.set('v.accountId',leadRec.FBE_End_User_Account__c);                    
                }                   
                else if(leadRec.FBE_Account_Name__c!=null && leadRec.FBE_Account_Name__r.Name!='' &&  leadRec.FBE_Account_Name__r.Name!=undefined){
                    component.set('v.AccName',leadRec.FBE_Account_Name__r.Name);
                    component.set('v.accountId',leadRec.FBE_Account_Name__c);                    
                }
                    else{component.set('v.enduser','');
                         component.set('v.AccName','');
                         component.set('v.accountId','');  
                         component.set('v.accNameEmpty',true);   
                        }
                
            }else{
                console.log('Error occured');
            }
            if(state!='INCOMPLETE'){
                component.set('v.isLoading',false);
            }
        });
        $A.enqueueAction(action1);
        
        var action = component.get("c.getCurrentUser");
        //action.setParams();
        action.setCallback(this,function(response1){
            var state1 = response1.getState();
               if(state1 = "SUCCESS"){
                component.set("v.ShowOrHideField",response1.getReturnValue());
            }  
            else{
                console.log('Error occured');
            }
      });
        $A.enqueueAction(action);
        
        
    },//close onInit
    
    onChangeCont: function (component, event, helper) {
        var val = component.find('selectCont').get('v.value');
        if(val!='newCont'){
            component.set('v.error',false);
            component.set('v.SelectedCont','existingCont');
        }
        if(val=='newCont'){
            component.set('v.contactId','');
        }
        if(!val){ component.set('v.contactId',''); }
        component.set('v.SelectedCont',val);
        
    },
    
    onChangeOppty: function (component, event, helper) {
        var val = component.find('selectOppty').get('v.value');
        if(val!='newOppty'){
            component.set('v.error',false);
            if(val == 'none'){
                component.set('v.opportunityId','');
                component.set('v.selectedValue', 'Converted without Opportunity');
            }
            if(val == 'existingOppty'){ 
                	component.set('v.selectedValue', 'Converted to Existing Opportunity');                
            }
        }
        if(val=='newOppty'){
            component.set('v.opportunityId','');
            component.set('v.selectedValue', 'Converted to New Opportunity');
        }
        
        component.set('v.SelectedOppty',val);
        
    },
    
    onChangeRecType: function (component, event, helper) {
        var recType = component.find('selectRecType').get('v.value');        
        if(recType=='standard')
            component.set('v.RecordType', $A.get("$Label.c.OpptyStandardRecTypeId"));
        else if(recType=='APOS')
            component.set('v.RecordType', $A.get("$Label.c.OpptyAPOSRecTypeId"));
            else if(recType=='channel')
                component.set('v.RecordType', $A.get("$Label.c.OpptyChannelRecTypeId"));
                else if(recType=='DFS')
                    component.set('v.RecordType', $A.get("$Label.c.OpptyDFSRecTypeId"));
        
    },
    OnClkdisableOppty: function (component, event, helper) {
        var checkVal = component.find('checkbox').get('v.value');        
        component.set('v.disableOppty',checkVal);
        if(checkVal){
            component.find('selectOppty').set('v.value','none');
            component.set('v.SelectedOppty','none');
        }
        component.set('v.selectedValue', 'Converted without Opportunity');
        
    },
    
    handleClick: function (component, event, helper) {
        console.log('opties lenght in handleclick :',component.get('v.existingOptySize'));
        if(!component.get('v.SelectedCont')){
            
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!","type":"error",
                    "message": "Contact is required for Conversion."
                });
                toastEvent.fire();
            
        }else if(component.get('v.SelectedCont')=='existingCont' && 
                 (component.get('v.contactId')=='' || component.get('v.contactId')==null || component.get('v.contactId')==undefined)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({ "title": "Error!","type":"error","message": "Please select a Contact."});                
            toastEvent.fire();
        }else if(component.get('v.SelectedOppty')=='existingOppty' && component.get('v.existingOptySize') >0 &&
                 ((component.get('v.opportunityId')=='' || component.get('v.opportunityId')==null || component.get('v.opportunityId')==undefined))){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({ "title": "Error!","type":"error","message": "Please select an opportunity."});                
            toastEvent.fire();
        }else if(component.get('v.SelectedOppty')=='existingOppty' && component.get('v.existingOptySize') == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({ "title": "Error!","type":"error","message": "Please create a new opportunity or select Don't create an opportunity upon conversion checkbox for conversion."});                
            toastEvent.fire();
        } else{       
        var error = false;       
        if(component.get('v.SelectedCont')=='newCont'){
            var reqFieldList = component.find('contRec');     
            if(reqFieldList!=null && reqFieldList!='' && reqFieldList!=undefined){
                reqFieldList.forEach(function(field){
                    if(!field.get("v.value") && (field.get('v.fieldName')=='LastName' || field.get('v.fieldName')=='Email')){
                        error= true;
                    }
                    if(field.get('v.fieldName')=='FirstName')
                        component.set('v.newContact.FirstName',field.get("v.value"));
                    if(field.get('v.fieldName')=='LastName')
                        component.set('v.newContact.LastName',field.get("v.value"));
                    if(field.get('v.fieldName')=='Country_Code_CAM__c')
                        component.set('v.newContact.Country_Code_CAM__c',field.get("v.value"));
                    if(field.get('v.fieldName')=='Phone')
                        component.set('v.newContact.Phone',field.get("v.value"));
                    if(field.get('v.fieldName')=='Extension_CAM__c')
                        component.set('v.newContact.Extension_CAM__c',field.get("v.value"));
                    if(field.get('v.fieldName')=='Email')
                        component.set('v.newContact.Email',field.get("v.value"));
                });
            }
        }  //newCont         
        if(component.get('v.SelectedOppty')=='newOppty'){
            var recordType = component.get('v.RecordType');
            component.set('v.newOpportunity.RecordTypeId',recordType);
            var reqFieldList = component.find('opptyRec');     
            if(reqFieldList!=null && reqFieldList!='' && reqFieldList!=undefined){
                reqFieldList.forEach(function(field){
                    if(!field.get("v.value")){                
                        error = true;
                    }
                    if(field.get('v.fieldName')=='Name')
                        component.set('v.newOpportunity.Name',field.get("v.value"));
                    if(field.get('v.fieldName')=='FBE_Pursuit_Type__c')
                        component.set('v.newOpportunity.FBE_Pursuit_Type__c',field.get("v.value"));
                    if(field.get('v.fieldName')=='Type')
                        component.set('v.newOpportunity.Type',field.get("v.value"));
                    if(field.get('v.fieldName')=='StageName')
                        component.set('v.newOpportunity.StageName',field.get("v.value"));
                    if(field.get('v.fieldName')=='FBE_Contracting_Status__c')
                        component.set('v.newOpportunity.FBE_Contracting_Status__c',field.get("v.value"));
                    if(field.get('v.fieldName')=='CloseDate')
                        component.set('v.newOpportunity.CloseDate',field.get("v.value"));
                    if(field.get('v.fieldName')=='FBE_Funding_Source__c')
                        component.set('v.newOpportunity.FBE_Funding_Source__c',field.get("v.value"));
                    if(field.get('v.fieldName')=='FBE_Storage_Selling_Motion__c')
                        component.set('v.newOpportunity.FBE_Storage_Selling_Motion__c',field.get("v.value"));
                });
            }
        }//newOppty            
        if(component.find('recordOwnerId').get('v.value')=='' || component.find('recordOwnerId').get('v.value')==undefined || component.find('recordOwnerId').get('v.value')==null){            
            error = true;
        }
        if(error){ component.set('v.error',true); }
        else{
            component.set('v.error',false);
            component.set("v.showSpinner", true); 
            var action = component.get('c.LeadConvert');
            console.log("recordOwner" ,component.find('recordOwnerId').get('v.value'));
            action.setParams({leadRec : component.get('v.leadRec'), 
                              newCont : component.get('v.newContact'), 
                              newOppty : component.get('v.newOpportunity'), 
                              existingOpp : component.get('v.opportunityId'), 
                              existingCont : component.get('v.contactId'), 
                              accountId : component.get('v.accountId'),
                              convertStatus : component.get('v.selectedValue'),
                              recordOwner : component.find('recordOwnerId').get('v.value')});
            action.setCallback(this,function(response){
                component.set("v.showSpinner", false); 
                var state = response.getState();
                if(state === "SUCCESS"){
                    var res =  response.getReturnValue();
                    console.log('res',res);
                    component.set('v.returnSObject',res);
                    if(res.successResult!=null && res.successResult!='' && res.successResult!=undefined && 
                       res.failureResult==null ){
                        console.log('Lead Converted Successfully-');
                        console.log('res.successResult lenght ::' ,res.successResult.length);
                        console.log('response0 ' , res.successResult[0]);
                        component.set('v.oppRec',res.successResult[0]);
                        
                        console.log('response1 ' , res.successResult[1]);
                        component.set('v.contRec',res.successResult[1]);
                        
                        var acId = component.get('v.accountId');
                        if(res.successResult.length == 2){
                            console.log('lenght -2 ');
                            helper.createComponent(component, event, acId, res.successResult[0].Id,res.successResult[1].Id);
                        }
                        if(res.successResult.length == 1){
                            console.log('lenght - 1');
                            helper.createComponent(component, event, acId, null ,res.successResult[0].Id);
                        }
                        $A.get("e.force:closeQuickAction").fire()
                    }
                    else{
                        console.log('fail msgs: ',res.failureResult);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: res.failureResult[0],
                            duration : "8000",
                            type: 'error',
                        });
                        toastEvent.fire();
                        
                        console.log('Error occured');
                    }
                    console.log(component.get('v.returnSObject'));
                }else{
                    console.log('Global Error');
                }
            });
            $A.enqueueAction(action);
        }//error else    
        }
        
        
        
    }         
    
    
    
})
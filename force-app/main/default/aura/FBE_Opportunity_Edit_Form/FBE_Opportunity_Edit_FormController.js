({
    init: function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        console.log('FieldSetFormController.init');
        var sectionfieldSetName = cmp.get('v.sectionfieldSetName');
        var sobjectName = cmp.get('v.sObjectName');
        var recordId = cmp.get('v.recordId');
        var getFormAction = cmp.get('c.getForm');
        getFormAction.setParams({
            "fieldSetName": sectionfieldSetName,
            "objectName": sobjectName,
            "recordId": recordId
        });
        
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            console.log('FieldSetFormController getFormAction callback');
            console.log("callback state: " + state);
            
            if (cmp.isValid() && state === "SUCCESS") { 
                var form = response.getReturnValue();
                console.log("form: " , form);
                console.log('Start date', form.fields.indexOf('FBE_Stage_Start_Date__c'));
                //console.log('contract name', form.fields[9].value);
               
                //console.log('trest'+form.fields[9].value);
                form.fields.splice(form.fields[0],1);
                form.fields.splice(form.fields.indexOf('FBE_Stage_Start_Date__c'),1);
                form.fields.splice(form.fields.indexOf('FBE_Opportunity_Close_Date__c'),1);
                form.fields.splice(form.fields.indexOf('FBE_Siebel_Deal_Reg_Id__c'),1);
                form.fields.splice(form.fields.indexOf('FBE_Siebel_Opportunity_Id__c'),1);
                form.fields.splice(form.fields.indexOf('FBE_EMC_Federal_Oppty_ID__c'),1);// legacy sf opty id- external id
                form.fields.splice(form.fields.indexOf('FBE_CPSD_Opportunity__c'),1);// external id
                
                cmp.set('v.sectionFields', form.fields);
                //console.log('fieldset '+cmp.set('v.sectionFields.ContractId',null));
                cmp.set('v.relatedProducts', form.products);
            }
            else if (state === "INCOMPLETE") {
                helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(cmp, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
                }
            }
            cmp.set("v.showSpinner", false);
        }
                                 );
        $A.enqueueAction(getFormAction);
    },
    
    
    
    onSubmitAction: function(component, event, helper){
        
        event.preventDefault();
        component.set("v.showSpinner", true);
        //console.log('v.recordId'+v.recordId);
        var recordId = component.get('v.recordId');
        var eventFields = event.getParam("fields");
        
        var objJSON = JSON.parse(JSON.stringify(eventFields));
        console.log('-------TTobjJSON-----',objJSON);
       
        //var recUi = event.getParam("recordUi");
        //console.log('-------recUi-----',recUi); 
        
        var callAction = component.get("c.submitUIValues");
        console.log('Unknown error'+JSON.stringify(eventFields));
        console.log('****recordId'+recordId);
        callAction.setParams({
            "jsonObject": JSON.stringify(eventFields),
            "recordId" : recordId,
            "lstProducts": component.get("v.relatedProducts")
        });
        
        console.log('^^^ prd');
        callAction.setCallback(this, function(response){
            
            var state = response.getState();
            component.set("v.showSpinner", false);
            console.log(state);
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
                helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(component, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
                }
            }
        });
        $A.enqueueAction(callAction);
        
    },
    
    removeOLI: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var recIndex = selectedItem.dataset.row;
        console.log('====',recIndex);
        var newLstOLIs = [];
        
        var lstOLIs = component.get("v.relatedProducts");
        //if (recIndex > -1) {
            lstOLIs.splice(recIndex, 1);
        //}
        //const filteredItems = lstOLIs.slice(0, recIndex).concat(lstOLIs.slice(recIndex+1, lstOLIs.length));
        component.set("v.relatedProducts", lstOLIs);
    },
    cancelAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOnload : function(component, event, helper) {
        /*var SiebelOppty = component.find("SiebelOppId").get("v.value");
        component.find("SiebelOppId").set("v.value","");*/
        /*var PrdClass = component.find("ProdClass").get("v.value");  
        console.log('&&***'+PrdClass);*/
        
        
        // Set Bookdate field to blank value
        let bookDate = component.find('makeblank').filter(x => x.get('v.fieldName') === 'CloseDate')[0];
		bookDate.set('v.value', "");
        // Set Opportunity Name field to blank value
        let Oppname = component.find('makeblank').filter(x => x.get('v.fieldName') === 'Name')[0];
        Oppname.set('v.value', "");
        // Set Opportunity Id as Current LoggedInUser
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        let OppOwner = component.find('makeblank').filter(x => x.get('v.fieldName') === 'OwnerId')[0];
        OppOwner.set('v.value', userId);
        //Set deal Reg fields to blank 'FBE_Linked_DealReg__c'
        let DealReg = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Linked_DealReg__c')[0];
        DealReg.set('v.value', "");
        // Set Integration Message and Integration Status fields to be blank
        let IntMsg = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Siebel_Integration_Message__c')[0];
        IntMsg.set('v.value', "");
      // Set Contract Name  fields to be blank
        let ContractName = component.find('makeblank').filter(x => x.get('v.fieldName') === 'ContractId')[0];
        ContractName.set('v.value', "");
        //let ContractLabel = component.find('makeblank').filter(x => x.get('v.fieldName') === 'ContractId')[0];
        //ContractLabel.set('v.label','Contract Name');
        let IntStatus = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Siebel_Integration_Status__c')[0];
        IntStatus.set('v.value', "Pending Sync");
        //Set Competitor and Win/loss fields to blank
        // Set SalesStage field to Intial LOV if the Opportunity is closed/cancelled/lost and set Win/loss reason field to blank
        let winlossReason = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Win_Loss_Reason__c')[0];
        let winlossDate = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Actual_Won_Lost_Date__c')[0];
        let winlossSummary = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Win_Loss_Summary__c')[0];
          winlossReason.set('v.value', "");
          winlossDate.set('v.value', null);// blank cannot be deserialize the date from Value_String
          winlossSummary.set('v.value', "");
        let competitor = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Competitors__c')[0];
        competitor.set('v.value', "");
        
        let vmWareEcms = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_VMware_ECMS__c')[0];
        vmWareEcms.set('v.value', "");
        let vmWareSfdcOpty = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_VMware_SFDC_Oppty__c')[0];
        vmWareSfdcOpty.set('v.value', "");
        let vmWarePSO = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_VMware_PSO_Credits__c')[0];
        vmWarePSO.set('v.value', false);
        
        //Story#9015810 - BDD1 - [Sireesha Myla] - 12/09/2020
        let salesStageset = component.find('makeblank').filter(x => x.get('v.fieldName') === 'StageName')[0];
        if(salesStageset.get('v.value') == 'Won - 100%' ||salesStageset.get('v.value') == 'Lost - 0%' ||salesStageset.get('v.value') == 'Cancelled - 0%')
        {
            salesStageset.set('v.value', 'Plan - 1%');
        }
        
        let recType = component.find('makeblank').filter(x => x.get('v.fieldName') === 'RecordTypeId')[0];
        recType.set('v.disabled', true);
        
       //Fields made Required as they are Required fields on Page Layouts 
       //DEFECT 9539948 - FBE: FY21-1101 GE4 - Federal UAT Defect: DFN SFDC: Opportunity - Ability to Clone without Sales Channel (and other fields) as mandatory field
        let salesChannelRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Pursuit_Type__c')[0];
         salesChannelRequired.set('v.required', true);  
        let prodClassificationRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Opportunity_Classification__c')[0];
         //prodClassificationRequired.set('v.required', true); [Dev Defect DEFECT 9753897]
         //console.log('&&&&& Log'+prodClassificationRequired.get('v.value'));
         
         prodClassificationRequired.set('v.disabled', true); // Made field Read only instead of removing from Clone layout 
        
        let OpptyTypeRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'Type')[0];
         OpptyTypeRequired.set('v.required', true); 
        let ContartingStatusRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Contracting_Status__c')[0];
         ContartingStatusRequired.set('v.required', true);
        let fundingSourceRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Funding_Source__c')[0];
         fundingSourceRequired.set('v.required', true);
        //let FedAllianceSegmentRequired = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_Federal_Alliance_Segment__c')[0];
        //FedAllianceSegmentRequired.set('v.required', true);
        
        //Story #8932428 - [Siva Kumar Valluru] - Feb Release 2021
 		 let SalesOrder = component.find('makeblank').filter(x => x.get('v.fieldName') === 'FBE_SO_Nums_Opp__c')[0];
		SalesOrder.set('v.value', "");
        
        //Story #9156792 - [Sireesha Myla] - Feb Release 2021
        if(prodClassificationRequired.get('v.value') != null )
         {
             //alert("Hey You are not allowed to Clone with a Product classification value ");
             $A.get("e.force:closeQuickAction").fire();// Defect 10027730 - Sireesha Myla
             helper.showNotifyLibHelper(component, 'Error!', 'error', "Users are unable to Clone opportunities that were created prior to the February 2021 release. Please manually create an opportunity.");
         }
               
	}

})
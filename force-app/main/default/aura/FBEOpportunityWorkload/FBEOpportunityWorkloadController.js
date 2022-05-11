({
    doInit: function(component, event, helper) {
        var optyId = component.get("v.parentRecordId");//console.log("optyId",optyId);
        if(optyId == null || optyId == ''){
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.context", context);
        component.set("v.parentRecordId", context.attributes.recordId);
        }
        helper.doInitHelper(component, event); 
    },
    CancelOptyWrkld : function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.parentRecordId')  });
        navigateEvent.fire();
       
    },   
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");//console.log(event.getSource().get("v.text"));
        var selectedObjectRecordsEvent = {};
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var mainList = component.get("v.listOfAllWorkloads"); 
        var selectList = component.get("v.listOfSelectedRecords"); 
        var Id = event.getSource().get("v.text");
        var name = event.getSource().get("v.name");//console.log(name);
        selectedObjectRecordsEvent['Id'] = Id;//console.log('selectedObjectRecordsEvent',JSON.stringify(selectedObjectRecordsEvent));
        selectedObjectRecordsEvent['Name'] = name;        
        if (selectedRec == true) {
            //add to selected list
            listSelectedItems.push(selectedObjectRecordsEvent);//console.log('listSelectedItems1',JSON.stringify(listSelectedItems));
            component.set("v.lstSelectedRecords", listSelectedItems);             
        } else {
            component.find("selectAllId").set("v.value", false);
            var i = 0;
            //remove from selected list
            listSelectedItems.forEach(function(e) {               
                if(e.Id == Id){
                    //console.log(i);
                    listSelectedItems.splice(i,1);                    
                }i++;
            });
            //console.log('listSelectedItems',listSelectedItems);
            //uncheck in main list 
            mainList.forEach(function(e) {               
                if(e.Id == Id){ 
                    e.isChecked = false;               
                }i++;
            });
 
            //uncheck in select list
            /*  selectList.forEach(function(e) {               
               if(e.ObjProduct2.Id == Id){
                	e.isChecked = false;   console.log('selectList',e.isChecked);                 
                }i++;
            });  */     
        }

    },
    handleAddToOpportunity: function (component, event, helper) {
        var selectedlist = component.get("v.lstSelectedRecords");
        if(typeof(selectedlist) != "undefined" && selectedlist.length > 0){
            helper.handleAddWorkload(component, event, helper); 
        }else{
            helper.showToast({
                "title": "Error!!",
                "type": "error",
                "message": "Please select Workload first to associate it."
            }); 
        }
        
        
    },   
    handleNewWrkld : function(component, event, helper) {
    	 helper.toggleModel(component,event);
    },
    closeModel : function(component, event, helper) {
       helper.toggleModel(component,event);       
	},     
    handleSuccess : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Workload Created",
            "message": "Record ID: " + event.getParam("id")
        });
    } ,
    openCreateWrkld : function(component, event, helper) { //Method for the Action on the  CreateInteraction Button
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "FBE_Workloads__c",
            "recordTypeId": component.get("v.masterRecTypeID"),
            "defaultFieldValues": {
                'FBE_Account__c': component.get('v.accountId'),
            },
            "navigationLocation" : "RELATED_LIST" 
        });
        createRecordEvent.fire();  
    } ,   
    toastInfo: function(component, event, helper) {
        var res = event.getParams().message.split(" ");
        if(res[0]=="Workloads" && res[1].startsWith("WL-") && res[2]=="was" && res[3]=="created."){
        	helper.doInitHelper(component, event);
        }
    }
})
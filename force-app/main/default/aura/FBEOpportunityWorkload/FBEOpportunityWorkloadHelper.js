({
    doInitHelper : function(component,event){
        var action = component.get("c.fetchWorkload");//console.log("recordId"+component.get("v.parentRecordId"));
        action.setParams({
            'optyId': component.get("v.parentRecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                //console.log("ORes Value: "+JSON.stringify(oRes));
                if(oRes != null){
                    component.set('v.listOfAllWorkloads', oRes.workloadList);
                    component.set('v.accountId', oRes.accountId);
                    component.set("v.bNoRecordsFound" , false);
                    component.set("v.masterRecTypeID",oRes.workloadRecordTypeId);
                }
                if(oRes.workloadList != null && oRes.workloadList.length <=0){
                    component.set("v.bNoRecordsFound" , true);
                }
            }
            else{
                alert('Error');
            }
        });
        $A.enqueueAction(action); 
    },
    handleAddWorkload: function (component, event, helper) {       
        var action = component.get("c.AddToOpportunity");
        var selectedlist = component.get("v.lstSelectedRecords");   
        var OptyId = component.get("v.parentRecordId");
        //console.log(JSON.stringify(selectedlist));  
        
        var ids=new Array();
        for (var i= 0 ; i < selectedlist.length ; i++){
            ids.push(selectedlist[i].Id);
        }
        
        var WorkloadIdStr=JSON.stringify(ids);
        //var ProductIdStr = JSON.stringify(selectedlist);
        //console.log(OptyId);
        //console.log(WorkloadIdStr);
        /* if(selectedlist.length > 0)
        { var ProductId =[];
        for (var i = 0; i < selectedlist.length; i++)
        ProductId= selectedlist[i].Id;}  */
         
         //console.log("length" + selectedlist.length +""+ "OptyId" + OptyId); 
         action.setParams({ 
             "WorkloadId":WorkloadIdStr,
             "OptyId": OptyId
         });
         
         action.setCallback(this, function (response){
             var state = response.getState();
             //console.log(state);
             if (state === "SUCCESS") {
                 if(response.getReturnValue() === null){
                     //console.log("Response" + selectedlist.length);
                     helper.showToast({
                         "title": "Workload Added successfully",
                         "type": "success",
                         "message": "Saved successfully"
                     });
                     var navigateEvent = $A.get("e.force:navigateToSObject");
                     navigateEvent.setParams({ "recordId": OptyId});
                     navigateEvent.fire();
                     helper.delayedRefresh();
                     
                 } else{ //if update got failed
                     helper.showToast({
                         "title": "Error!!",
                         "type": "error",
                         "message": "Error in update"
                     });
                 }
                 //activate from application and not console
                 
             } else if (state === "ERROR") {
                 var errors = action.getError();
                 //console.error(errors);
                 helper.showToast({
                     "title": "Error!!",
                     "type": "error",
                     "message": errors[0].message
                 });
                 //helper.fireFailureToast(component);  
             }
         });
         $A.enqueueAction(action);
         return true;
     },
    
    showToast : function(params){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }, 
    toggleModel: function(component, event){
        var status = component.get("v.newWorkload");
        component.set("v.newWorkload", !status);
        
    }, 
    navigateToMyComp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:FBEOpportunityWorkload",
            componentAttributes: {
                parentRecordId : component.get("v.parentRecordId")
            }
        });
        evt.fire();
    },
    delayedRefresh : function(milliseconds){
        let ms = milliseconds || 1000;
        window.setTimeout($A.getCallback(function(){
            //$A.get('e.force:refreshView').fire();console.log("called");
            location.reload();  
        }),ms);
    },    
})
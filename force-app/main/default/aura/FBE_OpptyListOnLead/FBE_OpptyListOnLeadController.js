({
	doInitialization : function(component, event, helper) {
        
        var leadrecId = component.get("v.recordId");       
        var action =component.get('c.getOpptyList');
        var existingOpptyArray=[];
        var title="Open Opportunities";
        action.setParams({
            LeadId : leadrecId
        });
        action.setCallback(this,function(response){     
            var state=response.getState();
            console.log('state ==> ' +state);
            console.log('getReturnValue() ==> ' +response.getReturnValue());
            var responseVal=response.getReturnValue();
            
            component.set("v.OpptyNumber",title);
            if(state==="SUCCESS")
            {
                var responseLength=response.getReturnValue().length;
                if(responseLength <= 3)
                {                    
                    component.set("v.OpptyNumber",title + ' ' + '(' + response.getReturnValue().length + ')');
                    component.set("v.opptyList",response.getReturnValue());
                }
                else
                {
                    component.set("v.OpptyNumber",title + ' ' + '(' + '3+' + ')');
                    
                    for(var i=0; i<3;i++)
                    {
                        existingOpptyArray.push(response.getReturnValue()[i]);
                    }
                    component.set("v.opptyList",existingOpptyArray);
                }            
            }
        });
        $A.enqueueAction(action);           
 },
  
        handleClick: function(component, event, helper) {
        var parentId= component.get("v.simpleRecord.FBE_End_User_Account__c");
        var LeadName= component.get("v.simpleRecord.Name");
        var LeadId = component.get("v.simpleRecord.Id");
         console.log('ParentID####'+parentId);   
         var pageReference = {
            "type": 'standard__component',
            "attributes": {
                "componentName": 'c__FBE_OpenOpptyListPage',
                
            },
            "state": {
                
                "c__LeadId" : LeadId,
                "c__accountId": parentId,
                "c__LeadName" : LeadName
            }
        };   
            component.set("v.pageReference", pageReference);
            var navService = component.find("navService");
            var pageReference = component.get("v.pageReference");
            event.preventDefault();
        
            helper.navService2(component, pageReference);
            helper.delayedRefresh();
    }
 
})
({
	helperMethod : function(component, event) {
        component.set('v.columns', [
            {label: 'Request #', fieldName: 'FBE_Sequence_Number__c', type: 'number'},
            {label: 'Deal Extension #', fieldName: 'Name', type: 'text'}, 
            {label: 'Extension Request Reason', fieldName: 'FBE_Extension_Request_Reason__c', type: 'text'},
             {label: 'Extension Request Status', fieldName: 'FBE_Extension_Request_Status__c', type: 'text'},
             {label: 'Approval/Rejection Reason', fieldName: 'FBE_Approval_Rejection_Reason__c', type: 'text'}, 
            {label: 'Approved/Rejected By', fieldName: 'RejectedBy', type: 'text'}
        ]);
        console.log('deal id - cmp2',component.get( "v.idval" ));
        var action = component.get('c.fetchRecords');
        action.setParams({
            "recordIds" : component.get( "v.idval" )
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('***SUCCESS****');
                var rows = response.getReturnValue();
                console.log('rows value : '+rows);
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    console.log('Rejcted by**'+row.FBE_Approved_Rejected_By__c);
                    // checking if any rejectedBY related data in row
                   
                    if(row.FBE_Extension_Request_Status__c !== 'Submitted' ){
                       console.log('Rejcted by**1'+row.FBE_Approved_Rejected_By__c);
                        
                        // Start Defect #11200750 - Sireesha Myla
                        if(row.FBE_Approved_Rejected_By__c === undefined)
                        {
                            row.RejectedBy = null;
                        }
                        else{
                            row.RejectedBy = row.FBE_Approved_Rejected_By__r.Name;
                        } // End Defect #11200750
                        
                         
                         
                    }
                }
                console.log('responseValue: ',rows);
                //component.set('v.data',rows);
                component.set('v.relatedList',rows);
                console.log('related producst::: '+ component.get( "v.relatedList" ));
            }else{
                 console.log('errorss :: ',response.getError());
             }
        });
        $A.enqueueAction(action);
    }
})
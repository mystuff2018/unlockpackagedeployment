({
fetchAccTeam : function(component, event, helper) {
    
        var action = component.get("c.getAccTeam");
        console.log('action ', action);
        var accid = component.get("v.accountId");
        console.log('accid' , accid);
        action.setParams({ accountId : component.get("v.accountId") });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state' ,state);
            if(state == "SUCCESS"){
                
                component.set('v.mycolumns', [
                    {label: 'Team Member', fieldName: 'UserUrl', type: 'url', typeAttributes:{
                        label: {
                            fieldName: 'FBE_User_Name__c'
                        }}, sortable: 'true', cellAttributes:
                     { iconName: 'action:user' , iconPosition: 'left' }},
                    {label: 'Team Role', fieldName: 'TeamMemberRole', type: 'text', sortable: 'false'}
                ]);
                
                var memList = response.getReturnValue();
                
                memList.forEach(function(item){
                    item['UserUrl'] = '/lightning/r/User/' +item['Id'] +'/view';
                });
                
                component.set("v.returnedTeam",response.getReturnValue());
                console.log('ATM values ' ,response.getReturnValue());
                console.log('Team lenghth: ',response.getReturnValue().length);
                component.set("v.Teamsize",response.getReturnValue().length);
                    
            }else{
                console.log('Error occured');
            }
        });
        $A.enqueueAction(action);
	},
    
sortData: function (component, fieldName, sortDirection) {
     var data = component.get("v.returnedTeam");
     var reverse = sortDirection !== 'asc';
     //sorts the rows based on the column header that's clicked
     data.sort(this.sortBy(fieldName, reverse))
     component.set("v.returnedTeam", data);
     },
 sortBy: function (field, reverse, primer) {
     var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
     //checks if the two rows should switch places
     reverse = !reverse ? 1 : -1;
     return function (a, b) {
         return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
     }
 }
})
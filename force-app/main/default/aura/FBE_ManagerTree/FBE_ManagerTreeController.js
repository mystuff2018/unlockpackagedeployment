({
    doInit: function (cmp, event, helper) {
        /* Defect #11326843 - added the tooltip*/
        /* Defect #11296995 - converted the string into amount */
        cmp.set('v.gridColumns', [
            {label: 'Team Member/Account Name', fieldName: 'name', type: 'url',initialWidth: 225, 
            typeAttributes: {label: { fieldName: 'nameL' }, target: '_blank',tooltip: { fieldName: 'nameL' }}},
            {label: 'Team Member Role', fieldName: 'teamMemRole', type: 'text',initialWidth: 155},
            {label: 'Account Type', fieldName: 'accType', type: 'text',initialWidth: 120},
            {label: 'Opportunity Name', fieldName: 'oppLink', type: 'url',initialWidth: 155, 
            typeAttributes: {label: { fieldName: 'oppname' }, target: '_blank',tooltip: { fieldName: 'oppname' }}},
            {label: 'Stage', fieldName: 'Stage', type: 'text',initialWidth: 120},
            {label: 'Time in stage', fieldName: 'stageDuration', type: 'number',initialWidth: 145},
            {label: 'Projected close', fieldName: 'closeDate', type: 'Date'},
            {label: 'Amount', fieldName: 'amount', type: 'currency'},
            ]);
          helper.getData(cmp);
    },
    filterByuser : function (cmp, event, helper) {
            var selPickListValue = event.getSource().get("v.value") ;
            var getDta = cmp.get("v.gridData");
            //cmp.set("v.gridData",'');
            //console.log('selPickListValue'+getDta);
            for(var i = 0; i < getDta.length; i++){
                if(getDta[i].nameL == selPickListValue){
            		console.log('selPickListValue'+getDta[i]);
            		cmp.set('v.all',false);
                	cmp.set("v.gridFilData",getDta[i]);
                }else if(selPickListValue == 'ALL'){
                    cmp.set('v.all',true);
                }
            }
    }
 
})
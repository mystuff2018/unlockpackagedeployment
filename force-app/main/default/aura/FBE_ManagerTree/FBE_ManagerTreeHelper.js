({
    getData : function (cmp) {
        var action = cmp.get("c.getTreeGridData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var usersList = [];
                usersList.push('ALL');
                //console.log('Parse'+JSON.stringify(data));
                var temojson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
                console.log('griddata#####'+JSON.parse(temojson));
                if(JSON.parse(temojson).length === 0){
                   cmp.set('v.nullCheck',true);
                }
                cmp.set('v.gridData', JSON.parse(temojson));
                for(var i = 0 ; i< JSON.parse(temojson).length; i++){
                    usersList.push(JSON.parse(temojson)[i].nameL);
                }
                console.log('usersList'+usersList);
                cmp.set('v.all',true);
                cmp.set('v.userList', usersList);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    }
})
({
    doInits: function(component) {
        var strAccId = component.get("v.recordId");
        console.log('Account Id ====>'+strAccId);
        $A.createComponent("c:ApprovalUltimateController", 
                           {strRecordId : strAccId},
                           function(result, status) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLibDemos').showCustomModal({
                                       header: "Deal Edit Form",
                                       body: result, 
                                       showCloseButton: false,
                                       cssClass: "mymodal", 
                                   })
                               }                               
                           });
    }
})
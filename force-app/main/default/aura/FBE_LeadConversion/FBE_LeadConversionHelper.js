({
	createComponent : function(component, event, actId, opporId, contId) {
        console.log('inisde createComponent');
        console.log('opporId: ',opporId);
        $A.createComponent("c:FBE_SuccessPage", 
                           {acntId : actId,
                             optId : opporId,
                            conId : contId
                            },
                           function(result, status) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLibDemo').showCustomModal({
                                       header: "Your Lead has been converted",
                                       body: result, 
                                       showCloseButton: false,
                                       cssClass: "successPageModal",
                                   })
                               }                               
                           });
       component.find("overlayLibDemo").notifyClose();
        
    }
})
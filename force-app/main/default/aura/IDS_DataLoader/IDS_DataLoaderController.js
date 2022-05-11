({    
    handleSave: function(component, event, helper) {
        //alert(component.find("fuploader").get("v.files").contentType);
        if (component.find("fuploader").get("v.files").length > 0 && component.find("fuploader").get("v.files")[0].type =='text/plain') {
            helper.uploadHelper(component, event);
        	
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
                title : 'Success',
                message: 'Your file is succesfully processed',
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
        	});
        	toastEvent.fire();
        } else {
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
                title : 'Error',
                message: 'Please select a text file.',
                duration:' 5000',
                key: 'info_alt',
                type: 'Error',
                mode: 'pester'
        	});
        	toastEvent.fire();
        }
    },
     
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            //alert(event.getSource().get("v.files")[0]['type']);
        }
        component.set("v.fileName", fileName);
        component.find("actionButton1").set('v.disabled',false);
        component.find("actionButton2").set('v.disabled',false);
    },
     
    handleCancel: function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
        location.reload();
    },
    
    enableFileInput: function(component, event, helper) {
        //alert(component.find("fuploader").get("v.disabled"));
        if(component.find("select").get("v.value") != 'choose file category...'){
            component.find("fuploader").set("v.disabled", false); 
        }else{
            component.find("fuploader").set("v.disabled", true); 
        }
    }
})
({
	doSave : function(component, event, helper) {
		if (component.find("fileId").get("v.files") == undefined ) {
           
           alert('Please Select a Valid csv File');
        } else if(component.find("fileId").get("v.files").length > 1){
            alert('Please Select one CSV file only');
        } else if(component.find("fileId").get("v.files").length == 1){
            helper.uploadHelper(component, event);
            alert(component.find("fileId").get("v.files"));
        }
	},
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    }
})
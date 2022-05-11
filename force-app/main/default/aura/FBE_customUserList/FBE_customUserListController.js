({
	doInit : function(component, event, helper) {
        var action = component.get("c.getRoleSubordinateUsers");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            'userId': userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse.length>0){
                console.log(JSON.parse(JSON.stringify(storeResponse)));
                component.set("v.userList",JSON.parse(JSON.stringify(storeResponse)));
                console.log( component.get("v.userList"));
                component.set("v.test","true");
                } else{
                   component.set("v.bNoRecordsFound","true"); 
                }
                if(storeResponse.length>5){
                   component.set("v.showViewAll","true");   
                }
               }
        });         
        $A.enqueueAction(action);		
	},

    
    downloadCsv : function(component, event, helper) {
        var lstPositions = component.get("v.userList");
        var PositionTitle = 'Users Under Me';
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        //Provide the title 
        var CSV = 'All Users Under You';
        
        //Fill out the Header of CSV
		headerArray.push('S.NO');
        headerArray.push('UserId');
        headerArray.push('Name');
        headerArray.push('Role');
        headerArray.push('Email');
        headerArray.push('LastLoginDate');
        data.push(headerArray);

        var sno = 0;
        for(var i=0;i<lstPositions.length;i++){
            
            //Check for records selected by the user
           // if(lstPositions[i].isSelected){
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+lstPositions[i].Id+'"');
                tempArray.push('"'+lstPositions[i].Name+'"');
            tempArray.push('"'+lstPositions[i].UserRole.Name+'"');
            tempArray.push('"'+lstPositions[i].Email+'"');
            tempArray.push('"'+lstPositions[i].LastLoginDate+'"');
                data.push(tempArray);
           // }
            
        }
        
        for(var j=0;j<data.length;j++){
            var dataString = data[j].join(",");
            csvContentArray.push(dataString);
        }
        var csvContent = csvContentArray.join("\n");
        
        //Generate a file name
        var fileName = "MyReport_";
        //this will remove the blank-spaces from the title and replace it with an underscore
        fileName += PositionTitle.replace(/ /g,"_");   
        fileName += ".csv";
        //Initialize file format you want csv or xls
        var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        
        if (navigator.msSaveBlob) { // IE 10+
            console.log('----------------if-----------');
            var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
            console.log('----------------if-----------'+blob);
        	navigator.msSaveBlob(blob, fileName);
        }
        else{
            // Download file
            // you can use either>> window.open(uri);
            // but this will not work in some browsers
            // or you will not get the correct file extension    
            var link = document.createElement("a");

            //link.download to give filename with extension
            //link.download = fileName;
            link.setAttribute('download',fileName);
            //To set the content of the file
            link.href = uri;
            
            //set the visibility hidden so it will not effect on your web-layout
            link.style = "visibility:hidden";
            
            //this part will append the anchor tag and remove it after automatic click
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
          
    	}
    },
    navigateToViewAll  : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:FBE_customUserFullList",
            componentAttributes: {
                userList : component.get("v.userList")
            }
        });
        evt.fire();
    },
    sortData: function(component, event, helper){
      var sortOrder = event.target.getAttribute('data-value');
        var sortBy = event.target.getAttribute('data-index');
        var userlist = component.get("v.userList");
        var sortedList = userlist.sort(helper.compareValues(sortBy,sortOrder));
        component.set("v.userList",sortedList);
        if(sortedList.length>0 && component.get("v.sortOrder") == "asc"){
            component.set("v.sortIcon","utility:chevrondown");
            component.set("v.sortOrder","desc");
        }else{
            component.set("v.sortIcon","utility:chevronup");
            component.set("v.sortOrder","asc");
        }
    }   
    
})
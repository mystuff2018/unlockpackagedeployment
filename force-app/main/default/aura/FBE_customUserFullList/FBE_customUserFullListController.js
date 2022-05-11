({
	doInit : function(component, event, helper) {
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = component.get('v.userList');
        var totalLength = totalRecordsList.length ;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);
        var PaginationLst = [];
        for(var i=0; i < pageSize; i++){
            if(component.get("v.userList").length > i){
                PaginationLst.push(totalRecordsList[i]);    
            } 
        }//console.log(component.get("v.lstSelectedRecords"));
        component.set('v.PaginationList', PaginationLst);
        //component.set("v.selectedCount" , 0);                    
        component.set("v.totalPagesCount", Math.ceil(totalLength/pageSize));        
		
	},
      handlecancel : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/lightning/page/home"
        });
        urlEvent.fire();
        },    
    navigation: function(component, event, helper) {
        var sObjectList;
        if(component.get("v.callType") == 'init'){
            sObjectList = component.get("v.userList");  
        } else if(component.get("v.callType") == 'search'){
            sObjectList = component.get("v.listOfSearchRecords");  
        }        
       //sObjectList = component.get("v.userList"); 
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");        
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }        
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },    
  /*  LoadMore:function (component, event, helper) {
        var limit = component.get('v.limit')+50;console.log("limit",limit);console.log("listsize",component.get('v.listSize'));
        if ((component.get('v.listSize')-limit) <= 0 ) {
            component.set('v.enableInfiniteLoading', false);
        } else {
        event.getSource().set("v.isLoading", true);
        component.set('v.currentData',component.get('v.userList').slice(0, limit));
        component.set('v.limit',limit);
                }
        event.getSource().set("v.isLoading", false);
    },*/
    keyPressController : function(component, event, helper) {
        component.set("v.callType", 'search' );
        var userList = component.get('v.userList');
        var searchResult= [];
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");  console.log(getInputkeyWord);
        if(getInputkeyWord.length > 2){
            
            for(var j=0; j<userList.length; j++){  
                if(userList[j].Name.toUpperCase().includes(getInputkeyWord.toUpperCase())
                   || userList[j].Email.toUpperCase().includes(getInputkeyWord.toUpperCase())
                   || userList[j].UserRole.Name.toUpperCase().includes(getInputkeyWord.toUpperCase()))
                {
                    searchResult.push(userList[j]);
                }
            } console.log("searchResult",searchResult); 
        }
            if(getInputkeyWord.length == 0){
            	searchResult = userList;
            }
            component.set("v.listOfSearchRecords", searchResult );
			var pageSize = component.get("v.pageSize");
            var totalRecordsList = searchResult;
            var totalLength = totalRecordsList.length ;
            component.set("v.totalRecordsCount", totalLength);
            component.set("v.startPage",0);
            component.set("v.endPage",pageSize-1);
            var PaginationLst = [];
            for(var i=0; i < pageSize; i++){
                if(component.get("v.listOfSearchRecords").length > i){
                    PaginationLst.push(searchResult[i]);    
                } 
            }
            component.set('v.PaginationList', PaginationLst);//console.log(PaginationLst);
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
            
           
        }, 
    downloadCsv : function(component, event, helper) {
        var lstPositions = component.get("v.userList");
        var PositionTitle = 'My Team';
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        
        //Provide the title 
        var CSV = 'All Users Under You';
        
        //Fill out the Header of CSV
		headerArray.push('S.NO');
        headerArray.push('Name');
        headerArray.push('Email');
        headerArray.push('Role');        
        headerArray.push('LastLoginDate');
        data.push(headerArray);

        var sno = 0;
        for(var i=0;i<lstPositions.length;i++){
            var tempArray = [];
            var datetime;
            if(typeof(lstPositions[i].LastLoginDate) !== "undefined" && lstPositions[i].LastLoginDate !== null){
                datetime = new Date(lstPositions[i].LastLoginDate);
                datetime = datetime.toLocaleString('en-US', { year: 'numeric',month: 'numeric',day: 'numeric',hour: '2-digit', minute: '2-digit', hour12: true });
            }else{
                datetime = "";  
            }
            //use parseInt to perform math operation
            sno = parseInt(sno) + parseInt(1);
            tempArray.push('"'+sno+'"');
            tempArray.push('"'+lstPositions[i].Name+'"');
            tempArray.push('"'+lstPositions[i].Email+'"');
            tempArray.push('"'+lstPositions[i].UserRole.Name+'"');            
            tempArray.push('"'+datetime+'"');
            data.push(tempArray);           
            
        }
        
        for(var j=0;j<data.length;j++){
            var dataString = data[j].join(",");
            csvContentArray.push(dataString);
        }
        var csvContent = csvContentArray.join("\n");
        
        //Generate a file name
        var fileName = "Report: ";
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
    sortData: function(component, event, helper){
      var sObjectList;
        if(component.get("v.callType") == 'init'){
            sObjectList = component.get("v.userList");  
        } else if(component.get("v.callType") == 'search'){
            sObjectList = component.get("v.listOfSearchRecords");  
        } console.log(sObjectList);
        var sortOrder = event.target.getAttribute('data-value');
        var sortBy = event.target.getAttribute('data-index');
       // var userlist = component.get("v.userList");
        var sortedList = sObjectList.sort(helper.compareValues(sortBy,sortOrder));
        
			var pageSize = component.get("v.pageSize");
            var totalRecordsList = sortedList;
            var totalLength = totalRecordsList.length ;
            component.set("v.totalRecordsCount", totalLength);
            component.set("v.startPage",0);
            component.set("v.endPage",pageSize-1);
            var PaginationLst = [];
            for(var i=0; i < pageSize; i++){
                if(sortedList.length > i){
                    PaginationLst.push(sortedList[i]);    
                } 
            }
            component.set('v.PaginationList', PaginationLst);//console.log(PaginationLst);
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        
        if(sortedList.length>0 && component.get("v.sortOrder") == "asc"){
            component.set("v.sortIcon","utility:chevrondown");
            component.set("v.sortOrder","desc");
        }else{
            component.set("v.sortIcon","utility:chevronup");
            component.set("v.sortOrder","asc");
        }
    }       
})
({
    searchHelper : function(component,event,getInputkeyWord) {       
        var action = component.get("c.fetchLookUpValues");
        
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
           // 'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
            'dealRegId' : component.get("v.parentRecordId")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }//console.log(storeResponse);
                component.set("v.listOfSearchRecords", storeResponse); 
               // component.set('v.PaginationList', storeResponse);
                
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = storeResponse;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                var selectedRec = component.get("v.lstSelectedRecords");console.log(selectedRec);
                    if(selectedRec.length > 0){
                    for(var j=0; j<storeResponse.length; j++){                        
                        for(var k=0; k<selectedRec.length; k++){
                            if(selectedRec[k].Id == storeResponse[j].ObjProduct2.Id){console.log('match found in search');
                                storeResponse[j].isChecked = true;
                            }
                        }
                    }console.log(storeResponse);
                    }
               	var mainList = component.get("v.listOfAllProducts");  
                if(selectedRec.length > 0 && mainList.length > 0){
                    for(var j=0; j<mainList.length; j++){                        
                        for(var k=0; k<selectedRec.length; k++){
                            if(selectedRec[k].Id == mainList[j].ObjProduct2.Id){console.log('match found in main');
                                mainList[j].isChecked = true;
                            }
                        }
                    }
                    }
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfSearchRecords").length > i){
                            PaginationLst.push(storeResponse[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);//console.log(PaginationLst);
                    //component.set("v.selectedCount" , 0);                    
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
            }
        });         
        $A.enqueueAction(action);
    },
    doInitHelper : function(component,event){
        var action = component.get("c.fetchProductWrapper");
       action.setParams({
            'dealRegId': component.get("v.parentRecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                //console.log("ORes Value: "+JSON.stringify(oRes));
                if(oRes.length > 0){
                    component.set('v.listOfAllProducts', oRes);
                    component.set('v.priceBookList', oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var selectedRec = component.get("v.lstSelectedRecords");
                    if(selectedRec.length > 0){
                    for(var j=0; j<oRes.length; j++){                        
                        for(var k=0; k<selectedRec.length; k++){
                            if(selectedRec[k].Id == oRes[j].ObjProduct2.Id){console.log('match found in main');
                                oRes[j].isChecked = true;
                            }
                        }
                    }//console.log(oRes);
                    }
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllProducts").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }//console.log(component.get("v.lstSelectedRecords"));
                    component.set('v.PaginationList', PaginationLst);
                    //component.set("v.selectedCount" , 0);                    
                    component.set("v.totalPagesCount", Math.ceil(totalLength/pageSize));
                }else{
                   
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error');
            }
        });
        $A.enqueueAction(action);  
    },
       getParameterByName: function(component, event, name) {
            name = name.replace(/[\[\]]/g, "\\$&");
            var url = window.location.href;
            var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
            var results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        },
        handlecancel : function(component, event, helper) {
               // alert("test cancel") ;
            // activate from application view
            var navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": component.get('v.parentRecordId')  });
            navigateEvent.fire();
        },

      next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
      
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
     handleSaveDealProduct: function (component, event, helper) {       
        var action = component.get("c.UpdateDealProduct");
        var selectedlist = component.get("v.lstSelectedRecords");   
        var DealRegId = component.get("v.parentRecordId");
        console.log(JSON.stringify(selectedlist));  
        
        var ids=new Array();
        for (var i= 0 ; i < selectedlist.length ; i++){
             ids.push(selectedlist[i].Id);
        }

        var ProductIdStr=JSON.stringify(ids);
        //var ProductIdStr = JSON.stringify(selectedlist);
        console.log(DealRegId);
        console.log(ProductIdStr);
       /* if(selectedlist.length > 0)
        { var ProductId =[];
        for (var i = 0; i < selectedlist.length; i++)
        ProductId= selectedlist[i].Id;}  */
        
         console.log("length" + selectedlist.length +""+ "DealId" + DealRegId); 
         action.setParams({ 
             "ProductId":ProductIdStr,
        	"DealRegId": DealRegId
        });
                 
        action.setCallback(this, function (response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue() === null){
                     console.log("Response" + selectedlist.length);
                    helper.showToast({
                        "title": "Deal Product Saved successfully",
                        "type": "success",
                        "message": "Saved successfully"
                    });
                    var navigateEvent = $A.get("e.force:navigateToSObject");
        			navigateEvent.setParams({ "recordId": DealRegId});
         			navigateEvent.fire();
                    //YM:3/16 - commented to allow view refresh & navigation to Deal record, under tech debt task
                    //helper.reloadDataTable();
                    
                } else{ //if update got failed
                    helper.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": "Error in update"
                    });
                }
                //activate from application and not console
             
            } else if (state === "ERROR") {
                var errors = action.getError();
                console.error(errors);
                helper.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": errors[0].message
                    });
                //helper.fireFailureToast(component);  
            }
        });
        $A.enqueueAction(action);
        return true;
    },
    
    showToast : function(params){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },
    
    reloadDataTable : function(component) {
     /*   
        var refreshEvent = $A.get("e.force:refreshView");
        if(refreshEvent){
            refreshEvent.fire();
        }*/
       location.reload();  
       
    }
})
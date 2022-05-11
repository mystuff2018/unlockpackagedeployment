({    
	searchByKeyword : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");  
        component.set("v.showSearchButton", 'false' ); 
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        helper.searchHelper(component,event,getInputkeyWord);
        component.set("v.showViewAll", 'true' ); 
        component.set("v.callType", 'search' ); //console.log(component.get("v.PaginationList"));
    },
    
    keyPressController : function(component, event, helper) {
        //$A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");  
        if(getInputkeyWord.length > 1){
            component.set("v.showSearchButton", 'true' ); 
            component.set("v.searchText", '"'+getInputkeyWord+'"' + ' in Products' );
        }else{
            component.set("v.showSearchButton", 'false' );  
        }    
        },
    showSelected :function(component,event,helper){
        component.set("v.showViewAll", 'true' ); 
        component.set("v.callType", 'select' );
        var recordsFiltered = [];      
        //filter selected records
        recordsFiltered.push(component.get("v.listOfAllProducts").filter(function(o) {
            return o.isChecked === true;                   
        }));
        var recordsFiltered1 = []; 
        //filter selected records
        recordsFiltered1.push(component.get("v.listOfSearchRecords").filter(function(o) {
            return o.isChecked === true;                    
        }));//console.log(recordsFiltered[0]);console.log(recordsFiltered1[0]);
        //merge search + main array of selected records
        recordsFiltered = recordsFiltered[0].concat(recordsFiltered1[0]);    
        //remove duplicate entries
        var a = recordsFiltered;
        for(var i=0; i<a.length; ++i) {
            for(var j=i+1; j<a.length; ++j) {
                if(a[i].ObjProduct2.Id === a[j].ObjProduct2.Id)
                    a.splice(j--, 1);
            }
        }
        recordsFiltered=a;//console.log(recordsFiltered);
        component.set("v.listOfSelectedRecords", recordsFiltered);
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = recordsFiltered;
        var totalLength = totalRecordsList.length ;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);                    
        var PaginationLst = [];
        for(var i=0; i < pageSize; i++){
            if(recordsFiltered.length > i){
                PaginationLst.push(recordsFiltered[i]);    
            } 
        }
        component.set('v.PaginationList', PaginationLst);
        //  component.set("v.selectedCount" , 0);                    
        component.set("v.totalPagesCount", Math.ceil(totalLength/pageSize));        
        
    },
    clear :function(component,event,helper){
        //console.log(component.get("v.PaginationList"));
        component.set("v.SearchKeyWord",null);
        component.set("v.showSearchButton", 'false' ); 
        //$A.util.addClass(component.find("mySpinner"), "slds-show");    
        helper.doInitHelper(component, event);  
        component.set("v.showViewAll", 'false' );     
        component.set("v.callType", 'init' );
        },
    
    CancelProducts : function(component, event, helper) {
        helper.handlecancel(component, event, helper);        
    },
    handleComponentEvent : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedObjectRecordsEvent = event.getParam("recordByEvent");console.log('selectedObjectRecordsEvent',JSON.stringify(selectedObjectRecordsEvent));
        listSelectedItems.push(selectedObjectRecordsEvent);console.log('listSelectedItems1',JSON.stringify(listSelectedItems));
        component.set("v.lstSelectedRecords", listSelectedItems); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    doInit: function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        // -- Stroy 9911968 -- start
        if (value == null){
            var str = window.location.href;
            console.log(str);
            var dealId = component.get("v.recordId");
            console.log('dealId: ',dealId);
            
            if(str.includes("relatedlist")){
                var s3 = str.substring(
                    str.lastIndexOf("/a02")+1);
                var remove_after= s3.indexOf('/');
                var result =  s3.substring(0, remove_after);
                console.log('result:  ',result);
                component.set("v.parentRecordId", result);
            }else{
                var s1 = str.substring(
                    str.lastIndexOf("/a02")+1);
                var s2 = s1.slice(0,18);
                component.set("v.parentRecordId", s2);
            }
    } // -- Story 9911968 -- End
        else{
            var context = JSON.parse(window.atob(value));
            component.set("v.context", context);
            component.set("v.parentRecordId", context.attributes.recordId);
        }
        helper.doInitHelper(component, event);
    },
    
    navigation: function(component, event, helper) {
        var sObjectList;
        if(component.get("v.callType") == 'init'){
            sObjectList = component.get("v.listOfAllProducts");  
        } else if(component.get("v.callType") == 'search'){
            sObjectList = component.get("v.listOfSearchRecords");  
        } else if(component.get("v.callType") == 'select'){
            sObjectList = component.get("v.listOfSelectedRecords");  
        } //console.log(component.get("v.callType"));
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
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");//console.log(event.getSource().get("v.text"));
        var getSelectedNumber = component.get("v.selectedCount");
        var selectedObjectRecordsEvent = {};
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var mainList = component.get("v.listOfAllProducts"); 
        var searchList = component.get("v.listOfSearchRecords"); 
        var selectList = component.get("v.listOfSelectedRecords"); 
        var Id = event.getSource().get("v.text");
        var name = event.getSource().get("v.name");//console.log(name);
        selectedObjectRecordsEvent['Id'] = Id;//console.log('selectedObjectRecordsEvent',JSON.stringify(selectedObjectRecordsEvent));
        selectedObjectRecordsEvent['Name'] = name;        
        if (selectedRec == true) {
            getSelectedNumber++;
            //add to selected list
            listSelectedItems.push(selectedObjectRecordsEvent);//console.log('listSelectedItems1',JSON.stringify(listSelectedItems));
            component.set("v.lstSelectedRecords", listSelectedItems);             
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
            var i = 0;
            //remove from selected list
            listSelectedItems.forEach(function(e) {               
                if(e.Id == Id){
                    console.log(i);listSelectedItems.splice(i,1);                    
                }i++;
            });
            //uncheck in main list 
            mainList.forEach(function(e) {               
                if(e.ObjProduct2.Id == Id){ 
                    e.isChecked = false;               
                }i++;
            });
            //uncheck in search list
            searchList.forEach(function(e) {               
                if(e.ObjProduct2.Id == Id){
                    e.isChecked = false;                    
                }i++;
            }); console.log(searchList);   
            //uncheck in select list
            /*  selectList.forEach(function(e) {               
               if(e.ObjProduct2.Id == Id){
                	e.isChecked = false;   console.log('selectList',e.isChecked);                 
                }i++;
            });  */     
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
       /* if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }*/
    },
    handleSaveDealProduct: function (component, event, helper) {
        var selectedlist = component.get("v.lstSelectedRecords");
        if(typeof(selectedlist) != "undefined" && selectedlist.length > 0){
            helper.handleSaveDealProduct(component, event, helper); 
        }else{
            helper.showToast({
                "title": "Error!!",
                "type": "error",
                "message": "Please select Product first to save it."
            }); 
        }
        
        
    },
    EditDealProductData : function (component, event, helper) {
        
        //var listSelectedItems =  component.get("v.lstSelectedRecords");
        //method name from child
        //var ParRecordId = component.get("v.parentRecordId")
        //component.set("v.DealProductList", listSelectedItems);
        //component.set("v.ParentDealRegId",ParRecordId);
        
        //aura method
        //var EditDealProductData = component.find(EditDealProductData);
        // EditDealProductData.DisplayEditRecords(component.get("v.lstSelectedRecords"),component.get("v.parentRecordId"));
        console.log('evt'+evt);
        var evt = $A.get("e.force:navigateToComponent");
        console.log('evt'+evt);
        evt.setParams({
            componentDef: "c:FBEFirstEditDealProductData",
            componentAttributes :{
                context: component.get("v.context"),
                //lstSelectedRecords: component.get("sr.Name"),
                ParentDealRegId: component.get("v.parentRecordId")
            }
        });
        
        evt.fire();
    }
})
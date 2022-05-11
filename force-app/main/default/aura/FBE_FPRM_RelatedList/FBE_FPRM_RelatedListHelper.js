({
    getRecords : function(component, event, helper) {
        //Determine if the component is exposed in a community portal or Standard Salesforce
        var environment = component.get('v.environmentType');
        console.log("view All Records flag: "+component.get("v.viewAllRecordsFlag"));
        var pageTransferData = sessionStorage.getItem('pageTransfer');
        if (pageTransferData) {
            var recordIdLocal = JSON.parse(pageTransferData).recordId
            var viewAllFlag = JSON.parse(pageTransferData).viewAllRecords
            //console.log('State: '+pageTransferData+ ' Record Local: '+recordIdLocal+' View All Records Flag: '+viewAllFlag);
            component.set("v.viewAllRecordsFlag", viewAllFlag);
            sessionStorage.clear();
        }
        
        //Logic to Return Records based on Object
        var action = component.get("c.setContext")
        var noOfRecords = component.get("v.numberOfRecords")
        component.set('v.currentUserId', $A.get("$SObjectType.CurrentUser.Id"));
        
        var jsonRequest = JSON.stringify({recordId:component.get("v.recordId"),
                                          sobjectApiName:component.get("v.objectApiName"),
                                          objfields:component.get("v.fields"),
                                          numberOfRecords:noOfRecords + 1,
                                          conditionFieldApiName:component.get("v.conditionFieldApiName"),
                                          prmVisibilityFlag:component.get("v.prmUserVisibility"),
                                          currentUserId:component.get("v.currentUserId"),
                                          viewAllRecordsFlag:component.get("v.viewAllRecordsFlag"),
                                          rowLimit:component.get("v.initialRows"),
                                          affiliationsListFlag:component.get("v.affiliationsList")
                                         });
        
        action.setParams({jsonData : jsonRequest});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var jsonResponse = JSON.parse(response.getReturnValue())
                var records = jsonResponse.records
                
                //Below code iterates over records and transforms to flatten the structure
                if(records.length > noOfRecords){
                    //records.pop()
                    component.set('v.noOfRecordsHeader', noOfRecords + "+")
                    //console.log('Records Pop: '+records.pop())
                    //console.log('Records length: '+records.length)
                }
                else{ 
                    component.set('v.noOfRecordsHeader', Math.min(noOfRecords,records.length))
                }
                
                var viewAllFlag = component.get('v.viewAllRecordsFlag')
                if(!viewAllFlag){
                    component.set('v.noOfRecordsHeader', records.length)
                }
                
                //Flatten the record structure
                records.forEach(eaRecord =>{
                    //console.log("each record: "+eaRecord); 
                    if(environment === 'Community'){
                    var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                    eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                    //console.log('Ea Record Link for Community: '+ eaRecord.LinkName);
                    
                }
                                else if (environment === 'Standard') {
                    eaRecord.LinkName = '/'+eaRecord.Id;
                    //console.log('Ea Record Link for Standard: '+ eaRecord.LinkName);
                }
                
                for (const col in eaRecord) {
                    //console.log("each record >> col "+col);
                    const curCol = eaRecord[col];
                    //console.log("each record >> col >> curCol "+curCol);
                    if (typeof curCol === 'object') {
                        const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                        //console.log("curCol >> newVal: "+newVal);
                        helper.flattenStructure(helper,eaRecord, col + '_', curCol);
                        if (newVal !== null) {
                            if(environment === 'Community'){
                                var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                                eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                                var objName = (jsonResponse.recordSObjectName).toLowerCase();
                                eaRecord[col+ '_LinkName'] = '/'+portalName+'/s/'+objName+''+newVal;
                                //console.log('Ea Record Link for Community: '+ eaRecord.LinkName);
                                
                            }
                            else if (environment === 'Standard') {
                                eaRecord[col+ '_LinkName'] = newVal;
                            }
                            
                            //console.log("eaRecord after flatten struture: "+JSON.stringify(eaRecord));
                        }
                    }
                }
                
            });
            
            //Flatten TotalRows so that in can be searchable
            var totalRecords = jsonResponse.totalRows
                            totalRecords.forEach(eaRecord =>{
                    if(environment === 'Community'){
                    var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                    eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                    
                }
                                else if (environment === 'Standard') {
                    eaRecord.LinkName = '/'+eaRecord.Id;
                }
                
                for (const col in eaRecord) {
                    const curCol = eaRecord[col];
                    if (typeof curCol === 'object') {
                        const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                        helper.flattenStructure(helper,eaRecord, col + '_', curCol);
                        
                        if (newVal !== null) {
                            if(environment === 'Community'){
                                var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                                eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                                var objName = (jsonResponse.recordSObjectName).toLowerCase();
                                eaRecord[col+ '_LinkName'] = '/'+portalName+'/s/'+objName+''+newVal;
                                
                            }
                            else if (environment === 'Standard') {
                                eaRecord[col+ '_LinkName'] = newVal;
                            }
                        }
                    }
                }
                
            });
            
        	var recordName = jsonResponse.recordName
            recordName.forEach(eaRecord =>{
                component.set("v.recordName", eaRecord.Name)
            })
            
                component.set("v.records", totalRecords)
                component.set("v.filteredRecords", records)
                component.set("v.initialRecords", records)
                //component.set("v.icon", jsonResponse.iconName)
                component.set("v.objectName", jsonResponse.sobjectName)
                component.set("v.objectNamePlural", jsonResponse.sobjectNamePlural)
                component.set("v.parentRelationshipApiName", jsonResponse.parentRelationshipApiName)
                component.set("v.canCreateRecords", jsonResponse.canCreateRecords)
                component.set("v.totalRows", jsonResponse.totalRows.length)
                component.set("v.recordSObjectName", jsonResponse.recordSObjectName)
        	
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        /*component.set("v.columns", [
                {label:"Name", fieldName:"Name", type:"text"},
                {label:"Email", fieldName:"Email", type:"Email"},
                {label:"Phone", fieldName:"Phone", type:"phone"}
            ]); */
        
        $A.enqueueAction(action);        
    },
 
     flattenStructure : function (helper,topObject, prefix, toBeFlattened) {
        for (const prop in toBeFlattened) {
            //console.log("to be flattened: "+toBeFlattened)
            const curVal = toBeFlattened[prop];
            //console.log("Current Val: "+curVal);
            if (typeof curVal === 'object') {
                helper.flattenStructure(helper, topObject, prefix + prop + '_', curVal);
            } else {
                topObject[prefix + prop] = curVal;
            }
        }
    },
    
    initColumnsAndActions: function (component, event, helper) {
        /*var defineCustomActions = component.get('v.defineCustomActions')
       
       var customActions = component.get('v.customActions')
        if( !customActions.length && defineCustomActions){
            customActions = [
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
	        ]         
        }
        */
        
        var columns = component.get('v.columns')        
        var columnsWithActions = []
        columnsWithActions.push(...columns)
        //columnsWithActions.push({ type: 'action', typeAttributes: { rowActions: customActions } })
        component.set('v.recordColumnsWithActions',  columnsWithActions)
    },
        
        searchRecordsBySearchPhrase : function (component) {
            var fieldList = component.get("v.fields");
            var searchPhrase = component.get("v.searchPhrase");
            let filteredData;
            
            if (!$A.util.isEmpty(searchPhrase)) {
                component.set("v.enableInfiniteLoading",false);
                let allData = component.get("v.records");
                
                //Added search capability on Email field - For Contacts Related List
                if(fieldList.includes("Email")){
                    filteredData = allData.filter(record => (record.Name).toLowerCase().includes(searchPhrase.toLowerCase()) ||
                                                 (record.Email).toLowerCase().includes(searchPhrase.toLowerCase()));
                }
                else{
                    filteredData = allData.filter(record => (record.Name).toLowerCase().includes(searchPhrase.toLowerCase()))
                }
                
                component.set("v.filteredRecords", filteredData);
                component.set('v.noOfRecordsHeader', filteredData.length)
                //Update number of records here.
                
            }
            if ($A.util.isEmpty(searchPhrase)){
                component.set("v.enableInfiniteLoading",true);
                
                let allData = component.get("v.initialRecords");
                component.set("v.filteredRecords", allData);
                component.set('v.noOfRecordsHeader', allData.length)
                component.set("v.currentCount", allData.length)
            }
        },
            loadData: function(component, event, helper){
                return new Promise($A.getCallback(function(resolve){
                    var limit = component.get("v.initialRows");
                    var offset = component.get("v.currentCount");
                    var totalRows = component.get("v.totalRows");
                    if(limit + offset > totalRows){
                        limit = totalRows - offset;
                    }
                    
                    var action = component.get("c.setContext");
                    var jsonRequest = JSON.stringify({recordId:component.get("v.recordId"),
                                                      sobjectApiName:component.get("v.objectApiName"),
                                                      objfields:component.get("v.fields"),
                                                      conditionFieldApiName:component.get("v.conditionFieldApiName"),
                                                      prmVisibilityFlag:component.get("v.prmUserVisibility"),
                                                      currentUserId:component.get("v.currentUserId"),
                                                      viewAllRecordsFlag:component.get("v.viewAllRecordsFlag"),
                                                      rowsOffset:offset,
                                                      rowLimit:limit,
                                                      numberOfRecords:component.get("v.numberOfRecords") + 1,
                                                      affiliationsListFlag:component.get("v.affiliationsList")
                                                     });
                    action.setParams({jsonData : jsonRequest});
                    action.setCallback(this, function(response){
                        var environment = component.get('v.environmentType');
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            var jsonResponse = JSON.parse(response.getReturnValue())
                            var records = jsonResponse.records
                            records.forEach(eaRecord =>{
                                //console.log("each record: "+eaRecord); 
                                if(environment === 'Community'){
                                var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                                eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                                //console.log('Ea Record Link for Community: '+ eaRecord.LinkName);
                                
                            }
                                            else if (environment === 'Standard') {
                                eaRecord.LinkName = '/'+eaRecord.Id;
                                //console.log('Ea Record Link for Standard: '+ eaRecord.LinkName);
                            }
                            
                            for (const col in eaRecord) {
                                //console.log("each record >> col "+col);
                                const curCol = eaRecord[col];
                                //console.log("each record >> col >> curCol "+curCol);
                                if (typeof curCol === 'object') {
                                    const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                                    //console.log("curCol >> newVal: "+newVal);
                                    helper.flattenStructure(helper,eaRecord, col + '_', curCol);
                                    if (newVal !== null) {
                                        if(environment === 'Community'){
                                            var portalName = $A.get("$Label.c.FBE_FPRM_Portal_Name");
                                            eaRecord.LinkName = '/'+portalName+'/s/detail/'+eaRecord.Id;
                                            var objName = (jsonResponse.recordSObjectName).toLowerCase();
                                            eaRecord[col+ '_LinkName'] = '/'+portalName+'/s/'+objName+''+newVal;
                                            //eaRecord[col+ '_LinkName'] = '/'+portalName+'/s/detail'+newVal;
                                            //console.log('Ea Record Link for Community: '+ eaRecord.LinkName);
                                            
                                        }
                                        else if (environment === 'Standard') {
                                            eaRecord[col+ '_LinkName'] = newVal;
                                        }
                                        //console.log("eaRecord after flatten struture: "+eaRecord);
                                    }
                                }
                            }
                            
                        }); //end for
                        resolve(records)
                        //component.set("v.records", records)
                        //console.log("Records under Load More: "+records);
                        //console.log("Existing value of component.records: "+component.get("v.records"));
                        //component.set("v.filteredRecords", records)
                        var currentCount = component.get("v.currentCount");
                        // set the current count with number of records loaded
                        currentCount += component.get("v.initialRows");
                        if(currentCount > totalRows){
                            component.set("v.noOfRecordsHeader", totalRows);
                        }
                        else{
                            component.set("v.noOfRecordsHeader", currentCount);
                        }
                        component.set("v.currentCount", currentCount);
                        
                        event.getSource().set("v.isLoading", false);
                        
                    } //End If
                                       else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                    }); //End setCallback
                    $A.enqueueAction(action);
                })); //End Promise
            }
})
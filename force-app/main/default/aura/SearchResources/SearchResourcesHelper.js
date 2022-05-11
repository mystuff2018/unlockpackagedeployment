({
    helperdoInit : function (component, event, helper, resetBoolean){
        component.set("v.isLowerLevelDetails", false);
        this.openFilterWindow(component, event, helper);
        var resetBooleanForRR = false;
        component.set("v.data4BooleanCheck",true);
        if(resetBoolean != null && resetBoolean != '' && resetBoolean != 'undefined' && resetBoolean){
            component.set("v.data4", null);
            component.set("v.data4BooleanCheck",true);
            component.set("v.total", 0);
            component.set("v.pages", 0);
            component.set("v.page", 0);
            //resetBooleanForRR = true;
        }
        var pageReference = component.get("v.pageReference");
        var actions = [
            {
                label: 'Assign',
                name: 'assign',
                
            }/*,
            {
                label: 'Hold',
                name: 'hold',
                
            },
            {
                label: 'Release',
                name: 'release',
                
            }*/,
            {
                label: 'View In Planner',
                name: 'view_in_planners'
            },
            {
                label: 'View In Map',
                name: 'view_in_map'
            }/*,
            {
                label: 'Send Email',
                name: 'send_email'
            },
            {
                label: 'Send Email',
                name: 'send_email'
            },
            {
                label: 'Past Jobs',
                name: 'past_jobs'
            },
            {
                label: 'C&Qs',
                name: 'c_q'
            }*/
        ]
        var lookupFields;
        var action1 = component.get("c.DisplayColumns1");
        action1.setParams({
            objApi : 'Contact',
            fieldSetName : 'Search_Resource_Screen'
        }); 
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                lookupFields = result.lookUpFieldsWithvalue;
                var col = result.columns;
                col.unshift({
                    type: 'action',
                    typeAttributes: {
                        rowActions: actions
                    }
                });
                component.set("v.fieldNameWithRelationship",result.lookUpFieldsWithvalue);
                component.set("v.columns4", result.columns);
            }else if (state === 'ERROR'){
            }
        });
        $A.enqueueAction(action1);
        var action = component.get('c.getSearchDetails');
        action.setParams({
            recordId: pageReference.state.c__ResourceRequestID
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isRenderRDC", true);
                component.set("v.searchDetailObject", result);
                component.set("v.isLocationAvailble",result.isLocationAvailble); 
                component.set("v.defultDate", result.startDate);
                var defaultCost = parseInt(component.get("v.searchDetailObject.defaultCostRateValue"));
                component.set("v.searchDetailObject.defaultCostRateValue", defaultCost);
                if(component.get("v.searchDetailObject.openFromResourceReqScreen")){
                    component.set("v.searchDetailObject.role", component.get("v.searchDetailObject.selectedResourceRequest.pse__Resource_Role__c"));
                    component.set("v.searchDetailObject.startDate", component.get("v.searchDetailObject.selectedResourceRequest.pse__Start_Date__c"));
                    component.set("v.searchDetailObject.endDate", component.get("v.searchDetailObject.selectedResourceRequest.pse__End_Date__c"));
                    component.set("v.searchDetailObject.name", component.get("v.searchDetailObject.selectedResourceRequest.Name"));
                    component.set("v.searchDetailObject.resourceRequestName", component.get("v.searchDetailObject.selectedResourceRequest.pse__Resource__r.Name"));
                    if(component.get("v.searchDetailObject.selectedResourceRequest.pse__Practice__c") != null && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Practice__c") != '' && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Practice__c") != 'undefined'){
                        component.set("v.searchDetailObject.practiceFilter",'Equals');
                        component.set("v.searchDetailObject.practiceValue", component.get("v.searchDetailObject.selectedResourceRequest.pse__Practice__r.Name"));
                    }
                    if(component.get("v.searchDetailObject.selectedResourceRequest.pse__Region__c") != null && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Region__c") != '' && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Region__c") != 'undefined'){
                        component.set("v.searchDetailObject.regionFilter",'Equals');
                        component.set("v.searchDetailObject.regionValue", component.get("v.searchDetailObject.selectedResourceRequest.pse__Region__r.Name"));
                    }
                    if(component.get("v.searchDetailObject.selectedResourceRequest.pse__Group__c") != null && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Group__c") != '' && 
                       component.get("v.searchDetailObject.selectedResourceRequest.pse__Group__c") != 'undefined'){
                        component.set("v.searchDetailObject.groupFilter",'Equals');
                        component.set("v.searchDetailObject.groupValue", component.get("v.searchDetailObject.selectedResourceRequest.pse__Group__r.Name"));
                    }
                }           
                if(pageReference.state.c__ResourceRequestID != null && 
                   pageReference.state.c__ResourceRequestID != '' && 
                   pageReference.state.c__ResourceRequestID != 'undefined'){
                    var page = component.get("v.page") || 1;
                    // get the select option (drop-down) values.   
                    var recordToDisply = component.find("recordSize").get("v.value");
                    this.getContacts(component, page, recordToDisply, event);
                }
                this.countSearchFilters(component, event, helper);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error('elseiferror>>>>',errors);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    countSearchFilters : function(component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject"); 
        
        //Count Start Based On Skills
        
        if(lstSearchDetail.lstSkill != null){
            var skillValue = 'Skills (' + lstSearchDetail.lstSkill.length + ')';
            component.set("v.accordionSkillValue",skillValue);
        }
        //Count End Based On Skills
        
        //Count Start Based On Certifications
        if(lstSearchDetail.lstCertification != null){
            var certificationValue = 'Certifications (' + lstSearchDetail.lstCertification.length + ')';
            component.set("v.accordionCertificationValue",certificationValue);
        }
        //Count End Based On Certifications
        
        //Count Start Based On Additional Filters
        var additionalFilterCount = 0;
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionValue != null && lstSearchDetail.regionValue != '' && lstSearchDetail.regionValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceValue != null && lstSearchDetail.practiceValue != '' && lstSearchDetail.practiceValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupValue != null && lstSearchDetail.groupValue != '' && lstSearchDetail.groupValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateValue != null && lstSearchDetail.defaultCostRateValue != '' && lstSearchDetail.defaultCostRateValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' && lstSearchDetail.scheduledUtilizationFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' &&  lstSearchDetail.scheduledUtilizationFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' && lstSearchDetail.scheduledUtilizationValue != null && lstSearchDetail.scheduledUtilizationValue != '' && lstSearchDetail.scheduledUtilizationValue != 'undefined'){
            additionalFilterCount++;
        }
        var additionalFilterValue = 'Additional Filters (' + additionalFilterCount + ')';
        component.set("v.accordionAdditionalFiltersValue",additionalFilterValue);
        //Count End Based On Additional Filters
        
        //Count Start Based On Attributes
        var attributeCount = 0;
        if(lstSearchDetail.workedWithCustomer != null && lstSearchDetail.workedWithCustomer){
            attributeCount++;
        }
        if(lstSearchDetail.availability != null && lstSearchDetail.availability){
            attributeCount++;
        }
        if(lstSearchDetail.internal != null && lstSearchDetail.internal){
            attributeCount++;
        }
        if(lstSearchDetail.distance != null && lstSearchDetail.distance){
            attributeCount++;
        }
        if(lstSearchDetail.rdcFilter != null && lstSearchDetail.rdcFilter){
            attributeCount++;
        }
        var attributeValue = 'Attributes (' + attributeCount + ')';
        component.set("v.accordionAttributeValue",attributeValue);
        //Count End Based On Attributes
        
        //Code Start Based On SearchResource
        var searchResourceCount = 0;
        if(lstSearchDetail.startDate != null && lstSearchDetail.startDate != '' && lstSearchDetail.startDate != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.endDate != null && lstSearchDetail.endDate != '' && lstSearchDetail.endDate != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.name != null && lstSearchDetail.name != '' && lstSearchDetail.name != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.resourceRequestName != null && lstSearchDetail.resourceRequestName != '' && lstSearchDetail.resourceRequestName != 'undefined'){
            searchResourceCount++;
        }
        var searchResourceValue = 'Search Resource (' + searchResourceCount + ')';
        component.set("v.accordionSearchResourceValue",searchResourceValue);
        //Code End Based On SearchResource
        
        //Code Start Based On Role
        var roleCount = 0;
        if(lstSearchDetail.role != null && lstSearchDetail.role != '' && lstSearchDetail.role != 'undefined' && lstSearchDetail.roleList.includes(lstSearchDetail.role)){
            roleCount++;
        }
        var roleValue = 'Roles (' + roleCount + ')';
        component.set("v.accordionRoleValue",roleValue);
        //Code End Based On Role
        
        //Code Start Based On ResourceRequestDetails
        var resourceRequestDetailsCount = 0;
        if(lstSearchDetail.selectedResourceRequest != null){
            if(lstSearchDetail.selectedResourceRequest.Name != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Status__c != null && lstSearchDetail.selectedResourceRequest.pse__Status__c != '' && lstSearchDetail.selectedResourceRequest.pse__Status__c != 'undefined'){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__SOW_Hours__c != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Requested_Bill_Rate__c != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Project__c != null && lstSearchDetail.selectedResourceRequest.pse__Project__r.Name != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Opportunity__c != null && lstSearchDetail.selectedResourceRequest.pse__Opportunity__r.Name != null){
                resourceRequestDetailsCount++;
            }
        }
        var resourceRequestDetailsValue = 'Resource Request Details (' + resourceRequestDetailsCount + ')';
        component.set("v.accordionResourceRequestDetailsValue",resourceRequestDetailsValue);
        //Code Ends Based On ResourceRequestDetails
        
        //Code Start Based On Address Details
        var addressDetailsCount = 0;
        if(lstSearchDetail.street != null && lstSearchDetail.street != '' && lstSearchDetail.street != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.city != null && lstSearchDetail.city != '' && lstSearchDetail.city != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.state != null && lstSearchDetail.state != '' && lstSearchDetail.state != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.country != null && lstSearchDetail.country != '' && lstSearchDetail.country != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.zipCode != null && lstSearchDetail.zipCode != '' && lstSearchDetail.zipCode != 'undefined'){
            addressDetailsCount++;
        }
        var addressDetailsValue = 'Address Details (' + addressDetailsCount + ')';
        component.set("v.accordionAddressDetailsValue",addressDetailsValue);
        //Code Ends Based On Address Details
    },
    additionalFilterCountCalculation: function (component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var additionalFilterCount = 0;
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionFilter != 'undefined' && lstSearchDetail.regionValue != null && lstSearchDetail.regionValue != '' && lstSearchDetail.regionValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceFilter != 'undefined' && lstSearchDetail.practiceValue != null && lstSearchDetail.practiceValue != '' && lstSearchDetail.practiceValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupFilter != 'undefined' && lstSearchDetail.groupValue != null && lstSearchDetail.groupValue != '' && lstSearchDetail.groupValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.defaultCostRateFilter != null && lstSearchDetail.defaultCostRateFilter != '' && lstSearchDetail.defaultCostRateFilter != 'undefined' && lstSearchDetail.defaultCostRateValue != null && lstSearchDetail.defaultCostRateValue != '' && lstSearchDetail.defaultCostRateValue != 'undefined'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' && lstSearchDetail.scheduledUtilizationFilter == 'Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' &&  lstSearchDetail.scheduledUtilizationFilter == 'Not Is Null'){
            additionalFilterCount++;
        }
        if(lstSearchDetail.scheduledUtilizationFilter != null && lstSearchDetail.scheduledUtilizationFilter != '' && lstSearchDetail.scheduledUtilizationFilter != 'undefined' && lstSearchDetail.scheduledUtilizationValue != null && lstSearchDetail.scheduledUtilizationValue != '' && lstSearchDetail.scheduledUtilizationValue != 'undefined'){
            additionalFilterCount++;
        }
        var additionalFilterValue = 'Additional Filters (' + additionalFilterCount + ')';
        component.set("v.accordionAdditionalFiltersValue",additionalFilterValue);
    },
    searchResourceCountCalculation: function (component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var searchResourceCount = 0;
        if(lstSearchDetail.startDate != null && lstSearchDetail.startDate != '' && lstSearchDetail.startDate != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.endDate != null && lstSearchDetail.endDate != '' && lstSearchDetail.endDate != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.name != null && lstSearchDetail.name != '' && lstSearchDetail.name != 'undefined'){
            searchResourceCount++;
        }
        if(lstSearchDetail.resourceRequestName != null && lstSearchDetail.resourceRequestName != '' && lstSearchDetail.resourceRequestName != 'undefined'){
            searchResourceCount++;
        }
        var searchResourceValue = 'Search Resource (' + searchResourceCount + ')';
        component.set("v.accordionSearchResourceValue",searchResourceValue);
    },
    roleCount: function(component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var roleCount = 0;
        if(lstSearchDetail.role != null && lstSearchDetail.role != '' && lstSearchDetail.role != 'undefined' && lstSearchDetail.roleList.includes(lstSearchDetail.role)){
            roleCount++;
        }
        var roleValue = 'Roles (' + roleCount + ')';
        component.set("v.accordionRoleValue",roleValue);
    },
    statusChange: function(component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var resourceRequestDetailsCount = 0;
        if(lstSearchDetail.selectedResourceRequest != null){
            if(lstSearchDetail.selectedResourceRequest.Name != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Status__c != null && lstSearchDetail.selectedResourceRequest.pse__Status__c != '' && lstSearchDetail.selectedResourceRequest.pse__Status__c != 'undefined'){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__SOW_Hours__c != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Requested_Bill_Rate__c != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Project__c != null && lstSearchDetail.selectedResourceRequest.pse__Project__r.Name != null){
                resourceRequestDetailsCount++;
            }
            if(lstSearchDetail.selectedResourceRequest.pse__Opportunity__c != null && lstSearchDetail.selectedResourceRequest.pse__Opportunity__r.Name != null){
                resourceRequestDetailsCount++;
            }
        }
        var resourceRequestDetailsValue = 'Resource Request Details (' + resourceRequestDetailsCount + ')';
        component.set("v.accordionResourceRequestDetailsValue",resourceRequestDetailsValue);
    },
    addressDetailsChangeCount : function(component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var addressDetailsCount = 0;
        if(lstSearchDetail.street != null && lstSearchDetail.street != '' && lstSearchDetail.street != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.city != null && lstSearchDetail.city != '' && lstSearchDetail.city != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.state != null && lstSearchDetail.state != '' && lstSearchDetail.state != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.country != null && lstSearchDetail.country != '' && lstSearchDetail.country != 'undefined'){
            addressDetailsCount++;
        }
        if(lstSearchDetail.zipCode != null && lstSearchDetail.zipCode != '' && lstSearchDetail.zipCode != 'undefined'){
            addressDetailsCount++;
        }
        var addressDetailsValue = 'Address Details (' + addressDetailsCount + ')';
        component.set("v.accordionAddressDetailsValue",addressDetailsValue);
        component.set("v.searchDetailObject.isLocationChanged",true);
    },
    getContacts: function (component, page, recordToDisply, event) {
        if(component.get("v.searchOutResourcesPagePagesValue")){
            page = 1;
        }
        var action = component.get("c.getFilteredContacts");
        action.setParams({
            "searchDetailList": component.get("v.searchDetailObject"),
            "pageNumber": page,
            "recordToDisply": recordToDisply
        });
        action.setCallback(this, function (a) {
            var result = a.getReturnValue();
            if (result != undefined) {
                component.set("v.searchOutResourcesPagePagesValue", false);
                var  lookupFields = component.get("v.fieldNameWithRelationship");
                var resultListContacts = result.contacts;
                resultListContacts.forEach(function(row){
                    for(var key in lookupFields){
                        if(row[key] != null && row[key] != 'undefined'){
                            if(key == 'Name'){
                                var recordLink = 'link'+key;
                                row[recordLink] = '/'+row.Id;
                            }else{
                                var relationshipName = lookupFields[key];
                                if(key.includes("__c")){
                                    var recordLink = 'link'+key;
                                    row[recordLink] = '/'+row[key];
                                }else{
                                    var recordLink = 'link'+key;
                                    row[recordLink] = '/'+row[relationshipName].Id;
                                }
                                row[key] = row[relationshipName].Name;
                            }
                        }
                    } 
                });
                component.set("v.isResReqTable", true);
                component.set("v.data4", resultListContacts);
                /*//Change Start For Lower Level Details
                component.set("v.dataLowerLevelDetails", resultListContacts);
                var actions = [
                    {
                        label: 'Send Email',
                        name: 'send_email'
                    },
                    {
                        label: 'Past Jobs',
                        name: 'past_jobs'
                    },
                    {
                        label: 'C&Qs',
                        name: 'c_q'
                    }
                ]
                component.set('v.columnsLowerLevelDetails', [
                    { type: 'action', typeAttributes: { rowActions: actions } },
                    { label: 'Name', fieldName: 'Name', type: 'text' },
                    { label: 'Cost Rate', fieldName: 'pse__Default_Cost_Rate__c', type: 'text' },
                ]);
                    //Change Ends For Lower Level Details*/
                component.set("v.page", result.page);
                if(resultListContacts.length == 0){
                    component.set("v.page", 0);
                    component.set("v.data4BooleanCheck",true);
                }
                if(resultListContacts.length > 0){
                    component.set("v.data4BooleanCheck",false);
                }
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisply));
                /*if (Math.ceil(result.total / recordToDisply) == 0) {
                    component.set('v.displayDisabledNextButton', true);
                }*/
                component.set("v.resReqAvailability", result.resRequestAvailability);
                //Closing window after Applying Filter
                //this.closeFilterWindow(component, event,helper);
                this.showLowerLevelDetails(component, event, recordToDisply);
            }
             component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    calculateSchedulingPatternsHelper: function (component, event, totalHoursOnResReq){
        var keyForPattern = component.find('selectPattern').get('v.value');
        console.log('keyForPattern1:::',keyForPattern);
        if(keyForPattern == null || keyForPattern == '' || keyForPattern == 'undefined'){
            component.set("v.displayForWeeklyHours", false);
            component.set("v.startendDateBasisOfSchedulingPattern", false);
            component.set("v.customHoursSchedule", false);
        }
        console.log('keyForPattern2:::',keyForPattern);
        var StrategyBasedOnSchdulePatternMap = component.get("v.mapStrategyBasedOnSchdulePattern");
        component.set("v.keyPattern", keyForPattern);
        if(keyForPattern != null && keyForPattern != '' && keyForPattern != 'undefined'){
            component.set("v.disableAssignHoldButton",false);
        }
        else{
            component.set("v.disableAssignHoldButton",true);
        }
        console.log('keyForPattern3:::',keyForPattern);
        switch (keyForPattern) {
            case 'CalculateEndDateLevelSchedule':
                component.set("v.scheduleRecord", StrategyBasedOnSchdulePatternMap[keyForPattern]);
                var schRec = component.get("v.scheduleRecord");
                component.set("v.totalHours", totalHoursOnResReq);
                component.set("v.displayForWeeklyHours", true);
                component.set("v.startendDateBasisOfSchedulingPattern", true);
                component.set("v.customHoursSchedule", false);
                component.set("v.spinner", false);
                break;
            case 'CalculateEndDateIgnoreAvailability':
                component.set("v.scheduleRecord", StrategyBasedOnSchdulePatternMap[keyForPattern]);
                var schRec = component.get("v.scheduleRecord");
                component.set("v.totalHours", totalHoursOnResReq);
                component.set("v.displayForWeeklyHours", true);
                component.set("v.startendDateBasisOfSchedulingPattern", true);
                component.set("v.customHoursSchedule", false);
                component.set("v.spinner", false);
                break;
            case 'AdjustHoursPerDay':
                component.set("v.scheduleRecord", StrategyBasedOnSchdulePatternMap[keyForPattern]);
                var schRec = component.get("v.scheduleRecord");
                component.set("v.totalHours", totalHoursOnResReq);
                component.set("v.displayForWeeklyHours", true);
                component.set("v.startendDateBasisOfSchedulingPattern", true);
                component.set("v.customHoursSchedule", false);
                component.set("v.spinner", false);
                break;
            case 'PercentAllocation':
                component.set("v.assignHold", false);
                component.set("v.ispercentAllocation", true);
                var percentageAlloationRow = component.get("v.percentageAlloationRow");
                var ignoreHoliday = component.get("v.ignoreHoliday");
                var action = component.get('c.getPercentAllocationRows');
                var resReqForAssignHold = component.get("v.searchDetailObject.selectedResourceRequest");
                console.log('resReqForAssignHold::::',resReqForAssignHold);
                action.setParams({
                    resReq: resReqForAssignHold,
                    resId: component.get("v.resId"),
                    lstAllocationRow: percentageAlloationRow,
                    ignoreHoliday: ignoreHoliday,
                    indexForDeletionOfRow:component.get("v.indexDeletion")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state::::',state);
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.percentageAlloationRow", result);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.error(errors);
                    }
                    component.set("v.spinner", false);
                });
                $A.enqueueAction(action);
                break;
            case 'Custom':
                component.set("v.scheduleRecord", StrategyBasedOnSchdulePatternMap[keyForPattern]);
                this.calculateCustomSchedulePatternTotalHoursHelper(component, event);
                component.set("v.displayForWeeklyHours", true);
                component.set("v.startendDateBasisOfSchedulingPattern", true);
                component.set("v.customHoursSchedule", true);
                component.set("v.spinner", false);
                break;
            case 'ZeroHourSchedule':
                component.set("v.scheduleRecord", StrategyBasedOnSchdulePatternMap[keyForPattern]);
                var schRec = component.get("v.scheduleRecord");
                var totalHrs = schRec.pse__Monday_Hours__c + schRec.pse__Tuesday_Hours__c +
                    schRec.pse__Wednesday_Hours__c + schRec.pse__Thursday_Hours__c +
                    schRec.pse__Friday_Hours__c + schRec.pse__Saturday_Hours__c +
                    schRec.pse__Sunday_Hours__c;
                component.set("v.totalHours", totalHrs);
                component.set("v.displayForWeeklyHours", true);
                component.set("v.startendDateBasisOfSchedulingPattern", true);
                component.set("v.customHoursSchedule", false);
                component.set("v.spinner", false);
                break;
           default:
                component.set("v.spinner", false);
        }
       
    },
    assignHoldSchedulePatternHelper: function (component, event, helper) {
        var listResReq = component.get("v.searchDetailObject.selectedResourceRequest");
        var resReqForAssignHold;
        if (listResReq != null && listResReq != undefined) {
            resReqForAssignHold = component.get("v.searchDetailObject.selectedResourceRequest");
        }
        console.log('listResReq:::::',listResReq);
        var action = component.get('c.assignHoldSchedulePatterns');
        action.setParams({
            mapStrategyPattern: component.get("v.mapStrategyBasedOnSchdulePattern"),
            patternKey: component.get("v.keyPattern"),
            resouId: component.get("v.resId"),
            resReq: resReqForAssignHold,
            assignHoldValue: component.get("v.valueAssignHold")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state2:::::',state);
            if (state === "SUCCESS") {
                component.set("v.assignHold", false);
                component.set("v.assignValue", false);
                component.set("v.holdValue", false);
                component.set("v.displayForWeeklyHours", false);
                component.set("v.spinner", false);
                var result = JSON.parse(response.getReturnValue());
                if (result.responseCode == '900') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": result.responseMessage,
                        "type": "success"
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.searchDetailObject.selectedResourceRequest.Id"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else if (result.responseCode == '1000') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": result.responseMessage,
                        "type": "success"
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.searchDetailObject.selectedResourceRequest.Id"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else if (result.responseCode == '100') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": result.responseMessage,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.spinner", false);
            }
            
        });
        $A.enqueueAction(action);
    },
    calculateCustomSchedulePatternTotalHoursHelper: function (component, event) {
        component.set("v.totalHours", 0);
        var schRec = component.get("v.scheduleRecord");
        var totalHrs = parseInt(schRec.pse__Monday_Hours__c) + parseInt(schRec.pse__Tuesday_Hours__c) +
            parseInt(schRec.pse__Wednesday_Hours__c) + parseInt(schRec.pse__Thursday_Hours__c) +
            parseInt(schRec.pse__Friday_Hours__c) + parseInt(schRec.pse__Saturday_Hours__c) +
            parseInt(schRec.pse__Sunday_Hours__c);
        component.set("v.totalHours", totalHrs);
        component.set("v.spinner", false);
    },
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    handleSort: function(component, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var dataForContacts = component.get('v.data4');
        var cloneData = dataForContacts.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        component.set('v.data4', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
    },
    submitForPDMApprovalHelper : function(component, event, helper){
        var action = component.get('c.submitForApprovalPDM');
        action.setParams({
            lstSearchDetail : component.get("v.searchDetailObject"),
            resRequ: component.get("v.searchDetailObject.selectedResourceRequest")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == 'status is Send For PDM Approval'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Mail Sent Succesfully",
                        "type" : "success"
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Resource Request status is not Approval Pending",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    saveFilterHelper : function(component, event, helper){
        var action = component.get('c.saveFilterForScreen');
        action.setParams({
            lstSearchDetail: component.get("v.searchDetailObject")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Filter saved succesfully",
                    "type" : "success"
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    closeFilterWindow: function (cmp, event, helper) {
        $A.util.removeClass(cmp.find("filterPanel"), 'filterWindow');
        $A.util.removeClass(cmp.find("ResourceDataTable"), 'dataTable');
        $A.util.addClass(cmp.find("filterPanel"), 'filterWindowCollapse');
        $A.util.addClass(cmp.find("ResourceDataTable"), 'dataTableExpand');  
    },
    openFilterWindow : function (cmp, event, helper) {
        $A.util.removeClass(cmp.find("filterPanel"), 'filterWindowCollapse');
        $A.util.removeClass(cmp.find("ResourceDataTable"), 'dataTableExpand');
        $A.util.addClass(cmp.find("filterPanel"), 'filterWindow');
        $A.util.addClass(cmp.find("ResourceDataTable"), 'dataTable');
    },
    showLowerLevelDetails : function(component, event, helper){
        var actions = [
                    {
                        label: 'Past Jobs',
                        name: 'past_jobs'
                    },
                    {
                        label: 'C&Qs',
                        name: 'c_q'
                    }
                ]
        var lookupFields;
        var action1 = component.get("c.DisplayColumns1");
        action1.setParams({
            objApi : 'Contact',
            fieldSetName : 'Search_Resource_Screen_Lower'
        }); 
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                lookupFields = result.lookUpFieldsWithvalue;
                var col = result.columns;
                col.unshift({
                    type: 'action',
                    typeAttributes: {
                        rowActions: actions
                    }
                });
                //component.set("v.fieldNameWithRelationshipLowerLevelDetails",result.lookUpFieldsWithvalue);
                component.set("v.columnsLowerLevelDetails", result.columns);
                //var  lookupFields = component.get("v.fieldNameWithRelationship");
                var resultListContacts = component.get("v.data4");
                resultListContacts.forEach(function(row){
                    for(var key in lookupFields){
                        if(row[key] != null && row[key] != 'undefined'){
                            if(key == 'Name'){
                                var recordLink = 'link'+key;
                                row[recordLink] = '/'+row.Id;
                            }else{
                                var relationshipName = lookupFields[key];
                                if(key.includes("__c")){
                                    var recordLink = 'link'+key;
                                    row[recordLink] = '/'+row[key];
                                }else{
                                    var recordLink = 'link'+key;
                                    row[recordLink] = '/'+row[relationshipName].Id;
                                }
                                row[key] = row[relationshipName].Name;
                            }
                        }
                    } 
                });
                component.set("v.dataLowerLevelDetails", resultListContacts);
            }else if (state === 'ERROR'){
            }
        });
        $A.enqueueAction(action1);
    },
    showLowerLevelDetails2: function(component, event, helper){
        component.set("v.isLowerLevelDetails", true);
    }
})
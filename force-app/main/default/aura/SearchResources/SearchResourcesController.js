({
    doInit: function (component, event, helper) {
        component.set("v.spinner", true);
        helper.helperdoInit(component, event, helper);
    },
    handleClick: function (component, event, helper) {
        component.set("v.spinner", true);
        console.log('Skill certification seratch start::::');
        var skillcertification = event.getSource().getLocalId();
        if (skillcertification == 'Skill') {
            component.set("v.isSearchSkillsModalOpen", true);
            var action = component.get('c.getSkillsCertifications');
            action.setParams({
                recordType: skillcertification,
                lstSkllCert: component.get("v.searchDetailObject.lstSkill"),
                skillNameForFilter: component.get("v.searchedSkillName")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.data", result);
                    component.set("v.spinner", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.spinner", false);
                    console.error(errors);
                }
                console.log('Skill certification seratch end::::');
            });
            $A.enqueueAction(action);
            component.set('v.columns', [{
                label: 'Name',
                fieldName: 'Name',
                type: 'text'
            },
                                        {
                                            label: 'Type',
                                            fieldName: 'pse__Type__c',
                                            type: 'text'
                                        }
                                       ]);
            
        } else if (skillcertification == 'Certification') {
            component.set("v.isSearchCertificationssModalOpen", true);
            var action = component.get('c.getSkillsCertifications');
            action.setParams({
                recordType: skillcertification,
                lstSkllCert: component.get("v.searchDetailObject.lstCertification"),
                skillNameForFilter: component.get("v.searchedCertificationName")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.data2", result);
                    component.set("v.spinner", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                    component.set("v.spinner", false);
                }
                console.log('Skill certification seratch end::::');
            });
            $A.enqueueAction(action);
            component.set('v.columns2', [{
                label: 'Name',
                fieldName: 'Name',
                type: 'text'
            },
                                         {
                                             label: 'Type',
                                             fieldName: 'pse__Type__c',
                                             type: 'text'
                                         }
                                        ]);
        }
    },
    getSelectedSkills: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        let obj = []; 
        let obj2 = [];
        for (var i = 0; i < selectedRows.length; i++) {
            obj.push(false);
            obj2.push(selectedRows[i].Id);
        }
        component.set("v.skillSelectedRowsId", obj2);
    },
    getSelectedCertifications: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        let obj = [];
        let obj2 = [];
        for (var i = 0; i < selectedRows.length; i++) {
            obj.push(selectedRows[i].Id);
            obj2.push(false);
        }
        component.set("v.certificationSelectedRowsId", obj);
    },
    handleSkills: function (component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get('c.getSkills');
        action.setParams({
            skillIdList: component.get("v.skillSelectedRowsId"),
            lstSkll: component.get("v.searchDetailObject.lstSkill")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.searchDetailObject.lstSkill", result);
                if(result != null){
                var skillValue = 'Skills (' + result.length + ')';
                component.set("v.accordionSkillValue",skillValue);
                component.set("v.data", null);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
        component.set("v.isSearchSkillsModalOpen", false);
    },
    handleCertifications: function (component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get('c.getCertifications');
        action.setParams({
            certificationIdList: component.get("v.certificationSelectedRowsId"),
            lstCerti: component.get("v.searchDetailObject.lstCertification")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.searchDetailObject.lstCertification", result);
                component.set("v.isSearchCertifications", true);
                if(result != null){
                var certificationValue = 'Certifications (' + result.length + ')';
                component.set("v.accordionCertificationValue",certificationValue);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
        component.set("v.isSearchCertificationssModalOpen", false);
    },
    openResourceRequestModal: function (component, event, helper) {
        component.set("v.isSearchResourceRequests", true);
        component.set("v.resourceRequestName", '');
        component.set("v.isResReqTable", false);
    },
    searchResourceRequest: function (component, event, helper) {
        var searchedText = component.get("v.resourceRequestName");
        if (searchedText == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a Resource Request name."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.getResourceRequests');
            action.setParams({
                searchText: searchedText
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    for (var i = 0; i < result.length; i++) {
                        var row = result[i];
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.pse__Resource__r) {
                            row.pse__Resource__c = row.pse__Resource__r.Name;
                        }
                        if (row.pse__Opportunity__r) {
                            row.pse__Opportunity__c = row.pse__Opportunity__r.Name;
                        }
                    }
                    component.set("v.isResReqTable", true);
                    component.set("v.data3", result);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            });
            $A.enqueueAction(action);
            component.set('v.columns3', [{
                label: 'Resource Request Id',
                fieldName: 'Name',
                initialWidth: 150,
                type: 'text'
            },
                                         {
                                             label: 'Resource Role',
                                             fieldName: 'pse__Resource_Role__c',
                                             initialWidth: 150,
                                             type: 'text'
                                         },
                                         {
                                             label: 'Suggested Resource',
                                             fieldName: 'pse__Resource__c',
                                             initialWidth: 150,
                                             type: 'text'
                                         },
                                         {
                                             label: 'Opportunity',
                                             fieldName: 'pse__Opportunity__c',
                                             initialWidth: 150,
                                             type: 'text'
                                         },
                                         {
                                             label: 'Status',
                                             fieldName: 'pse__Status__c',
                                             initialWidth: 150,
                                             type: 'text'
                                         }
                                        ]);
        }
    },
    selectParticularRR: function (component, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        var action = component.get('c.getSkillsAndCertBasedOnResRequest');
        action.setParams({
            recordId: selectedRow[0].Id,
            lstSearchDetail: component.get("v.searchDetailObject")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.searchDetailObject", result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
        component.set("v.searchDetailObject.resourceRequestName", '');
        component.set("v.searchDetailObject.startDate", '');
        component.set("v.searchDetailObject.endDate", '');
        component.set("v.searchDetailObject.name", '');
        //component.set("v.resourceRequestBasedOnSearch", selectedRow[0]);
        if (selectedRow[0].Name != null && selectedRow[0].Name != '') {
            component.set("v.searchDetailObject.name", selectedRow[0].Name);
        }
        if (selectedRow[0].pse__Start_Date__c != null && selectedRow[0].pse__Start_Date__c != '') {
            component.set("v.searchDetailObject.startDate", selectedRow[0].pse__Start_Date__c);
        }
        if (selectedRow[0].pse__End_Date__c != null && selectedRow[0].pse__End_Date__c != '') {
            component.set("v.searchDetailObject.endDate", selectedRow[0].pse__End_Date__c);
        }
        if (selectedRow[0].pse__Resource__c != null && selectedRow[0].pse__Resource__c != '' && selectedRow[0].pse__Resource__c != 'undefined') {
            component.set("v.searchDetailObject.resourceRequestName", selectedRow[0].pse__Resource__r.Name);
        }
        if (selectedRow[0].pse__Resource_Role__c != null && selectedRow[0].pse__Resource_Role__c != '') {
            component.set("v.searchDetailObject.role", selectedRow[0].pse__Resource_Role__c);
        }
        if(selectedRow[0].pse__Practice__c != null && selectedRow[0].pse__Practice__c != '' && selectedRow[0].pse__Practice__c != 'undefined'){
            component.set("v.searchDetailObject.practiceFilter",'Equals');
            component.set("v.searchDetailObject.practiceValue", selectedRow[0].pse__Practice__r.Name);
        }
        if(selectedRow[0].pse__Region__c != null && selectedRow[0].pse__Region__c != '' && selectedRow[0].pse__Region__c != 'undefined'){
            component.set("v.searchDetailObject.regionFilter",'Equals');
            component.set("v.searchDetailObject.regionValue", selectedRow[0].pse__Region__r.Name);
        }
        if(selectedRow[0].pse__Group__c != null && selectedRow[0].pse__Group__c != '' && selectedRow[0].pse__Group__c != 'undefined'){
            component.set("v.searchDetailObject.groupFilter",'Equals');
            component.set("v.searchDetailObject.groupValue", selectedRow[0].pse__Group__r.Name);
        }
        component.set("v.isSearchResourceRequests", false);
    },
    closeModel: function (component, event, helper) {
        component.set("v.isSearchSkillsModalOpen", false);
        component.set("v.isSearchCertificationssModalOpen", false);
        component.set("v.isSearchResourceRequests", false);
        component.set("v.showfilterLogicSkills", false);
        component.set("v.showfilterLogicCertifications", false);
        component.set("v.assignHold", false);
        component.set("v.assignValue", false);
        component.set("v.holdValue", false);
        component.set("v.displayForWeeklyHours", false);
        component.set("v.mapOpenClose", false);
        component.set("v.isSearchPracticeModal", false);
        component.set("v.isSearchRegionModal", false);
        component.set("v.isSearchGroupModal", false);
        component.set("v.ispercentAllocation", false);
        component.set("v.percentageAlloationRow",null);
        component.set("v.isSendEmail", false);
        component.set("v.isPastJobs", false);
        component.set("v.isCQ", false);
    },
    getSkillExpValue: function (component, event, helper) {
        var objArray = component.get("v.searchDetailObject.lstSkill");
        var index = event.getSource().get('v.name');
        objArray[index].skillExp = event.getSource().get('v.value');
        component.set("v.searchDetailObject.lstSkill", objArray);
    },
    addDateRangePercentAllocation: function (component, event, helper){
        var indexDel = component.get("v.indexDeletion");
        indexDel += 1;
        component.set("v.indexDeletion",indexDel);
        var percentageAlloationRow = component.get("v.percentageAlloationRow");
        var ignoreHoliday = component.get("v.ignoreHoliday");
        var action = component.get('c.getPercentAllocationRows');
        var resReqForAssignHold = component.get("v.searchDetailObject.selectedResourceRequest");
        action.setParams({
            resReq: resReqForAssignHold,
            resId: component.get("v.resId"),
            lstAllocationRow: percentageAlloationRow,
            ignoreHoliday: ignoreHoliday,
            indexForDeletionOfRow:indexDel
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.percentageAlloationRow", result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    partialAssign : function(component, event, helper){
        component.set("v.isUpdated",false);
        var percentageAlloationRow = component.get("v.percentageAlloationRow");
        var ignoreHoliday = component.get("v.ignoreHoliday");
        var resReqForAssignHold = component.get("v.searchDetailObject.selectedResourceRequest");
        var action = component.get('c.updatePercentAllocationScheduleRows');
        action.setParams({
            resReq: resReqForAssignHold,
            resId: component.get("v.resId"),
            lstAllocationRow: percentageAlloationRow,
            ignoreHoliday: ignoreHoliday,
            isUpdated: component.get("v.isUpdated"),
            assignHoldValue: component.get("v.valueAssignHold")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showError",false);
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                var assignOrHold = component.get("v.valueAssignHold");
                if(assignOrHold == 'assign'){
                    assignOrHold = assignOrHold+'ed';
                }
                var nameContact = component.get("v.conName");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": nameContact+" has been succesfully "+assignOrHold,
                    "type": "success"
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.searchDetailObject.selectedResourceRequest.Id"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            } else if (state === "ERROR") {
                component.set("v.messageType", 'error' );
                var errors = response.getError();
                if (errors) {
                    component.set("v.showError",true);
                    if (errors[0] && errors[0].message) {
                        component.set("v.message",errors[0].message );//Fetching Custom Message.
                    }
                }
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
        
    },
    updatePercentAllocation : function (component, event, helper) {
        var percentageAlloationRow = component.get("v.percentageAlloationRow");
        var ignoreHoliday = component.get("v.ignoreHoliday");
        component.set("v.isUpdated",true);
        var resReqForAssignHold = component.get("v.searchDetailObject.selectedResourceRequest");
        var action = component.get('c.updatePercentAllocationScheduleRows');
        action.setParams({
            resReq: resReqForAssignHold,
            resId: component.get("v.resId"),
            lstAllocationRow: percentageAlloationRow,
            ignoreHoliday: ignoreHoliday,
            isUpdated: component.get("v.isUpdated")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showError",false);
                var result = response.getReturnValue();
                component.set("v.percentageAlloationRow", result);
            } else if (state === "ERROR") {
                component.set("v.messageType", 'error' );
                var errors = response.getError();
                if (errors) {
                    component.set("v.showError",true);
                    if (errors[0] && errors[0].message) {
                        component.set("v.message",errors[0].message );//Fetching Custom Message.
                    }
                }
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    //Methods For Displaying Contacts
    closeModelForDisplayingContacts: function (component, event, helper) {
        component.set("v.isDisplayingContacts", false);
    },
    navigate: function (component, event, helper) {
         component.set("v.spinner", true);
        // this function call on click on the previous page button  
        var page = component.get("v.page") || 1;
        // get the previous button label  
        var direction = event.getSource().getLocalId();
        // get the select option (drop-down) values.  
        var recordToDisply = component.find("recordSize").get("v.value");
        // set the current page,(using ternary operator.)  
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        helper.getContacts(component, page, recordToDisply, event);
    },
    onSelectChange: function (component, event, helper) {
         component.set("v.spinner", true);
        var page = 1
        var recordToDisply = component.find("recordSize").get("v.value");
        helper.getContacts(component, page, recordToDisply, event);
    },
    searchOutResources: function (component, event, helper) {
        component.set("v.spinner", true);
        component.set("v.searchOutResourcesPagePagesValue", true);
        component.set("v.isDisplayingContacts", true);
        // get the page Number if it's not define, take 1 as default
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.   
        var recordToDisply = component.find("recordSize").get("v.value");
        helper.getContacts(component, page, recordToDisply, event);
    },
    
    filterLogicSkills: function (component, event, helper) {
        component.set("v.showfilterLogicSkills", true);
    },
    filterLogicCertifications: function (component, event, helper) {
        component.set("v.showfilterLogicCertifications", true);
    },
    selectRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.resId", row.Id);
        component.set("v.resEmail",row.Email);
        component.set("v.conName", row.Name);
        component.set("v.valueAssignHold", action.name);
        switch (action.name) {
                case 'send_email':
                component.set("v.isSendEmail",true);
                break;
            case 'view_in_planners':
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/pse__ResourcePlannerForResource?id=" + row.Id
                });
                urlEvent.fire();
                break;
            case 'assign':
                if (component.get("v.resReqAvailability")) {                    
                    component.set("v.assignHold", true);
                    component.set("v.assignValue", true);
                    component.set("v.conName", row.Name);
                    component.set("v.resorceId", row.Id);
                    var listResReq = component.get("v.searchDetailObject.selectedResourceRequest");
                    if (listResReq != undefined && listResReq != null) {
                        var action = component.get('c.adjustHoursSchedule');
                        action.setParams({
                            resReq: component.get("v.searchDetailObject.selectedResourceRequest"),
                            resId: row.Id
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var result = response.getReturnValue();
                                component.set("v.mapStrategyBasedOnSchdulePattern", result);
                            } else if (state === "ERROR") {
                                var errors = response.getError();
                                console.error(errors);
                            }
                        });
                        $A.enqueueAction(action);
                    } 
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Please select a resource request.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                break;
            case 'hold':
                debugger;
                if (component.get("v.resReqAvailability")) {
                    var listResReq = component.get("v.searchDetailObject.selectedResourceRequest");
                    if (listResReq != undefined && listResReq != null) {
                        var isHoldDisabled = component.get("v.searchDetailObject.isHoldDisabled");
                        console.log('isHoldDisabled:::11',isHoldDisabled);
                        console.log('RRID::',component.get("v.searchDetailObject.selectedResourceRequest"));
                        if(isHoldDisabled == true){
                            // through an error
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": "Resources can only be Soft Booked on Custom or Residency Projects. You may only create an Assignment.",
                                "type": "error"
                            });
                            toastEvent.fire();
                        }else{
                            component.set("v.assignHold", true);
                            component.set("v.holdValue", true);
                            component.set("v.conName", row.Name);
                         	console.log('listResReq::',listResReq);
                            console.log('role::',component.get("v.searchDetailObject.selectedResourceRequest"));
                            var action = component.get('c.adjustHoursSchedule');
                            action.setParams({
                                resReq: component.get("v.searchDetailObject.selectedResourceRequest"),
                                resId: row.Id
                            });
                            action.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                    component.set("v.mapStrategyBasedOnSchdulePattern", result);
                                } else if (state === "ERROR") {
                                    var errors = response.getError();
                                    console.error(errors);
                                }
                            });
                            $A.enqueueAction(action);
                        }
                        
                    } 
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Please select a resource request.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                break;
            case 'release':
                if (component.get("v.resReqAvailability")) {
                    var listResReq = component.get("v.searchDetailObject.selectedResourceRequest");
                    if (listResReq != undefined && listResReq != null) {
                        var action = component.get('c.assignHoldSchedulePatterns');
                        action.setParams({
                            mapStrategyPattern: null,
                            patternKey: null,
                            resouId: row.Id,
                            resReq: component.get("v.searchDetailObject.selectedResourceRequest"),
                            assignHoldValue: component.get("v.valueAssignHold")
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var result = JSON.parse(response.getReturnValue());
                                if (result.responseCode == '700') {
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
                                } else if (result.responseCode == '800') {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "message": result.responseMessage,
                                        "type": "warning"
                                    });
                                    toastEvent.fire();
                                } else if (result.responseCode == '750') {
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
                            }
                        });
                        $A.enqueueAction(action);
                    } 
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Please select a resource request.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                break;
            case 'view_in_map':
                if ((row.MailingStreet != null && row.MailingStreet != '' && row.MailingStreet != 'undefined') &&
                    (row.MailingCity != null && row.MailingCity != '' && row.MailingCity != 'undefined') &&
                    (row.MailingState != null && row.MailingState != '' && row.MailingState != 'undefined')) {
                    component.set("v.mapOpenClose", true);
                    component.set('v.mapMarkers', [{
                        location: {
                            Street: row.MailingStreet,
                            City: row.MailingCity,
                            State: row.MailingState
                        },
                    }]);
                    component.set('v.zoomLevel', 16);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Can't display on maps, please enter the mailing address to view in maps.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                break;
                
        }
    },
    calculateSchedulingPatterns: function (component, event, helper) {
        component.set("v.spinner", true);
        var totalHoursOnResReq = component.get("v.searchDetailObject.selectedResourceRequest.pse__SOW_Hours__c");
        helper.calculateSchedulingPatternsHelper(component, event, totalHoursOnResReq);
    },
    assignHoldSchedulePattern: function (component, event, helper) {
        component.set("v.spinner", true);
        helper.assignHoldSchedulePatternHelper(component, event);
    },
    calculateCustomSchedulePatternTotalHours: function (component, event, helper) {
        component.set("v.spinner", true);
        helper.calculateCustomSchedulePatternTotalHoursHelper(component, event);
    },
    resetTheValues: function (component, event, helper) {
        var resetBoolean = true;
        component.set("v.spinner", true);
        helper.helperdoInit(component, event, helper, resetBoolean);
    },
    openRegionModal: function (component, event, helper) {
        component.set("v.isSearchRegionModal", true);
        component.set("v.regionName", '');
        component.set("v.isRegionTable", false);
    },
    searchRegion: function (component, event, helper) {
        var searchedText = component.get("v.regionName");
        if (searchedText == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a Region name."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.getRegions');
            action.setParams({
                searchText: searchedText
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    for (var i = 0; i < result.length; i++) {
                        var row = result[i];
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.pse__Region_Head__r) {
                            row.pse__Region_Head__c = row.pse__Region_Head__r.Name;
                        }
                        if (row.pse__Parent_Region__r) {
                            row.pse__Parent_Region__c = row.pse__Parent_Region__r.Name;
                        }
                        if (row.pse__Headquarters_Region__r) {
                            row.pse__Headquarters_Region__c = row.pse__Headquarters_Region__r.Name;
                        }
                    }
                    component.set("v.isRegionTable", true);
                    component.set("v.dataReg", result);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            });
            $A.enqueueAction(action);
            component.set('v.columnsReg', [{
                label: 'Region Name',
                fieldName: 'Name',
                initialWidth: 100,
                type: 'text'
            },
                                           {
                                               label: 'Region Owner',
                                               fieldName: 'pse__Region_Head__c',
                                               initialWidth: 100,
                                               type: 'text'
                                           },
                                           {
                                               label: 'Parent Region',
                                               fieldName: 'pse__Parent_Region__c',
                                               initialWidth: 100,
                                               type: 'text'
                                           },
                                           {
                                               label: 'Headquarters Region',
                                               fieldName: 'pse__Headquarters_Region__c',
                                               initialWidth: 100,
                                               type: 'text'
                                           },
                                           {
                                               label: 'Bookings',
                                               fieldName: 'pse__Bookings__c',
                                               initialWidth: 100,
                                               type: 'currency'
                                           },
                                           {
                                               label: 'Billings',
                                               fieldName: 'pse__Billings__c',
                                               initialWidth: 100,
                                               type: 'currency'
                                           },
                                           {
                                               label: 'Billable Hours (Internal)',
                                               fieldName: 'pse__Billable_Internal_Hours__c',
                                               initialWidth: 100,
                                               type: 'number'
                                           },
                                           {
                                               label: 'Total Costs',
                                               fieldName: 'pse__Total_Costs__c',
                                               initialWidth: 100,
                                               type: 'currency'
                                           },
                                           {
                                               label: 'Margin',
                                               fieldName: 'pse__Margin__c',
                                               initialWidth: 100,
                                               type: 'currency'
                                           }
                                          ]);
        }
    },
    selectParticularegion: function (component, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        if (selectedRow[0].Name != null && selectedRow[0].Name != '' && selectedRow[0].Name != 'undefined') {
            component.set("v.searchDetailObject.regionValue", selectedRow[0].Name);
        }
        component.set("v.isSearchRegionModal", false);
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    openPracticeModal: function (component, event, helper) {
        component.set("v.isSearchPracticeModal", true);
        component.set("v.practiceName", '');
        component.set("v.isPracticeTable", false);
    },
    searchPractice: function (component, event, helper) {
        var searchedText = component.get("v.practiceName");
        if (searchedText == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a Practice name."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.getPractices');
            action.setParams({
                searchText: searchedText
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    for (var i = 0; i < result.length; i++) {
                        var row = result[i];
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.pse__Practice_Head__r) {
                            row.pse__Practice_Head__c = row.pse__Practice_Head__r.Name;
                        }
                        if (row.pse__Parent_Practice__r) {
                            row.pse__Parent_Practice__c = row.pse__Parent_Practice__r.Name;
                        }
                        if (row.pse__Global_Practice__r) {
                            row.pse__Global_Practice__c = row.pse__Global_Practice__r.Name;
                        }
                    }
                    component.set("v.isPracticeTable", true);
                    component.set("v.dataPrac", result);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            });
            $A.enqueueAction(action);
            component.set('v.columnsPrac', [{
                label: 'Practice Name',
                fieldName: 'Name',
                initialWidth: 100,
                type: 'text'
            },
                                            {
                                                label: 'Practice Owner',
                                                fieldName: 'pse__Practice_Head__c',
                                                initialWidth: 100,
                                                type: 'text'
                                            },
                                            {
                                                label: 'Parent Practice',
                                                fieldName: 'pse__Parent_Practice__c',
                                                initialWidth: 100,
                                                type: 'text'
                                            },
                                            {
                                                label: 'Global Practice',
                                                fieldName: 'pse__Global_Practice__c',
                                                initialWidth: 100,
                                                type: 'text'
                                            },
                                            {
                                                label: 'Bookings',
                                                fieldName: 'pse__Bookings__c',
                                                initialWidth: 100,
                                                type: 'currency'
                                            },
                                            {
                                                label: 'Billings',
                                                fieldName: 'pse__Billings__c',
                                                initialWidth: 100,
                                                type: 'currency'
                                            },
                                            {
                                                label: 'Billable Hours (Internal)',
                                                fieldName: 'pse__Billable_Internal_Hours__c',
                                                initialWidth: 100,
                                                type: 'number'
                                            },
                                            {
                                                label: 'Total Costs',
                                                fieldName: 'pse__Total_Costs__c',
                                                initialWidth: 100,
                                                type: 'currency'
                                            },
                                            {
                                                label: 'Margin',
                                                fieldName: 'pse__Margin__c',
                                                initialWidth: 100,
                                                type: 'currency'
                                            }
                                           ]);
        }
    },
    selectParticularPractice: function (component, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        if (selectedRow[0].Name != null && selectedRow[0].Name != '' && selectedRow[0].Name != 'undefined') {
            component.set("v.searchDetailObject.practiceValue", selectedRow[0].Name);
        }
        component.set("v.isSearchPracticeModal", false);
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    openGroupModal: function (component, event, helper) {
        component.set("v.isSearchGroupModal", true);
        component.set("v.groupName", '');
        component.set("v.isGroupTable", false);
    },
    searchgroup: function (component, event, helper) {
        var searchedText = component.get("v.groupName");
        if (searchedText == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a Group name."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.getGroups');
            action.setParams({
                searchText: searchedText
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    for (var i = 0; i < result.length; i++) {
                        var row = result[i];
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.pse__Group_Head__r) {
                            row.pse__Group_Head__c = row.pse__Group_Head__r.Name;
                        }
                        if (row.pse__Parent_Group__r) {
                            row.pse__Parent_Group__c = row.pse__Parent_Group__r.Name;
                        }
                    }
                    component.set("v.isGroupTable", true);
                    component.set("v.dataGroup", result);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            });
            $A.enqueueAction(action);
            component.set('v.columnsGroup', [{
                label: 'Group Name',
                fieldName: 'Name',
                initialWidth: 100,
                type: 'text'
            },
                                             {
                                                 label: 'Group Owner',
                                                 fieldName: 'pse__Group_Head__c',
                                                 initialWidth: 100,
                                                 type: 'text'
                                             },
                                             {
                                                 label: 'Parent Group',
                                                 fieldName: 'pse__Parent_Group__c',
                                                 initialWidth: 100,
                                                 type: 'text'
                                             },
                                             {
                                                 label: 'Bookings',
                                                 fieldName: 'pse__Bookings__c',
                                                 initialWidth: 100,
                                                 type: 'currency'
                                             },
                                             {
                                                 label: 'Billings',
                                                 fieldName: 'pse__Billings__c',
                                                 initialWidth: 100,
                                                 type: 'currency'
                                             },
                                             {
                                                 label: 'Billable Hours (Internal)',
                                                 fieldName: 'pse__Billable_Internal_Hours__c',
                                                 initialWidth: 100,
                                                 type: 'number'
                                             },
                                             {
                                                 label: 'Total Costs',
                                                 fieldName: 'pse__Total_Costs__c',
                                                 initialWidth: 100,
                                                 type: 'currency'
                                             },
                                             {
                                                 label: 'Margin',
                                                 fieldName: 'pse__Margin__c',
                                                 initialWidth: 100,
                                                 type: 'currency'
                                             }
                                            ]);
        }
    },
    selectParticularGroup: function (component, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        if (selectedRow[0].Name != null && selectedRow[0].Name != '' && selectedRow[0].Name != 'undefined') {
            component.set("v.searchDetailObject.groupValue", selectedRow[0].Name);
        }
        component.set("v.isSearchGroupModal", false);
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    openDropDown: function (component, event, helper) {
        if (component.get("v.toggleDropdown") == "")
            component.set("v.toggleDropdown", "slds-is-open");
        else
            component.set("v.toggleDropdown", "");
    },
    openFilterWindow: function (cmp, event, helper) {
        helper.openFilterWindow(cmp, event, helper);
    },
    closeFilterWindow: function (cmp, event, helper) {
        helper.closeFilterWindow(cmp, event, helper);
    },
    handleSort: function(component, event, helper) {
        helper.handleSort(component, event);
    },
    costDisabledValueCheck : function(component, event, helper) {
        var cost = component.find('costFilter').get('v.value');
        if(cost == 'Is Null' || cost == 'Not Is Null' || cost == ''){
            component.set("v.costDisabled",true);
            component.set("v.searchDetailObject.defaultCostRateValue",'');
        }
        else{
            component.set("v.costDisabled",false);
        }
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    utilizationDisabledValueCheck : function(component, event, helper) {
        var utilization = component.find('utilizationFilter').get('v.value');
        if(utilization == 'Is Null' || utilization == 'Not Is Null' || utilization == ''){
            component.set("v.utilizationDisabled",true);
            component.set("v.searchDetailObject.scheduledUtilizationValue",'');
        }
        else{
            component.set("v.utilizationDisabled",false);
        }
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    practiceDisabledValueCheck : function(component, event, helper) {
        var practice = component.find('practiceFilter').get('v.value');
        if(practice == 'Is Null' || practice == 'Not Is Null' || practice == ''){
            component.set("v.practiceDisabled",true);
            component.set("v.searchDetailObject.practiceValue",'');
        }
        else{
            component.set("v.practiceDisabled",false);
        }
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    regionDisabledValueCheck : function(component, event, helper) {
        var region = component.find('regionFilter').get('v.value');
        if(region == 'Is Null' || region == 'Not Is Null' || region == ''){
            component.set("v.regionDisabled",true);
            component.set("v.searchDetailObject.regionValue",'');
        }
        else{
            component.set("v.regionDisabled",false);
        }
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    groupDisabledValueCheck : function(component, event, helper) {
        var group = component.find('groupFilter').get('v.value');
        if(group == 'Is Null' || group == 'Not Is Null' || group == ''){
            component.set("v.groupDisabled",true);
            component.set("v.searchDetailObject.groupValue",'');
        }
        else{
            component.set("v.groupDisabled",false);
        }
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    additionalFilterCountCalculation : function (component, event, helper){
        helper.additionalFilterCountCalculation(component, event, helper);
    },
    backToResourceRequest : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.searchDetailObject.selectedResourceRequest.Id"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    submitForPDMApproval : function (component, event, helper) {
        component.set("v.spinner", true);
        helper.submitForPDMApprovalHelper(component, event, helper);
    },
    saveFilter : function (component, event, helper){
        component.set("v.spinner", true);
        helper.saveFilterHelper(component, event, helper);
        
    },
    removeSkillsAndCertificationNotRequired : function (component, event, helper){
        var skillcertification = event.getSource().getLocalId();
        if(skillcertification == 'skillRemove'){
            var skillList = component.get("v.searchDetailObject.lstSkill");
            var skillListAfterRemoval = [];
            if(skillList != null && skillList != '' && skillList != 'undefined' && skillList.length > 0){
                var skillIndex = 0;
                for(var i = 0; i < skillList.length ; i++){
                    if(skillList[i].isSelected){
                        skillList[i].index = skillIndex;
                        skillListAfterRemoval.push(skillList[i]);
                        skillIndex = skillIndex + 1;
                    }	
                }
                component.set("v.searchDetailObject.lstSkill",skillListAfterRemoval);
                var skillValue = 'Skills (' + skillListAfterRemoval.length + ')';
                component.set("v.accordionSkillValue",skillValue);
            }
        }
        else if(skillcertification == 'certificationRemove'){
            var certificationList = component.get("v.searchDetailObject.lstCertification");
            var certificationListAfterRemoval = [];
            if(certificationList != null && certificationList != '' && certificationList != 'undefined' && certificationList.length > 0){
                var certificationIndex = 0;
                for(var i = 0; i < certificationList.length ; i++){
                    if(certificationList[i].isSelected){
                        certificationList[i].index = certificationIndex;
                        certificationListAfterRemoval.push(certificationList[i]);
                        certificationIndex = certificationIndex + 1;
                    }	
                }
                component.set("v.searchDetailObject.lstCertification",certificationListAfterRemoval);
                var certificationValue = 'Certifications (' + certificationListAfterRemoval.length + ')';
                component.set("v.accordionCertificationValue",certificationValue);
            }
        }
    },
    deleteParticularRowBasedOnPercentAllocation : function (component, event, helper){
        var percentAllocationList = component.get("v.percentageAlloationRow");
        var percentAllocationListAfterRemoval = [];
        if(percentAllocationList != null && percentAllocationList != '' && percentAllocationList != 'undefined' && percentAllocationList.length > 0){
            var percentAllocationIndex = 0;
            for(var i = 0; i < percentAllocationList.length ; i++){
                if(percentAllocationList[i].isSelectedCheck){
                    percentAllocationList[i].indexForDeletion = percentAllocationIndex;
                    percentAllocationListAfterRemoval.push(percentAllocationList[i]);
                    percentAllocationIndex = percentAllocationIndex + 1;
                }	
            }
            component.set("v.percentageAlloationRow",percentAllocationListAfterRemoval);
        }
    },
    validateDatesClick : function (component, event, helper){
        component.set("v.startDateForValidation",component.get("v.searchDetailObject.startDate"));
        component.set("v.endDateForValidation",component.get("v.searchDetailObject.endDate"));
    },
    validateDates : function (component, event, helper){
        var endDate = component.get("v.searchDetailObject.endDate");
        if(component.get("v.searchDetailObject.endDate") < component.get("v.searchDetailObject.startDate")){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "End Date should be greater than the Start Date."
            });
            toastEvent.fire();
            component.set("v.searchDetailObject.endDate",component.get("v.endDateForValidation"));
            component.set("v.searchDetailObject.startDate",component.get("v.startDateForValidation"));
        }
        helper.searchResourceCountCalculation(component, event, helper);
    },
    nameChangeMethod : function (component, event, helper){
        helper.searchResourceCountCalculation(component, event, helper);
    },
    resourceRequestNameChangeMethod : function (component, event, helper){
        helper.searchResourceCountCalculation(component, event, helper);
    },
    sendEmailToResource : function (component, event, helper){
        var action = component.get('c.sendEmailToParticularResource');
        action.setParams({
            emailAdd: component.get("v.resEmail"),
            emailSub: component.get("v.emailSubject"),
            emailBody: component.get("v.emailBody")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email has been sent succesfully.",
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.isSendEmail",false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    showLowerLevelDetails2 : function (component, event, helper){
        helper.showLowerLevelDetails2(component, event, helper);
    },
    selectRowActionLowerLevelDetails: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.conNameLowerLevel",row.Name);
        switch (action.name) {
            case 'past_jobs':
                var action = component.get('c.displayAssignmentsBasedOnResource');
                action.setParams({
                    resourceRecordId: row.Id
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.isPastJobs",true);
                        if(result != undefined){
                            result.forEach(function(record){
                                record.linkAssignmentName = '/'+record.Id;
                                record.linkAssignmentProjectName = '/'+record.pse__Project__c;
                                //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                                if (record.pse__Project__r) {
                                    record.pse__Project__c = record.pse__Project__r.Name;
                                }   
                            });                      
                            component.set("v.assignmentData", result);
                            component.set('v.assignmentDataColoumns', [{
                                label: 'Assignment',
                                fieldName: 'linkAssignmentName',
                                type: 'url',
                                typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
                            },
                                                                       
                                                                       {
                                                                           label: 'Project',
                                                                           fieldName: 'linkAssignmentProjectName',
                                                                           type: 'url',
                                                                           typeAttributes: {label: { fieldName: 'pse__Project__c' }, target: '_blank'}
                                                                       },
                                                                       {
                                                                           label: 'Start Date',
                                                                           fieldName: 'pse__Start_Date__c',
                                                                           type: 'text'
                                                                       },
                                                                       {
                                                                           label: 'End Date',
                                                                           fieldName: 'pse__End_Date__c',
                                                                           type: 'text'
                                                                       },
                                                                       {
                                                                           label: 'Status',
                                                                           fieldName: 'pse__Status__c',
                                                                           type: 'text'
                                                                       },
                                                                       {
                                                                           label: 'Role',
                                                                           fieldName: 'pse__Role__c',
                                                                           type: 'text'
                                                                       }
                                                                      ]);
                            
                        }
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.error(errors);
                    }
                });
                $A.enqueueAction(action);
                break;
            case 'c_q':
                var action = component.get('c.getCompetenceQualifications');
                action.setParams({
                    resourceRecordId: row.Id
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.isCQ",true);
                        if(result != undefined){
                            var skillCompetencyList = result.skillRatList;
                            var certificationqualificationList = result.certificationRatList;
                            skillCompetencyList.forEach(function(record){
                                record.linkSkillName = '/'+record.pse__Skill_Certification__c;
                                //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                                if (record.pse__Skill_Certification__r) {
                                    record.pse__Skill_Certification__c = record.pse__Skill_Certification__r.Name;
                                }   
                            });                      
                            component.set("v.competenceDataList", result.skillRatList);
                            certificationqualificationList.forEach(function(record2){
                                record2.linkCertificationName = '/'+record2.pse__Skill_Certification__c;
                                //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                                if (record2.pse__Skill_Certification__r) {
                                    record2.pse__Skill_Certification__c = record2.pse__Skill_Certification__r.Name;
                                }   
                            });
                            component.set("v.qualificationDataList", result.certificationRatList);
                            component.set('v.competenceDataColoumns', [{
                                label: 'Competence',
                                fieldName: 'linkSkillName',
                                type: 'url',
                                typeAttributes: {label: { fieldName: 'pse__Skill_Certification__c' }, target: '_blank'}
                            },
                                                                       
                                                                       {
                                                                           label: 'Rating',
                                                                           fieldName: 'pse__Rating__c',
                                                                           type: 'text',
                                                                       },
                                                                       {
                                                                           label: 'Notes',
                                                                           fieldName: 'pse__Notes__c',
                                                                           type: 'text'
                                                                       },
                                                                       {
                                                                           label: 'Evaluation Date',
                                                                           fieldName: 'pse__Evaluation_Date__c',
                                                                           type: 'date'
                                                                       },
                                                                       {
                                                                           label: 'Last Modified Date',
                                                                           fieldName: 'LastModifiedDate',
                                                                           type: 'date'
                                                                       },                     
                                                                      ]);
                                                                       component.set('v.qualificationDataColoumns', [{
                                                                       label: 'Qualification',
                                                                       fieldName: 'linkCertificationName',
                                                                       type: 'url',
                                                                       typeAttributes: {label: { fieldName: 'pse__Skill_Certification__c' }, target: '_blank'}
                                                                       },
                                                                       
                                                                       {
                                                                       label: 'Rating',
                                                                       fieldName: 'pse__Rating__c',
                                                                       type: 'text',
                                                                       },
                                                                       {
                                                                       label: 'Notes',
                                                                       fieldName: 'pse__Notes__c',
                                                                       type: 'text'
                                                                       },
                                                                       {
                                                                       label: 'Evaluation Date',
                                                                       fieldName: 'pse__Evaluation_Date__c',
                                                                       type: 'date'
                                                                       },
                                                                       {
                                                                       label: 'Expiration Date',
                                                                       fieldName: 'pse__Expiration_Date__c',
                                                                       type: 'date'
                                                                       },
                                                                       {
                                                                       label: 'Last Modified Date',
                                                                       fieldName: 'LastModifiedDate',
                                                                       type: 'date'
                                                                       },                     
                                                                      ]);
                            
                        }
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.error(errors);
                    }
                });
                $A.enqueueAction(action);
                break;
        }
    },
    attributeCountCalculation : function(component, event, helper){
        var lstSearchDetail = component.get("v.searchDetailObject");
        var attributeCount = 0;
        if(lstSearchDetail.workedWithCustomer){
            attributeCount++;
        }
        if(lstSearchDetail.availability){
            attributeCount++;
        }
        if(lstSearchDetail.internal){
            attributeCount++;
        }
        if(lstSearchDetail.distance){
            attributeCount++;
            var isLocationAvailble =  component.get("v.searchDetailObject").isLocationAvailble;
        }
        if(lstSearchDetail.rdcFilter){
            attributeCount++;
        }
        var attributeValue = 'Attributes (' + attributeCount + ')';
        component.set("v.accordionAttributeValue",attributeValue);
    },
    roleCount : function(component, event, helper){
        helper.roleCount(component, event, helper);
    },
    statusChange : function(component, event, helper){
        helper.statusChange(component, event, helper);
    },
    addressDetailsChangeCount : function(component, event, helper){
        helper.addressDetailsChangeCount(component, event, helper);
    },
    showUpperLevelDetails : function(component, event, helper){
        component.set("v.isLowerLevelDetails", false);
    }
})
({  fetchRecords : function(component) {  
    
    var recId = component.get( "v.recordId" );
    if(recId.startsWith("a02")){
        component.set( "v.dealRecord", true);  
    }else{
        component.set( "v.dealRecord", false);  
    }
    
    
    var temObjName = component.get( "v.sobjectName" ); 
    component.set( "v.ObjectName", temObjName.replace( "__c", "" ).replace( "_", " " ) );  
    var action = component.get( "c.fetchRecs" );  
    action.setParams({  
        recId: component.get( "v.recordId" ),  
        sObjName: temObjName,  
        parentFldNam: component.get( "v.parentFieldName" ),  
        strCriteria: component.get( "v.criteria" )  
    });  
    action.setCallback(this, function(response) {  
        var state = response.getState();  
        if ( state === "SUCCESS" ) {  
            
            var tempTitle = component.get( "v.title" );  
            component.set( "v.listRecords", response.getReturnValue().listsObject );  
            component.set( "v.title", tempTitle + response.getReturnValue().strTitle );
            
        }  
    }); 
    var action2 = component.get( "c.getRecords" );  
    action2.setParams({  
        recIds: component.get( "v.recordId" )
    });  
    action2.setCallback(this, function(response) {  
        var state = response.getState();  
        if ( state === "SUCCESS" ) {  
            console.log(response.getReturnValue());
            var time = new Date().getHours();
            if (response.getReturnValue() === true) {
                component.set( "v.showButton", false);
            }
            else
                component.set( "v.showButton", true);
            
        }  
    }); 
    $A.enqueueAction(action);  
    $A.enqueueAction(action2);  
}, 
  
  handleSuccess: function(component, event, helper) {
     component.set("v.acceptterms", false);
      // Show toast
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          "type": "success",
          "title": "Success!",
          "message": "Record has been created successfully."
      });
      toastEvent.fire();
      
      // navigate to new record on successful save
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
          "recordId": event.getParam("response").id,
          "slideDevName": "detail"
      });
      navEvt.fire();
  },
  
  viewRelatedList: function (component, event, helper) {  
      component.set("v.showRelatedList", true);
      var strAccId = component.get("v.recordId");
      console.log('Account Id ====>'+strAccId);
      $A.createComponent("c:FBE_FPRM_DisplayListofRecordsUsingDataTable", 
                         {idval : strAccId},
                         function(result, status) {
                             if (status === "SUCCESS") {
                                 component.find('overlayLibDemos').showCustomModal({
                                     header: "Deal Extensions",
                                     body: result, 
                                     showCloseButton: true,
                                     cssClass: "mymodal", 
                                 })
                             }                               
                         });
      
      /*var navEvt = $A.get("e.force:navigateToRelatedList");  
        var childrel = component.get("v.childRelName")
        navEvt.setParams({  
            "relatedListId": childrel.concat("__r") ,  
            "parentRecordId": component.get( "v.recordId" )  
        });  
        navEvt.fire(); */
    },  
  onCheck: function(cmp, evt) {
      var checkCmp = cmp.find("checkbox"); 
      //var checkCmp = cmp.find("checkbox-unique-id-72");
      cmp.set('v.myBool', checkCmp.get("v.value"));
      console.log('mybool value : ', cmp.get("v.myBool"));
  },
  
  showPopup : function (cmp, evt, helper) {
      cmp.set('v.showpopup', true);
  },
  acceptTerms : function (cmp, evt, helper) {
      var reason = cmp.find("reasonField").get("v.value");
      console.log(reason);
      console.log(cmp.find("checkbox").get("v.value"));
      
      
      if ((!reason || !cmp.find("checkbox").get("v.value"))) {
          console.log(cmp.find("checkbox").get("v.value"));
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              title : 'Error',
              message:'Please fill Required Fields.',
              type: 'error'
          });
          toastEvent.fire();
          //alert('Please fill Required Fields');  
      }
      
      else{
          
          cmp.find("editForm").submit();
          let button = evt.getSource();
          button.set('v.disabled',true);

      }
      
      //cmp.set("v.showpopup", false);
      //cmp.set('v.acceptterms', true);
  },
  closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.showpopup", false);
  },
  closeModels: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.acceptterms", false);
  },
  viewRecord: function (component, event, helper) {  
      
      
      var navEvt = $A.get("e.force:navigateToSObject");  
      var recId = event.getSource().get( "v.value" )  
      navEvt.setParams({  
          "recordId": recId  
      });  
      navEvt.fire();  
      
  } 
  
 })
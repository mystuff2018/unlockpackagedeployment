function onSearchByChanged(value) {
  if (value === 'Order Number') {
    setVerifyWith(value, ['Bill To Postal Code']);
  }
  else if (value === 'Account Number') {
    setVerifyWith(value, ['PO Number','Bill To Postal Code','Company Name']);
  }
  else if (value === 'PO Number') {
    setVerifyWith(value, ['DFN Account Number','Bill To Postal Code','Company Name']);
  }
  else if (value === 'Billing Information') {
    hide('verify-with-section',false);
    hide('verify-with-select',true);
    hide('verify-with-value',true);
    show('address-section',false);
    show('first-name',true);
    show('last-name',true);
    show('phone-number',true);
    show('zip-code',true);
    hide('search-by-section',false);
    hide('search-by-value',true);
  }
}

function setVerifyWith(searchBy, values) {
  var sel = getElem('verify-with-select');
  for (var opt in sel.children) sel.remove(opt);
  for (var i in values) {
     var o = document.createElement("option");
     o.text = values[i]; o.value = values[i];
     sel.add(o);
  }
  show('verify-with-section',false);
  show('verify-with-select',true);
  show('verify-with-value',true);
  hide('address-section',false);
  hide('first-name',true);
  hide('last-name',true);
  hide('phone-number',true);
  hide('zip-code',true);
  getElem('search-by-value').placeholder = 'Enter ' + searchBy;
  getElem('verify-with-value').placeholder = 'Enter ' + values[0];
}

function showExtension() {
  getElem('add-phone-extension').style.display = 'none';
  getElem('phone-extension').style.display = 'block';
  return false;
}

function showTechSupportExtension(id) {
   getElem(id).style.display = 'block';
   getElem('spacer').style.display = 'none';
   if ((id === 'phone-extension' && getElem('alt-phone-extension').style.display === 'none') || 
      (id === 'alt-phone-extension' && getElem('phone-extension').style.display === 'none')) {
      getElem('spacer').style.display = 'block';
   }
   return false;
}

function showChatExtension() {
  getElem('add-phone-extension').style.display = 'none';
  getElem('phone-extension').style.display = 'block';
  return false;
}

function setPageTitle(val) {
  document.title = val;
}

function show(id, setRequired) {
  var elem = getElem(id);
  elem.style.display = 'block';
  if (setRequired)
    elem.setAttribute('required','true');
}

function hide(id, setRequired) {
  var elem = getElem(id);
  elem.style.display = 'none';
  if (setRequired)
    elem.removeAttribute('required');
}

function getElem(id) {
  return document.getElementById(id);
}

function setTitle(val) {
  document.title = val;
}

function initESW(gslbBaseURL, baseUrl, orgId, deployId, buttonId) {
  embedded_svc.settings.displayHelpButton = false;
  embedded_svc.settings.enabledFeatures = ['LiveAgent'];
  embedded_svc.settings.entryFeature = 'LiveAgent';
  
  embedded_svc.init('https://'+baseUrl, 'https://'+baseUrl, gslbBaseURL, orgId, 'Services_Chat',
  {
    'baseLiveAgentContentURL': 'https://c.la1cx.salesforceliveagent.com/content',
    'deploymentId': deployId,
    'buttonId': buttonId,
    'baseLiveAgentURL': 'https://d.la1cx.salesforceliveagent.com/chat',
    'eswLiveAgentDevName': 'Services_Chat',
    'isOfflineSupportEnabled': false
  });
};

function initChat(baseUrl, orgId, deployId, buttonId) {
  if (!window.embedded_svc) {
    var s = document.createElement('script');
    s.setAttribute('src', 'https://service.force.com/embeddedservice/5.0/esw.min.js');
    s.onload = function() {
       initESW(null, baseUrl, orgId, deployId, buttonId);
    };
    document.body.appendChild(s);
  } else {
    initESW('https://service.force.com', baseUrl, orgId, deployId, buttonId);
  }
}

function submitChat(firstName, lastName, email, company, phone, ext, serviceTag, queueName, desc, recTypeId) {

  embedded_svc.settings.targetElement = document.getElementById('snapinplaceholder');
  embedded_svc.settings.extraPrechatFormDetails = [
    {"label":"Company","name":"company","value":company,"displayToAgent":true}, 
    {"label":"First Name","name":"FirstName","value":firstName,"displayToAgent":true}, 
    {"label":"Last Name","name":"lastName","value":lastName}, 
    {"label":"Phone","name":"phone","value":phone,"displayToAgent":true}, 
    {"label":"Phone Extension","name":"Primary_Phone_Ext__c","value":ext,"displayToAgent":true},
    {"label":"Email","name":"email","value":email,"displayToAgent":true}, 
    {"label":"Description","name":"Description","value":desc,"displayToAgent":true}, 
    {"label":"Subject","name":"Subject","value":desc,"displayToAgent":true },
    {"label":"Service Tag","name":"Service_Tag__c","value":serviceTag,"displayToAgent":false}, 
    {"label":"Queue","name":"Queue__c","value":queueName,"displayToAgent":false},
    {"label":"Origin","name":"Origin","value":"Chat","displayToAgent":true}, 
    {"label":"Record Type","name":"RecordTypeId","value":recTypeId,"displayToAgent":false}]; 

  embedded_svc.settings.extraPrechatInfo = [
  {"entityName":"Contact",
  "showOnCreate":true,
  "linkToEntityName":"Case",
  "linkToEntityField":"ContactId",
  "saveToTranscript":"ContactId",
  "entityFieldMaps": [
    {"isExactMatch":true,"fieldName":"FirstName","doCreate":true,"doFind":true,"label":"First Name"}, 
    {"isExactMatch":true,"fieldName":"LastName","doCreate":true,"doFind":true,"label":"Last Name"}, 
    {"isExactMatch":true,"fieldName":"Email","doCreate":true,"doFind":true,"label":"Email"}]}, 
  {"entityName":"Case",
  "showOnCreate":true,
  "saveToTranscript":"CaseId",
  "entityFieldMaps": [
    {"isExactMatch":false,"fieldName":"Subject","doCreate":true,"doFind":false,"label":"Subject"}, 
    {"isExactMatch":false,"fieldName":"Description","doCreate":true,"doFind":false,"label":"Description"}, 
    {"isExactMatch":false,"fieldName":"Status","doCreate":true,"doFind":false,"label":"Status"}, 
    {"isExactMatch":false,"fieldName":"Origin","doCreate":true,"doFind":false,"label":"Origin"}, 
    {"isExactMatch":false,"fieldName":"Service_Tag__c","doCreate":true,"doFind":false,"label":"Service Tag"}, 
    {"isExactMatch":false,"fieldName":"RecordTypeId","doCreate":true,"doFind":false,"label":"Record Type"}, 
    {"isExactMatch":false,"fieldName":"Queue__c","doCreate":true,"doFind":false,"label":"Queue"}]
  }];

  showChatInProgress();
  return false;
}

function submitFirstChat(firstName, lastName, email, sysName, desc, recTypeId) {
    
  embedded_svc.settings.targetElement = document.getElementById('snapinplaceholder');
  embedded_svc.settings.extraPrechatFormDetails = [
  {"label":"First Name", "name":"FirstName", "value":firstName, "displayToAgent":true}, 
  {"label":"Last Name", "name":"lastName", "value":lastName,"displayToAgent":true},
  {"label":"Email", "name":"email", "value":email, "displayToAgent":true}, 
  {"label":"Description", "name":"Description", "value":desc, "displayToAgent":true}, 
  {"label":"Subject", "name":"Subject", "value":desc, "displayToAgent":true},
  {"label":"Queue", "name":"Queue__c", "value":"FIRST_Helpdesk", "displayToAgent":false},
  {"label":"System Name", "name":"System_Name__c", "value":sysName, "displayToAgent":false},
  {"label":"Origin", "name":"Origin", "value":"Chat", "displayToAgent":true}, 
  {"label":"Record Type", "name":"RecordTypeId", "value":recTypeId, "displayToAgent":false}]; 
     
  embedded_svc.settings.extraPrechatInfo = [
  {"entityName":"Contact", "showOnCreate":true, "linkToEntityName":"Case", "linkToEntityField":"ContactId", "saveToTranscript":"ContactId",
     "entityFieldMaps": [
        {"isExactMatch":true, "fieldName":"FirstName", "doCreate":true, "doFind":true, "label":"First Name"}, 
        {"isExactMatch":true, "fieldName":"LastName", "doCreate":true, "doFind":true, "label":"Last Name"}, 
        {"isExactMatch":true, "fieldName":"Email", "doCreate":true, "doFind":true, "label":"Email"}]}, 
              {"entityName":"Case",
              "showOnCreate":true,
              "saveToTranscript":"CaseId",
              "entityFieldMaps": [
                 {"isExactMatch":false, "fieldName":"Subject", "doCreate":true, "doFind":false, "label":"Subject"}, 
                 {"isExactMatch":false, "fieldName":"Description", "doCreate":true, "doFind":false, "label":"Description"}, 
                 {"isExactMatch":false, "fieldName":"Status", "doCreate":true, "doFind":false, "label":"Status"}, 
                 {"isExactMatch":false, "fieldName":"Origin", "doCreate":true, "doFind":false, "label":"Origin"}, 
                 {"isExactMatch":false, "fieldName":"System_Name__c", "doCreate":true, "doFind":false, "label":"System Name"}, 
                 {"isExactMatch":false, "fieldName":"RecordTypeId", "doCreate":true, "doFind":false, "label":"Record Type"}, 
                 {"isExactMatch":false, "fieldName":"Queue__c", "doCreate":true, "doFind":false, "label":"Queue"}]}];
     
  showChatInProgress();
  return false;
}

function submitTechSupportChat(firstName, lastName, email, srNumber, serviceTag, supportRole, desc, recTypeId) {

  embedded_svc.settings.extraPrechatFormDetails = [
    {"label":"First Name", "name":"FirstName","value":firstName,"displayToAgent":true}, 
    {"label":"Last Name","name":"lastName","value":lastName}, 
    {"label":"Email", "name":"email","value":email,"displayToAgent":true},
    {"label":"Description", "name":"Description", "value":desc,"displayToAgent":true}, 
    {"label":"Subject", "name":"Subject","value":desc,"displayToAgent":true},
    {"label":"Queue", "name":"Queue__c", "value":"Internal_Tech_Support","displayToAgent":false},
    {"label":"SR Number","name":"SR_Number__c","value":srNumber,"displayToAgent":false},
    {"label":"Support Role","name":"Support_Role__c","value":supportRole,"displayToAgent":false},
    {"label":"Service Tag","name":"Service_Tag__c","value":serviceTag,"displayToAgent":false},
    {"label":"Origin","name":"Origin","value":"Chat","displayToAgent":true}, 
    {"label":"Record Type","name":"RecordTypeId","value":recTypeId,"displayToAgent":false}]; 
 
 embedded_svc.settings.extraPrechatInfo = [
       {"entityName":"Contact",
       "showOnCreate":true,
       "linkToEntityName":"Case",
       "linkToEntityField":"ContactId",
       "saveToTranscript":"ContactId",
       "entityFieldMaps": [
         {"isExactMatch":true,"fieldName":"FirstName","doCreate":true,"doFind":true,"label":"First Name"}, 
         {"isExactMatch":true,"fieldName":"LastName","doCreate":true,"doFind":true,"label":"Last Name"}, 
         {"isExactMatch":true,"fieldName":"Email","doCreate":true,"doFind":true,"label":"Email"}]}, 
       {"entityName":"Case",
       "showOnCreate":true,
       "saveToTranscript":"CaseId",
       "entityFieldMaps": [
         {"isExactMatch":false,"fieldName":"Subject","doCreate":true,"doFind":false,"label":"Subject"}, 
         {"isExactMatch":false,"fieldName":"Description","doCreate":true,"doFind":false,"label":"Description"}, 
         {"isExactMatch":false,"fieldName":"Status","doCreate":true,"doFind":false,"label":"Status"}, 
         {"isExactMatch":false,"fieldName":"Origin","doCreate":true,"doFind":false,"label":"Origin"}, 
         {"isExactMatch":false,"fieldName":"SR_Number__c","doCreate":true,"doFind":false,"label":"SR Number"}, 
         {"isExactMatch":false,"fieldName":"Support_Role__c","doCreate":true,"doFind":false,"label":"Support Role"}, 
         {"isExactMatch":false,"fieldName":"Service_Tag__c","doCreate":true,"doFind":false,"label":"Service Tag"},
         {"isExactMatch":false,"fieldName":"RecordTypeId","doCreate":true,"doFind":false,"label":"Record Type"}, 
         {"isExactMatch":false,"fieldName":"Queue__c","doCreate":true,"doFind":false,"label":"Queue"}]
       }];
 
 showChatInProgress();
 return false;
}

function showChatInProgress() {
  document.getElementById('form').style.display = 'none';
  embedded_svc.bootstrapEmbeddedService();
  document.getElementById('chat').style.display = 'block';
}
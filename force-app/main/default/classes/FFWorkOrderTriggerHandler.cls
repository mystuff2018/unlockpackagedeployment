/**
* Created by Bruno_Frosi on 2/28/2020.
*/

public with sharing class FFWorkOrderTriggerHandler extends TriggerHandler {
    public Id recordTypeIdDSP {get;set;}
    public static Id recordTypeIdInstField {get;set;}
    public Map<Id, WorkOrder> TriggerNewMap {get;set;}
    public Map<Id, WorkOrder> TriggerOldMap {get;set;}
    public List<WorkOrder> TriggerNew {get;set;}
    public List<WorkOrder> TriggerOld {get;set;}
    
    public FFWorkOrderTriggerHandler() {
        if(TriggerHandler.isBypassed(FFWorkOrderTriggerHandler.class.getName())){
            //Prevent constructor execution when trigger is already bypassed
            return;
        }
        filterRecordsByRecordType();
        recordTypeIdDSP = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation DSP').getRecordTypeId();
        recordTypeIdInstField = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Field').getRecordTypeId();
        System.debug('@@21 ##### ' +recordTypeIdInstField);
  
    }
    
    public override void beforeInsert() {
        WorkOrderSchedulingTriggerHandler.CheckWorkOrderStatus(this.TriggerNew);
        //updateWOAddressFromProjectLocationINSERT(this.TriggerNew); - Location Centric change US 11646891
         updateWOAddressFromLocationINSERT(this.TriggerNew);
         preventWOCreationOnTaskWithChildren(this.TriggerNew);
        //populatePartnerDetailsFields(); // this is listed as before insert but I'm not sure, because this code was running before every DML
    }
    
    public override void afterInsert() {
         if(!System.isBatch() && !System.isFuture()){
            getPreferredPartnerFromGscv();
        }
      
        updateProjectTask(this.TriggerNewMap);
        updateParentRegionFromProject();
    }
    
    public override void beforeUpdate() {
        system.debug('beforeUpdate');  
       // updateWOAddressFromProjectLocation(TriggerOldMap, TriggerNewMap);
          updateWOAddressFromLocation(TriggerOldMap, TriggerNewMap);
          preventWOCreationOnTaskWithChildren(this.TriggerNew);
    }
    
    
    public override void afterUpdate() {
        updateWorkOrderStatus(TriggerNewMap);
        clickIntegration();
    }
    
    private void filterRecordsByRecordType() {
        Set<Id> ffRecordTypes = RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', FFWorkOrderTriggerHandler.class.getName()));
        
        Boolean hasFFRT = false;
        Boolean hasOtherRT = false;
        
        this.TriggerNewMap = new Map<Id, WorkOrder>();
        this.TriggerOldMap = new Map<Id, WorkOrder>();
        this.TriggerNew = new List<WorkOrder>();
        this.TriggerOld = new List<WorkOrder>();
        
        //mount triggerNewMap
        if(Trigger.NewMap != null) {
            for (Id woId : Trigger.NewMap.keySet()) {
                WorkOrder woNew = (WorkOrder) Trigger.newMap.get(woId);
                if (ffRecordTypes.contains(woNew.RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerNewMap.put(woId, woNew);
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerNew
        if(Trigger.New != null) {
            for (WorkOrder woNew : (List<WorkOrder>)Trigger.New) {
                if (ffRecordTypes.contains(woNew.RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerNew.add(woNew);
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerOldMap
        if(Trigger.OldMap != null) {
            for (Id woId : Trigger.OldMap.keySet()) {
                WorkOrder woOld = (WorkOrder) Trigger.OldMap.get(woId);
                if (ffRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woId)) {
                    hasFFRT = true;
                    this.TriggerOldMap.put(woId, woOld);
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerOld
        if(Trigger.Old != null) {
            for (WorkOrder woOld : (List<WorkOrder>)Trigger.Old) {
                if (ffRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woOld.Id)) {
                    hasFFRT = true;
                    this.TriggerOld.add(woOld);
                } else hasOtherRT = true;
            }
        }
        
        if(hasFFRT)
            system.debug('Continue with this handler. Other handlers should be bypassed.');
        else if(!hasFFRT && hasOtherRT)
            TriggerHandler.bypass(FFWorkOrderTriggerHandler.class.getName());
    }
    
    public void updateWorkOrderStatus(Map<Id,WorkOrder> newMap) {
        Set<Id> setPTIdsSub = new Set<Id>();
        Set<Id> setPTIdsCloCan = new Set<Id>();
        Set<Id> setPTAux = new Set<Id>();
        
        for (WorkOrder objWo : newMap.values())
        {
            setPTAux.add(objWo.Project_Task__c);
            setPTAux.add(objWo.RecordTypeId);
        }
        
        Map<Id, pse__Project_Task__c> mapIdxPT = new Map<Id, pse__Project_Task__c>([SELECT Id, pse__Summary__c
                                                                                    FROM pse__Project_Task__c
                                                                                    WHERE Id IN:setPTAux]);
        
        Map<Id, RecordType> mapIdxRT = new Map<Id, RecordType>([SELECT Id, DeveloperName
                                                                FROM RecordType
                                                                WHERE Id IN:setPTAux]);
        
        
        for(Id woId : newMap.keySet())
        {
            WorkOrder newWO = newMap.get(woId);
            if((mapIdxRT.get(newWO.RecordTypeId) != null && mapIdxRT.get(newWO.RecordTypeId).DeveloperName.equals('Installation_Badge')||
                mapIdxRT.get(newWO.RecordTypeId).DeveloperName.equals('Installation_DSP')) &&
               mapIdxPT.get(newWO.Project_Task__c) != null && mapIdxPT.get(newWO.Project_Task__c).pse__Summary__c == false)
            {
                if(newWO.Status.equals('FF - Submitted'))
                {
                    setPTIdsSub.add(newWO.Project_Task__c);
                }
                
                if(newWO.Status.equals('FF - Closed') || newWO.Status.endsWith('FF - Cancelled'))
                {
                    setPTIdsCloCan.add(newWO.Project_Task__c);
                }
            }
        }
        //Updates the workorder if the status is Submitted
        if(!setPTIdsSub.isEmpty())
        {
            List<pse__Project_Task__c> lstPTIdsSub = new List<pse__Project_Task__c>();
            lstPTIdsSub = [SELECT pse__Started__c, pse__Status__c,pse__Start_Date_Time__c
                           FROM pse__Project_Task__c
                           WHERE Id IN: setPTIdsSub ];
            
            for (pse__Project_Task__c objPT : lstPTIdsSub)
            {
                if(objPT.pse__Started__c == false )
                {
                    objPT.pse__Started__c = true;
                    objPT.pse__Status__c = 'Started';
                    // objPT.pse__Start_Date_Time__c = datetime.now();
                }
            }
            
            update lstPTIdsSub;
        }
        //Queries siblings Workorders and if all of them are closed or cancelled it updates the Project Task
        if(!setPTIdsCloCan.isEmpty())
        {
            // map of project task Id by obj project task
            Map<String, pse__Project_Task__c> mapPTIdxPT = new Map<String, pse__Project_Task__c>();
            for (pse__Project_Task__c objPT : [SELECT Id, pse__Completed__c, pse__Status__c,pse__End_Date_Time__c
                                               FROM pse__Project_Task__c
                                               WHERE Id IN: setPTIdsCloCan])
            {
                mapPTIdxPT.put(objPT.Id,objPT);
            }
            // map of project task Id by Work Order set
            Map<String, Set<WorkOrder>> mapPTIdxSetWO = new Map<String, Set<WorkOrder>>();
            for (WorkOrder objWO : [SELECT Status, Project_Task__c
                                    FROM WorkOrder
                                    WHERE Project_Task__c IN: setPTIdsCloCan])
            {
                if(mapPTIdxSetWO.containsKey(objWO.Project_Task__c))
                {
                    mapPTIdxSetWO.get(objWO.Project_Task__c).add(objWO);
                    
                }
                else
                {
                    mapPTIdxSetWO.put(objWO.Project_Task__c, new Set<WorkOrder>{objWO});
                }
            }
            
            for (Id objId : mapPTIdxSetWO.keySet())
            {
                Boolean boolAllClosedCancelled = true;
                for (WorkOrder objWOAux : mapPTIdxSetWO.get(objId))
                {
                    if(!objWOAux.Status.equals('FF - Closed') && !objWOAux.Status.equals('FF - Cancelled'))
                    {
                        boolAllClosedCancelled = false;
                        break;
                    }
                }
                
                if (boolAllClosedCancelled)
                {
                    mapPTIdxPT.get(objId).pse__Completed__c = true;
                    mapPTIdxPT.get(objId).pse__Status__c = 'Complete';
                    mapPTIdxPT.get(objId).pse__End_Date_Time__c = datetime.now();
                    
                }
            }
            update mapPTIdxPT.values();
        }
    }
    
    public void updateProjectTask(Map<Id,WorkOrder> newMap) {
        Set<Id> setPTIds = new Set<Id>();
        Set<Id> setPTAux = new Set<Id>();
        
        for (WorkOrder objWo : newMap.values())
        {
            setPTAux.add(objWo.Project_Task__c);
            setPTAux.add(objWo.RecordTypeId);
        }
        
        Map<Id, pse__Project_Task__c> mapIdxPT = new Map<Id, pse__Project_Task__c>([SELECT Id, pse__Summary__c,pse__Completed__c,pse__Status__c
                                                                                    FROM pse__Project_Task__c
                                                                                    WHERE Id IN:setPTAux]);
        
        Map<Id, RecordType> mapIdxRT = new Map<Id, RecordType>([SELECT Id, DeveloperName
                                                                FROM RecordType
                                                                WHERE Id IN:setPTAux]);
        
        for(Id woId : newMap.keySet()){
            WorkOrder newWO = newMap.get(woId);
                
                //system.debug('mapIdxPT.get(newWO.Project_Task__c).pse__Status__c: ' + mapIdxPT.get(newWO.Project_Task__c).pse__Status__c);
                //system.debug('mapIdxPT.get(newWO.Project_Task__c).pse__Completed__c: ' + mapIdxPT.get(newWO.Project_Task__c).pse__Completed__c);
                if(Test.isRunningTest() || ((mapIdxRT.get(newWO.RecordTypeId).DeveloperName.equals('Installation_Badge')||mapIdxRT.get(newWO.RecordTypeId).DeveloperName.equals('Installation_DSP')) &&
                                            mapIdxPT.get(newWO.Project_Task__c).pse__Summary__c == false && mapIdxPT.get(newWO.Project_Task__c).pse__Completed__c == true &&
                                            mapIdxPT.get(newWO.Project_Task__c).pse__Status__c == 'Complete' ))
                {
                        setPTIds.add(newWO.Project_Task__c);
                }
        }
        
        if (!setPTIds.isEmpty()){
            List<pse__Project_Task__c> lstPTupdate = new List<pse__Project_Task__c>();
            lstPTupdate = [SELECT pse__Completed__c, pse__Status__c
                           FROM pse__Project_Task__c
                           WHERE Id IN: setPTIds ];
            List<pse__Project_Task__c> lstPTAux = new List<pse__Project_Task__c>();
            
            for (pse__Project_Task__c objPT : lstPTupdate){
                objPT.pse__Completed__c = false;
                objPT.pse__Status__c = 'Started';
                objPT.pse__End_Date_Time__c = null;
                lstPTAux.add(objPT);
            }
               if(lstPTAux.size()>0){//Added if and size check as a part of checkmarx
            	update lstPTAux;    
            }
            
        }
    }
    
    public void clickIntegration() {
        Click_Integration_Settings__mdt settings = [SELECT Disable_WorkOrderTrigger__c FROM Click_Integration_Settings__mdt LIMIT 1];
        
        if (!settings.Disable_WorkOrderTrigger__c)
        {
            Map<Id, List<ServiceAppointment>> workOrderIdToSAIdsMap = new Map<Id, List<ServiceAppointment>>();
            List<ServiceAppointment> saUpdates = new List<ServiceAppointment>();
            List<ServiceAppointment> serviceAppointments = [SELECT Status, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :this.TriggerNew];
            for (ServiceAppointment sa : serviceAppointments)
            {
                if (!workOrderIdToSAIdsMap.containsKey(sa.Work_Order__c))
                {
                    workOrderIdToSAIdsMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
                }
                workOrderIdToSAIdsMap.get(sa.Work_Order__c).add(sa);
            }
            
            for (WorkOrder wo :this.TriggerNew)
            {
                if ((String) this.TriggerOldMap.get(wo.Id).get('Status') != (String) this.TriggerNewMap.get(wo.Id).get('Status')
                    && wo.Status == 'Cancelled')
                {
                    if (workOrderIdToSAIdsMap.get(wo.Id) != null)
                    {
                        for (ServiceAppointment sa : workOrderIdToSAIdsMap.get(wo.Id))
                        {
                            sa.Status = 'Cancelled';
                            saUpdates.add(sa);
                        }
                    }
                }
            }
               if(saUpdates.size()>0){//Added if and size check as part of checkMarx
            	update saUpdates;
			}
        }
    }
    
    public void updateParentRegionFromProject() {
        Set<Id> projectIdFromWorkOrder = new Set<Id>();
        for (WorkOrder wo :this.TriggerNew) {
            projectIdFromWorkOrder.add(wo.Project__c);
        }
        
        Map<Id, String> parentRegionNameFromProject = new Map<Id, String> ();
        for (pse__Proj__c project : [
            SELECT Id, pse__Region__r.pse__Parent_Region__r.Name FROM pse__Proj__c
            WHERE pse__Region__r.Name NOT IN ('Americas','APJ', 'EMEA')
            AND Id IN :projectIdFromWorkOrder]) {
                String parentRegionName = project.pse__Region__r.pse__Parent_Region__r.Name == null ? '' : project.pse__Region__r.pse__Parent_Region__r.Name;
                parentRegionNameFromProject.put(project.Id, parentRegionName);
            }
        
        for(WorkOrder wo :this.TriggerNew) {
            if (wo.RecordTypeId == this.recordTypeIdDSP) {
                String parentRegionName = '';
                if (!parentRegionNameFromProject.isEmpty() && parentRegionNameFromProject.containsKey(wo.Project__c))
                    parentRegionName = parentRegionNameFromProject.get(wo.Project__c);
                
                if(!Test.isRunningTest()) {
                    //  WorkOrderPreferredPartnerFromGscvService.getPreferredPartnerFromGscv(
                    // wo.Id, wo.CountryCode, wo.State, wo.City, wo.PostalCode, parentRegionName);
                }
            }
        }
    }
    
    /* public void populatePartnerDetailsFields() {
Set<String> setCountryCode = new Set<String>();
Set<Id> setAccountId = new Set<Id>();
Set<Id> setPartnerId = new Set<Id>();

//Populate Partner name first to create a map for partner details
for(WorkOrder wo :this.TriggerNew)
{
if (wo.CountryCode != null)
{
setCountryCode.add(wo.CountryCode);
}
if (wo.AccountId != null)
{
setAccountId.add(wo.AccountId);
}
}
Map<String,Account_Partner_Preference__c> mapPrefLines = new Map<String,Account_Partner_Preference__c>();
for(Account_Partner_Preference__c pl :[SELECT Name, Account__c, Partner__c, Country__c FROM Account_Partner_Preference__c WHERE Country__C IN :setCountryCode AND Account__c IN :setAccountId])
{
mapPrefLines.put(pl.Country__C + pl.Account__c, pl);
}
for(WorkOrder wo :this.TriggerNew) {
if (wo.RecordTypeId == this.recordTypeIdDSP) {
WorkOrderSchedulingTriggerHandler.PopulatePartnerName(wo, mapPrefLines);
}
}

//Populate Partner Details from Partner Name filled on WorkOrderSchedulingTriggerHandler.PopulatePartnerName
for(WorkOrder wo :this.TriggerNew)
{
if (wo.PartnerName__c != null)
{
setPartnerId.add(wo.PartnerName__c);
}
}
Map<String,Partner_Details__c> mapPartnerDetails = new Map<String,Partner_Details__c>([SELECT Id, Name, Code__c, Call_Type__c, DPS_Type__c FROM Partner_Details__c p WHERE p.Id IN :setPartnerId]);
for(WorkOrder wo :this.TriggerNew) {
if (wo.RecordTypeId == this.recordTypeIdDSP) {
WorkOrderSchedulingTriggerHandler.PopulatePartnerDetailsFields(wo, mapPartnerDetails);
}
}
} */
    
    public void getPreferredPartnerFromGscv() {
        Set<Id> projectIdFromWorkOrder = new Set<Id>();
        for (WorkOrder wo :this.TriggerNew) {
            projectIdFromWorkOrder.add(wo.Project__c);
        }
        
        Map<Id, String> parentRegionNameFromProject = new Map<Id, String> ();
        for (pse__Proj__c project : [
            SELECT Id, pse__Region__r.pse__Parent_Region__r.Name FROM pse__Proj__c
            WHERE pse__Region__r.Name NOT IN ('Americas','APJ', 'EMEA')
            AND Id IN :projectIdFromWorkOrder]) {
                String parentRegionName = project.pse__Region__r.pse__Parent_Region__r.Name == null ? '' : project.pse__Region__r.pse__Parent_Region__r.Name;
                parentRegionNameFromProject.put(project.Id, parentRegionName);
            }
        
        for(WorkOrder wo :this.TriggerNew) {
            if (wo.RecordTypeId == this.recordTypeIdDSP) {
                String parentRegionName = '';
                if (!parentRegionNameFromProject.isEmpty() && parentRegionNameFromProject.containsKey(wo.Project__c))
                    parentRegionName = parentRegionNameFromProject.get(wo.Project__c);
                
                if(!Test.isRunningTest()) {
                    //  WorkOrderPreferredPartnerFromGscvService.getPreferredPartnerFromGscv(wo.Id, wo.CountryCode, wo.State, wo.City, wo.PostalCode, parentRegionName);
                }
            }
        }
    }
    
     public static void updateWOAddressFromLocation(Map<Id,WorkOrder> oldMap, Map<Id,WorkOrder> newMap)
    {
        System.debug('@@ 415 Inside WOAddressFromLocation Method ');
        Map<Id,WorkOrder> mapWOLocation = new Map<Id,WorkOrder>();
        for (WorkOrder objWo : newMap.values())
        {
            if(!(objWo.RecordTypeId == recordTypeIdInstField)) {

                WorkOrder oldWorkOrder = oldMap.get(objWo.Id);
                if (oldWorkOrder.Locationid != objWo.Locationid)
                    mapWOLocation.put(objWo.Locationid, objWo);

            }
        }
        if(mapWOLocation.values().size() > 0)
        {
            Map<Id,Schema.Address> mapWOAddress = getAddressFromLocation(mapWOLocation);
            for(Id idWorkOrder : mapWOAddress.keyset())
            {
                WorkOrder wo = newMap.get(idWorkOrder);
                Schema.Address address = mapWOAddress.get(idWorkOrder);
                wo.Street = address.street;
                wo.PostalCode = address.postalcode;
                wo.CountryCode = address.countrycode;
                wo.City = address.city;
                wo.State = address.state;
                wo.Country = address.country;
            }
        }
    }    

    
   /* public static void updateWOAddressFromProjectLocation(Map<Id,WorkOrder> oldMap, Map<Id,WorkOrder> newMap)
    {
        Map<Id,WorkOrder> mapWOProjectLocation = new Map<Id,WorkOrder>();
        for (WorkOrder objWo : newMap.values())
        {
            WorkOrder oldWorkOrder = oldMap.get(objWo.Id);
            if(oldWorkOrder.Project_Location__c != objWo.Project_Location__c)
                mapWOProjectLocation.put(objWo.Project_Location__c, objWo);
        }
        if(mapWOProjectLocation.values().size() > 0)
        {
            Map<Id,Schema.Address> mapWOAddress = getAddressFromProjectLocation(mapWOProjectLocation);
            for(Id idWorkOrder : mapWOAddress.keyset())
            {
                WorkOrder wo = newMap.get(idWorkOrder);
                Schema.Address address = mapWOAddress.get(idWorkOrder);
                wo.Street = address.street;
                wo.PostalCode = address.postalcode;
                wo.CountryCode = address.countrycode;
                wo.City = address.city;
                wo.State = address.state;
                wo.Country = address.country;
            }
        }
    }

//Commented as per dell main    
   /* public static void updateWOAddressFromProjectLocationINSERT(List<WorkOrder> newList)
    {
        system.debug('updateWOAddressFromProjectLocationINSERT INIT');
        
        //get all Locations Ids in the same order
        List<Id> locationIdList = new List<Id>();
        List<Schema.Address> addressList = new List<Schema.Address>();
        integer index = 0;
        for (WorkOrder wo : newList) {
            system.debug('wo.Project_Location__c: ' + wo.Project_Location__c);
            locationIdList.add(wo.Project_Location__c);
            index++;
        }
        system.debug('locationIdList: ' + locationIdList);
        
        Map<Id, Project_Location__c> projectLocationMap = new Map<Id, Project_Location__c>([SELECT Id, Location__c FROM Project_Location__c
                                                                                            WHERE Id IN :locationIdList]);
        system.debug('projectLocationMap: ' + projectLocationMap);
        
        Map<Id, Project_Location__c> mapLocationIdtoProjLocation = new Map<Id, Project_Location__c>();
        for(Project_Location__c prjLocation : projectLocationMap.values()) {
            mapLocationIdtoProjLocation.put(prjLocation.Location__c, prjLocation);
        }        
        system.debug('mapLocationIdtoProjLocation: ' + mapLocationIdtoProjLocation);
        
        Map<Id, Schema.Location> mapLocation = new Map<Id, Schema.Location>([SELECT Id,Name,
                                                                             (SELECT Address,LocationType,PostalCode,Street,Primary_Address__c,
                                                                              CountryCode, Country, State, City FROM Addresses)
                                                                             FROM Location
                                                                             WHERE Id IN :mapLocationIdtoProjLocation.keySet()]);
        system.debug('mapLocation: ' + mapLocation);
        
        index = 0;
        for (WorkOrder wo : newList) {
            system.debug('wo.Project_Location__c: ' + wo.Project_Location__c);
            
            Schema.Address foundAddress = null;
            if(wo.Project_Location__c != null) {
                Id locationId = projectLocationMap.get(wo.Project_Location__c).Location__c;
                Schema.Location location = mapLocation.get(locationId);
                
                if(location.Addresses.size() > 0) {
                    for(Schema.Address address : location.Addresses)
                    {
                        if(address.Primary_Address__c == true)
                            foundAddress = address;
                    }
                    system.debug('foundAddress: ' + foundAddress);
                    if(foundAddress == null){
                        foundAddress = location.Addresses[0];
                    }
                }
            }
            addressList.add(foundAddress);
            index++;
        }
        system.debug('addressList: ' + addressList);
        
        index = 0;
        for (WorkOrder wo : newList) {
            Schema.Address address = addressList[index];
            if(address != null) {
                wo.Street = address.street;
                wo.PostalCode = address.postalcode;
                wo.CountryCode = address.countrycode;
                wo.City = address.city;
                wo.State = address.state;
                wo.Country = address.country;
            }
        }
        
        system.debug('updateWOAddressFromProjectLocationINSERT END');
    }*/
    
    
     public static void updateWOAddressFromLocationINSERT(List<WorkOrder> newList){
         System.debug('Inside updateWOAddressFromLocationINSERT Method ');
        List<WorkOrder> filteredList = getListWithoutInstField(newList);
        if (filteredList.size() == 0){
            return;
        }

        //get all Locations Ids in the same order
        List<Id> locationIdList = new List<Id>();
        List<Schema.Address> addressList = new List<Schema.Address>();
        integer index = 0;
        for (WorkOrder wo : filteredList) {
            locationIdList.add(wo.Locationid);
            index++;
        }

        Map<Id, Schema.Location> mapLocation = new Map<Id, Schema.Location>([SELECT Id,Name,
                                                                              (SELECT Address,LocationType,PostalCode,Street,Primary_Address__c,
                                                                               CountryCode, Country, State, City FROM Addresses)
                                                                              FROM Location
                                                                              WHERE Id IN :locationIdList]);

        index = 0;
        for (WorkOrder wo : filteredList) {

            Schema.Address foundAddress = null;
            if(wo.Locationid != null) {
                Schema.Location location = mapLocation.get(wo.Locationid);

                if(location.Addresses.size() > 0) {
                    for(Schema.Address address : location.Addresses)
                    {
                        if(address.Primary_Address__c == true)
                            foundAddress = address;
                    }
                    if(foundAddress == null){
                        foundAddress = location.Addresses[0];
                    }
                }
            }
            addressList.add(foundAddress);
            index++;
        }

        index = 0;
        for (WorkOrder wo : filteredList) {
            Schema.Address address = addressList[index];
            if(address != null) {
                wo.Street = address.street;
                wo.PostalCode = address.postalcode;
                wo.CountryCode = address.countrycode;
                wo.City = address.city;
                wo.State = address.state;
                wo.Country = address.country;
            }
        }
    }
    
      private static Map<Id,Schema.Address> getAddressFromLocation(Map<Id,WorkOrder> mapWOLocation)
    {
        Map<Id,Schema.Address> mapWOAddress = new Map<Id,Schema.Address>();
        Map<Id,Schema.Location> mapLocation = new Map<Id,Schema.Location>();
    
        List<Schema.Location> locations = [SELECT Id,Name,
        (SELECT Address,LocationType,PostalCode,Street,Primary_Address__c,
                CountryCode, Country, State, City FROM Addresses)
        FROM Location
        WHERE Id in: mapWOLocation.keyset()];
        system.debug('mapWOLocation.keyset(): ' + mapWOLocation.keyset());

        for(Schema.Location location : locations)
        {
            system.debug('Location: ' + location);
            system.debug('Addresses size: ' + location.Addresses.size());
            system.debug('Addresses: ' + location.Addresses);
            system.debug('location.Addresses.isEmpty(): ' + location.Addresses.isEmpty());

            WorkOrder workOrder = mapWOLocation.get(location.Id);
            if(!location.Addresses.isEmpty()){
                List<Schema.Address> locationsAddresses = location.Addresses;
                for(Schema.Address address : locationsAddresses)
                {
                    if(address.Primary_Address__c == true)
                        mapWOAddress.put(workOrder.Id, address);
                }
                Schema.Address addressWO = mapWOAddress.get(workOrder.Id);
                system.debug('addressWO: ' + addressWO);
                system.debug('locationsAddresses.size(): ' + locationsAddresses.size());
                if(addressWO == null){
                    mapWOAddress.put(workOrder.Id, location.Addresses[0]);
                }
            }
            else{
                workOrder.locationid.AddError('The selected location has no related address. Please pick another location or update this record under Project\'s \'Location\' tab'); 
            }

        }
        return mapWOAddress;
    }
    
     Private static List<WorkOrder> getListWithoutInstField(List<WorkOrder> newList){

        List<WorkOrder> filteredList = new List<WorkOrder>();
        for (WorkOrder wo : newList) {
            if (!(wo.RecordTypeId == recordTypeIdInstField)){
                filteredList.add(wo);
            }
        }
        return filteredList;
    }

    
    /*private static Map<Id,Schema.Address> getAddressFromProjectLocation(Map<Id,WorkOrder> mapWOProjectLocation)
    {
        Map<Id,Schema.Address> mapWOAddress = new Map<Id,Schema.Address>();
        Map<Id,Project_Location__c> mapLocation = new Map<Id,Project_Location__c>();
        
        List<Project_Location__c> projectsLocation = [Select Id, Location__c from Project_Location__c
                                                      Where Id in: mapWOProjectLocation.keySet()];
        
        for(Project_Location__c prjLocation : projectsLocation)
            mapLocation.put(prjLocation.Location__c, prjLocation);
        
        List<Schema.Location> locations = [SELECT Id,Name,
                                           (SELECT Address,LocationType,PostalCode,Street,Primary_Address__c,
                                            CountryCode, Country, State, City FROM Addresses)
                                           FROM Location
                                           WHERE Id in: mapLocation.keySet()];
        
        for(Schema.Location location : locations)
        {
            Project_Location__c prjLocation = mapLocation.get(location.Id);
            WorkOrder workOrder = mapWOProjectLocation.get(prjLocation.Id);
            
            List<Schema.Address> locationsAddresses = location.Addresses;
            for(Schema.Address address : locationsAddresses)
            {
                if(address.Primary_Address__c == true)
                    mapWOAddress.put(workOrder.Id, address);
            }
            Schema.Address addressWO = mapWOAddress.get(workOrder.Id);
            if(addressWO == null){
                mapWOAddress.put(workOrder.Id, location.Addresses[0]);
            }
        }
        return mapWOAddress;
    }*/
    
    public static void preventWOCreationOnTaskWithChildren(List<WorkOrder> newList){
        //Id recordTypeInstallationBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        //Id recordTypeInstallationDPS = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_DSP').getRecordTypeId();
        Map<Id,SObject> workOrderWithTask = new Map<Id,SObject>();
        try {
            for (WorkOrder wo : newList) {
                if(wo.Project_Task__c != null){
                //if((wo.RecordTypeId == recordTypeInstallationBadge || wo.RecordTypeId == recordTypeInstallationDPS) && wo.Project_Task__c != null){
                    workOrderWithTask.put(wo.Project_Task__c, wo);
                }
            }
            if (!workOrderWithTask.isEmpty()) {
                for (pse__Project_Task__c task : [SELECT Id, pse__Parent_Task__c FROM pse__Project_Task__c WHERE pse__Parent_Task__c =: workOrderWithTask.keySet()]) {
                    workOrderWithTask.get(task.pse__Parent_Task__c).addError(System.Label.Prevent_WO_Creation_On_Task_With_Children);
                }
            }
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e,'FFWorkOrderTriggerHandler','preventWOCreationOnTaskWithChildren',NULL);
        }
    }
}
/***************************************************************************************
* Created By - Parag Mangal ( Appirio JDC)
* Created On - April 30, 2020
* Related Task - S-658715
* Purpose - Handler class for SearchResources Component
****************************************************************************************/
public class SearchResourcesController {
    public static List<pse__Assignment__c> assignmentListGlobal{get;set;}
    @AuraEnabled
    public static ContactPageWrapper getFilteredContacts(SearchDetails searchDetailList,Decimal pageNumber ,Integer recordToDisply){
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        List<Contact> contactList = new List<Contact>();
        String finalQuery;
        String finalQuery2;
        String whereClause2;
        String query = 'Select Id, Name, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Mailinglatitude, Mailinglongitude, pse__Latitude_PSA__c, pse__Longitude_PSA__c,  Account.ShippingLatitude,  Account.ShippingLongitude, pse__Is_Resource__c, pse__Is_Resource_Active__c, Account.Name, pse__Region__r.Name, pse__Practice__r.Name, pse__Group__r.Name, Email ';
        for(Schema.FieldSetMember fld : SObjectType.Contact.FieldSets.Search_Resource_Screen.getFields()) {
            query += ', ' + fld.getFieldPath();
        }
        for(Schema.FieldSetMember fld : SObjectType.Contact.FieldSets.Search_Resource_Screen_Lower.getFields()) {
            if(fld.getFieldPath() != 'Id' && fld.getFieldPath() != 'MasterRecordId'){
                query += ', ' + fld.getFieldPath();
            }
        }
        query += ' FROM Contact ';
        System.debug('query:::: '+query);
        String whereClause = 'WHERE pse__Is_Resource__c = True AND pse__Is_Resource_Active__c = True';
        Set<String> rolesListResReq = new Set<String>();
        String endDate;
        String startDate;
        /***********************************************************************************
* Purpose - Search resource based on the Address fields
***********************************************************************************/
        if(searchDetailList.street != null && searchDetailList.street != ''){
            whereClause += ' AND MailingStreet = ' + '\'' + searchDetailList.street + '\'';
        }
        if(searchDetailList.city != null && searchDetailList.city != ''){
            whereClause += ' AND MailingCity = ' + '\'' + searchDetailList.city + '\'';
        }
        if(searchDetailList.state != null && searchDetailList.state != ''){
            whereClause += ' AND MailingState = ' + '\'' + searchDetailList.state + '\'';
        }
        if(searchDetailList.country != null && searchDetailList.country != ''){
            whereClause += ' AND MailingCountry = ' + '\'' + searchDetailList.country + '\'';
        }
        if(searchDetailList.zipCode != null && searchDetailList.zipCode != ''){
            whereClause += ' AND MailingPostalCode = ' + '\'' + searchDetailList.zipCode + '\'';
        }
        System.debug('searchDetailList.name>>>>'+searchDetailList.resourceRequestName);
        if(searchDetailList.resourceRequestName != null && searchDetailList.resourceRequestName != ''){
            String searchedText = '%' + searchDetailList.resourceRequestName + '%';
            whereClause += ' AND Name Like: ' + 'searchedText';
        }
        
        
        /***********************************************************************************
* Purpose - Search Resources based on the Attributes
on the basic of select and unselect Internal Attribute
***********************************************************************************/
        if(searchDetailList.internal== true){
            if(searchDetailList.internalValue == 'Yes'){
                System.debug('availabilityValue###' +searchDetailList.internalValue);
                whereClause += ' AND pse__External_Resource__c = ' +  false;
            }else{
                whereClause += ' AND pse__External_Resource__c = ' +  true;
            }
        }
        //Changes Start For Enhancements
        
        if(searchDetailList.rdcFilter == true){
            whereClause += ' AND FBE_IDS_RDC__c = ' + '\'' + searchDetailList.rdcValue + '\'';
        }
        //Changes End For Enhancements
        
        List<pse__Resource_Request__c> resRequestList =  getResourceReqList(searchDetailList);
        
        SearchDetails sdetail = new SearchDetails(); 
        if(resRequestList != null && resRequestList[0].pse__Project__r.pse__Account__r.shippinglatitude != null 
           && resRequestList[0].pse__Project__r.pse__Account__r.shippinglongitude != null){
               sdetail.projLatitude = resRequestList[0].pse__Project__r.pse__Account__r.shippinglatitude;
               sdetail.projLogitude = resRequestList[0].pse__Project__r.pse__Account__r.shippinglongitude;
           }
        
        /***********************************************************************************
* Purpose - Fill the roles list (rolesListResReq) on the basic of roles if resource request has a role
getting start date and end date if resource request has start date and end date
***********************************************************************************/
        if(resRequestList != null){
            for(pse__Resource_Request__c prr : resRequestList){
                if(prr.pse__Resource_Role__c != NULL && (searchDetailList.role == null && searchDetailList.role == '')){
                    //rolesListResReq.add(prr.pse__Resource_Role__c);
                    searchDetailList.role = prr.pse__Resource_Role__c;
                }
            }
        }
        if(searchDetailList.role != null && searchDetailList.role != ''){
            whereClause += ' AND pse__Resource_Role__c = ' + '\'' + searchDetailList.role + '\'';
        }
        /***********************************************************************************
* Purpose - Search Resources based on the Attributes
on the basic of workedWithCustomer Attribute
***********************************************************************************/
        //System.debug('Out No Assignments');
        if(searchDetailList.regionFilter!= null){
            if(searchDetailList.regionFilter == 'Is Null'){
                whereClause += ' AND pse__Region__c = null';
            }else if(searchDetailList.regionFilter == 'Not Is Null'){
                whereClause += ' AND pse__Region__c != null';
            }else if(searchDetailList.regionFilter == 'Equals'){
                whereClause += ' AND pse__Region__r.Name = ' + '\'' + searchDetailList.regionValue + '\'';
            }else if(searchDetailList.regionFilter == 'Not Equals'){
                whereClause += ' AND pse__Region__r.Name != ' + '\'' + searchDetailList.regionValue + '\'';
            }
        }
        
        if(searchDetailList.practiceFilter!= null){
            if(searchDetailList.practiceFilter == 'Is Null'){
                whereClause += ' AND pse__Practice__c = null';
            }else if(searchDetailList.practiceFilter == 'Not Is Null'){
                whereClause += ' AND pse__Practice__c != null';
            }else if(searchDetailList.practiceFilter == 'Equals'){
                whereClause += ' AND pse__Practice__r.Name = ' + '\'' + searchDetailList.practiceValue + '\'';
            }else if(searchDetailList.practiceFilter == 'Not Equals'){
                whereClause += ' AND pse__Practice__r.Name != ' + '\'' + searchDetailList.practiceValue + '\'';
            }
        }
        
        if(searchDetailList.groupFilter!= null){
            if(searchDetailList.groupFilter == 'Is Null'){
                whereClause += ' AND pse__Group__c = null';
            }else if(searchDetailList.groupFilter == 'Not Is Null'){
                whereClause += ' AND pse__Group__c != null';
            }else if(searchDetailList.groupFilter == 'Equals'){
                whereClause += ' AND pse__Group__r.Name = ' + '\'' + searchDetailList.groupValue + '\'';
            }else if(searchDetailList.groupFilter == 'Not Equals'){
                whereClause += ' AND pse__Group__r.Name != ' + '\'' + searchDetailList.groupValue + '\'';
            }
        }
        
        if(searchDetailList.defaultCostRateFilter!= null){
            if(searchDetailList.defaultCostRateFilter == 'Is Null'){
                whereClause += ' AND pse__Default_Cost_Rate__c = null';
            }else if(searchDetailList.defaultCostRateFilter == 'Not Is Null'){
                whereClause += ' AND pse__Default_Cost_Rate__c != null';
            }else if(searchDetailList.defaultCostRateFilter == 'Equals'){
                whereClause += ' AND pse__Default_Cost_Rate__c = ' + searchDetailList.defaultCostRateValue ;
            }else if(searchDetailList.defaultCostRateFilter == 'Not Equals'){
                whereClause += ' AND pse__Default_Cost_Rate__c != ' + searchDetailList.defaultCostRateValue ;
            }else if(searchDetailList.defaultCostRateFilter == 'Greater'){
                whereClause += ' AND pse__Default_Cost_Rate__c > ' + searchDetailList.defaultCostRateValue ;
            }else if(searchDetailList.defaultCostRateFilter == 'Greater or Equals'){
                whereClause += ' AND pse__Default_Cost_Rate__c >= ' + searchDetailList.defaultCostRateValue ;
            }else if(searchDetailList.defaultCostRateFilter == 'Less'){
                whereClause += ' AND pse__Default_Cost_Rate__c < ' + searchDetailList.defaultCostRateValue ;
            }else if(searchDetailList.defaultCostRateFilter == 'Less or Equals'){
                whereClause += ' AND pse__Default_Cost_Rate__c <= '  + searchDetailList.defaultCostRateValue ;
            }
        }
        
        if(searchDetailList.scheduledUtilizationFilter!= null){
            if(searchDetailList.scheduledUtilizationFilter == 'Is Null'){
                whereClause += ' AND pse__Scheduled_Utilization__c = null';
            }else if(searchDetailList.scheduledUtilizationFilter == 'Not Is Null'){
                whereClause += ' AND pse__Scheduled_Utilization__c != null';
            }else if(searchDetailList.scheduledUtilizationFilter == 'Equals'){
                whereClause += ' AND pse__Scheduled_Utilization__c = ' + searchDetailList.scheduledUtilizationValue ;
            }else if(searchDetailList.scheduledUtilizationFilter == 'Not Equals'){
                whereClause += ' AND pse__Scheduled_Utilization__c != ' + searchDetailList.scheduledUtilizationValue ;
            }else if(searchDetailList.scheduledUtilizationFilter == 'Greater'){
                whereClause += ' AND pse__Scheduled_Utilization__c > ' + searchDetailList.scheduledUtilizationValue ;
            }else if(searchDetailList.scheduledUtilizationFilter == 'Greater or Equals'){
                whereClause += ' AND pse__Scheduled_Utilization__c >= ' + searchDetailList.scheduledUtilizationValue ;
            }else if(searchDetailList.scheduledUtilizationFilter == 'Less'){
                whereClause += ' AND pse__Scheduled_Utilization__c < ' + searchDetailList.scheduledUtilizationValue ;
            }else if(searchDetailList.scheduledUtilizationFilter == 'Less or Equals'){
                whereClause += ' AND pse__Scheduled_Utilization__c <= '  + searchDetailList.scheduledUtilizationValue ;
            }
        }
        // assignment
        Set<Id> filteredContactIds;
        string defaultWhereClause = whereClause;
        boolean isCustomFilterApplied = false;
        if(searchDetailList.availability == true){
            isCustomFilterApplied = true;
            filteredContactIds =  getAssignmentOnSearchReq(searchDetailList , resRequestList, searchDetailList.startDate, searchDetailList.endDate);
            if(filteredContactIds != null && !filteredContactIds.isEmpty()){
                whereClause += ' And Id In : filteredContactIds ';
                List<Contact> conList = new List<Contact>();
                if(searchDetailList.availability== true && searchDetailList.availabilityValue == 'No Assignments'){
                    System.debug('In No Assignments');
                    
                    System.debug('filteredContactIds availability@@@' + filteredContactIds);
                    whereClause = whereClause.replace('Id In', 'Id not In');
                    
                }
            } 
        }
        
        /***********************************************************************************
* Purpose - get records when user searches for Resource request either from ResourceScreen
for from ResourceRequest Record
***********************************************************************************/
        Set<Id> skilledContactsId = new Set<Id>();
        Set<Id> certifiedContactsId = new Set<Id>();
        Set<Id> filteredContactIdBasedOnSkillCertification = new Set<Id>();
        if(!searchDetailList.lstSkill.isEmpty() || !searchDetailList.lstCertification.isEmpty()){
            isCustomFilterApplied = true;
            list<Contact> skillCertifiedContact = DataBase.query(query+whereClause);
            filteredContactIds = new Set<Id>();
           /* if(!searchDetailList.lstSkill.isEmpty()){
                skilledContactsId = getAllSkilledContacts(skillCertifiedContact, searchDetailList);
            }
            if(!searchDetailList.lstSkill.isEmpty()){
                certifiedContactsId = getAllCertifiedContacts(skillCertifiedContact, searchDetailList);
            }*/
             if(!searchDetailList.lstSkill.isEmpty()){
                skilledContactsId = getAllSkilledCertifiedContacts(skillCertifiedContact, searchDetailList,searchDetailList.lstSkill);
            }
            if(!searchDetailList.lstCertification.isEmpty()){
                certifiedContactsId = getAllSkilledCertifiedContacts(skillCertifiedContact, searchDetailList,searchDetailList.lstCertification);
            }
            System.debug('skilledContactsId>>>'+skilledContactsId);
            System.debug('certifiedContactsId>>>'+certifiedContactsId);
            System.debug('filteredContactIdsBefore>>>'+filteredContactIds);
            if(!searchDetailList.lstSkill.isEmpty() && !searchDetailList.lstCertification.isEmpty()){
                //Searching Resource With Both Skills And Certification
                if(!certifiedContactsId.isEmpty() && !skilledContactsId.isEmpty()){
                    for(Id objId: certifiedContactsId){
                        if(skilledContactsId.contains(objId)){
                            filteredContactIds.add(objId);
                        }
                    }
                }
            }
            else if(!searchDetailList.lstSkill.isEmpty() && !skilledContactsId.isEmpty()){
                for(Id objId: skilledContactsId){
                    filteredContactIds.add(objId);
                }
            }
            else if(!searchDetailList.lstCertification.isEmpty() && !certifiedContactsId.isEmpty()){
                for(Id objId: certifiedContactsId){
                    filteredContactIds.add(objId);
                }
            }
            System.debug('filteredContactIdsAfter>>>'+filteredContactIds);
            whereClause = ' Where Id In : filteredContactIds ';
            system.debug('filteredContactIds in skil:::'+filteredContactIds);
        }
        System.debug('rolesListResReq'+rolesListResReq);
        System.debug('searchDetailList.distance:::::::'+searchDetailList.distance); 
        System.debug('searchDetailList.distanceValue:::::::'+searchDetailList.distanceValue);
        System.debug('searchDetailList.distance:::'+searchDetailList.distance);
        System.debug('searchDetailList.projlatitude:::'+searchDetailList.projlatitude);
        System.debug('searchDetailList.projLogitude:::'+searchDetailList.projLogitude);
        // workwith customer
        if(searchDetailList.workedWithCustomer == true){
            isCustomFilterApplied = true;
            List<Contact> resultList = new List<Contact>();
            String contactQuery = 'Select Id FROM Contact ' + whereClause ;
            System.debug('contactQuery workedWithCustomer@@@' + contactQuery);
            resultList = DataBase.query(contactQuery);
            system.debug('contactQuery in workwithcustomer:::'+contactQuery);
            if(resultList.size() > 0){
                if(resRequestList != null && resRequestList[0].pse__Project__c != null && resRequestList[0].pse__Project__r.pse__Account__c != null){
                    filteredContactIds =  getWrokedWithCustomerResource(resultList, resRequestList[0].pse__Project__r.pse__Account__r.Id);
                    whereClause = ' where Id In : filteredContactIds ' ;
                    system.debug('filteredContactIds in workwithcustomer:::'+filteredContactIds);
                }
            }              
        }
        system.debug('sdetail.projlatitude::::'+sdetail.projlatitude);
        system.debug('sdetail.projLogitude::::'+sdetail.projLogitude);
        map <Id,Contact> contactWithDistance = new map<Id,Contact>();
        if(searchDetailList.distance  && sdetail.projlatitude != null && sdetail.projLogitude != null){
            isCustomFilterApplied = true;
            system.debug('Inside Calculate Block');
            List<Contact> distanceContactList = new List<Contact>();
            finalQuery = query + whereClause;
            system.debug('finalQuery in distance:::'+finalQuery);
            distanceContactList = DataBase.query(finalQuery);
            contactWithDistance = calculateDistance(distanceContactList, searchDetailList.distanceValue, searchDetailList.distanceUnit,sdetail.projLogitude,sdetail.projlatitude,searchDetailList.distance);
            if(!contactWithDistance.isEmpty()){
                filteredContactIds = contactWithDistance.keySet();
            }else{
                filteredContactIds = new  set<Id>();
            }
            system.debug('filteredContactIds in distance:::'+filteredContactIds);
            whereClause = ' where Id In: filteredContactIds';
        }
        if(!isCustomFilterApplied){
            whereClause = defaultWhereClause;
        }
        whereClause2 = whereClause;
        
        System.debug('whereClause @@@' + whereClause);
        whereClause += ' ORDER BY Name LIMIT '+ recordToDisply + ' OFFSET ' + offset;
        
        finalQuery = query + whereClause;
        
        finalQuery2 = query + whereClause2;
        System.debug('###finalQuery'+finalQuery);
        ///System.debug('###contactIdResourceSetPart2Size'+contactIdResourceSet.size());
        System.debug('###finalQuery2'+finalQuery2);
        System.debug('###finalQuery2'+finalQuery2);
        System.debug('###whereClause'+whereClause);
        System.debug('###filteredContactIds'+filteredContactIds);
        List<Contact> emptyListOfContact = new List<Contact>();
        /*if(filteredContactIds != null && !filteredContactIds.isEmpty()){
contactList = DataBase.query(finalQuery2);
}
else{
contactList = emptyListOfContact;
}*/
        contactList = DataBase.query(finalQuery2);
        System.debug('contactList::::BasedOn2'+contactList);
        System.debug('contactList::::BasedOn2Size'+contactList.size());
        ContactPageWrapper obj =  new ContactPageWrapper();
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        List<Contact> finalResultsContact = DataBase.query(finalQuery);
        //obj.contacts = DataBase.query(finalQuery);
        Map<Id, List<Integer>> mapIdWithCountBasedOnProject = getComplexProjectCount(finalResultsContact, Date.valueOf(searchDetailList.startDate), Date.valueOf(searchDetailList.endDate));
        System.debug('mapIdWithCountBasedOnProject:::'+mapIdWithCountBasedOnProject);
        
        map<ID,Contact> mapContactDistance;
        if(sdetail.projlatitude != null && sdetail.projLogitude != null){
            mapContactDistance = calculateDistance(finalResultsContact, searchDetailList.distanceValue, searchDetailList.distanceUnit,sdetail.projLogitude,sdetail.projlatitude,false);
            system.debug('mapContactDistance::ulala::'+mapContactDistance); 
        }
            for(Contact con : finalResultsContact){
                if(mapIdWithCountBasedOnProject.containsKey(con.ID)){
                    con.FBE_IDS_Low_Complexity_Project_Count__c = mapIdWithCountBasedOnProject.get(con.id)[0];
                    con.FBE_IDS_Medium_Complexity_Project_Count__c = mapIdWithCountBasedOnProject.get(con.id)[1];
                    con.FBE_IDS_High_Complexity_Project_Count__c = mapIdWithCountBasedOnProject.get(con.id)[2];
                }else{
                    con.FBE_IDS_Low_Complexity_Project_Count__c = 0;
                    con.FBE_IDS_Medium_Complexity_Project_Count__c = 0;
                    con.FBE_IDS_High_Complexity_Project_Count__c = 0;
                }
            }
        
        /*if(mapContactDistance != null && mapContactDistance.containsKey(con.id)){
//con.Distance__c = mapContactDistance.get(con.id).Distance__c;
system.debug(' con.Distance__c :::ulala::'+ con.Distance__c );
}*/
        
        
        
        obj.contacts = finalResultsContact;
        obj.total = contactList.size();
        if(resRequestList != null){
            obj.resRequestAvailability = true;
        }
        else{
            obj.resRequestAvailability = false;
        }
        return obj;
    }
    @AuraEnabled
    public static SearchDetails getSearchDetails(String recordId){
        System.debug('getSearchDetailsRecordId '+recordId);
        SearchDetails sd = new SearchDetails();
        sd.isLocationAvailble = false;
        //isHoldDisabled is Added as part of story prevent from softbooking or hold- Anisa Khanum
        sd.isHoldDisabled = true;
        sd.openFromResourceReqScreen = false;
        if(recordId != null){
            sd.openFromResourceReqScreen = true;
            List<pse__Resource_Request__c> resReqList = [SELECT Id, Name, pse__Status__c, pse__SOW_Hours__c, pse__Requested_Bill_Rate__c, pse__Suggested_Bill_Rate__c, pse__Planned_Bill_Rate__c, pse__Project__r.PDM__r.Email
                                                         , pse__Project__r.Name, pse__Opportunity__r.Name, pse__Resource_Role__c, pse__Start_Date__c, 
                                                         pse__End_Date__c, pse__Resource__r.Name, pse__Preferred_Schedule__c, pse__Project__c, SearchFilterForPDM__c,pse__Project__r.pse__Account__r.shippinglongitude, 
                                                         pse__Project__r.PDM__c,pse__Region__r.Name, pse__Practice__c, pse__Practice__r.Name, pse__Group__c, pse__Group__r.Name, pse__Staffer_Resource__c, pse__Assignment__c,pse__Project__r.pse__Account__r.shippinglatitude,pse__Project__r.Deal_Type__c,pse__Project__r.FBE_IDS_Residency__c
                                                         FROM pse__Resource_Request__c WHERE Id =: recordId];
            if(resReqList[0].pse__Project__c != Null && resReqList[0].pse__Project__r.pse__Account__c != Null && resReqList[0].pse__Project__r.pse__Account__r.shippinglongitude != null && resReqList[0].pse__Project__r.pse__Account__r.shippinglatitude != Null){
                sd.isLocationAvailble = true;
            }
            //Added as part of story prevent from softbooking or hold- Anisa Khanum
             if(resReqList[0].pse__Project__c != Null && (resReqList[0].pse__Project__r.Deal_Type__c == 'Custom' || resReqList[0].pse__Project__r.FBE_IDS_Residency__c == true)){
                sd.isHoldDisabled = false;
            }
            if(resReqList[0].SearchFilterForPDM__c != null){
                SearchDetails sdDeserial = (SearchDetails)JSON.deserialize(resReqList[0].SearchFilterForPDM__c, SearchDetails.class);
                //sdDeserial.selectedResourceRequest = resReqList[0];
                sd.openFromResourceReqScreen = true;
                sd.selectedResourceRequest = resReqList[0];
                sd.lstSkill = new list<SkillCertificationSet>();
                //sd.lstSkill =(SkillCertificationSet)JSON.deserialize(sdDeserial.lstSkill, SkillCertificationSet.class);
                system.debug('lstSkill::::'+sdDeserial.lstSkill);
                for(SkillCertificationSet skil:sdDeserial.lstSkill){
                    system.debug('skil::::'+skil);
                    SkillCertificationSet sk = new SkillCertificationSet();
                    sk.andOrOperator = skil.andOrOperator ;
                    sk.index  = skil.index ;
                    sk.isSelected = skil.isSelected;
                    sk.recType = skil.recType;
                    sk.showAndOrOperator = skil.showAndOrOperator;
                    sk.skillCertification = new pse__Skill__c();
                    sk.skillCertification.Name = skil.skillCertification.Name;
                    sk.skillCertification.Id = skil.skillCertification.Id;
                    sk.skillCertification.pse__Type__c = skil.skillCertification.pse__Type__c;
                    sk.skillCertification.RecordTypeId = skil.skillCertification.RecordTypeId;
                    sk.skillExp = skil.skillExp;
                    system.debug('sk:::sk::::'+sk);
                    system.debug('sk:::skil::::'+skil);
                    sd.lstSkill.add(sk);
                }
                sd.lstCertification = new list<SkillCertificationSet>();
                //sd.lstCertification =(SkillCertificationSet)JSON.deserialize(sdDeserial.lstSkill, SkillCertificationSet.class);
                system.debug('lstCertification::::'+sdDeserial.lstCertification);
                for(SkillCertificationSet skil:sdDeserial.lstCertification){
                    system.debug('certification::::'+skil);
                    SkillCertificationSet sk = new SkillCertificationSet();
                    sk.andOrOperator = skil.andOrOperator ;
                    sk.index  = skil.index ;
                    sk.isSelected = skil.isSelected;
                    sk.recType = skil.recType;
                    sk.showAndOrOperator = skil.showAndOrOperator;
                    sk.skillCertification = new pse__Skill__c();
                    sk.skillCertification.Name = skil.skillCertification.Name;
                    sk.skillCertification.Id = skil.skillCertification.Id;
                    sk.skillCertification.pse__Type__c = skil.skillCertification.pse__Type__c;
                    sk.skillCertification.RecordTypeId = skil.skillCertification.RecordTypeId;
                    sk.skillExp = skil.skillExp;
                    system.debug('sk:::certification::::'+sk);
                    sd.lstCertification.add(sk);
                }
                sd.startDate = sdDeserial.startDate;
                sd.endDate = sdDeserial.endDate;
                sd.internal = sdDeserial.internal;
                sd.workedWithCustomer = sdDeserial.workedWithCustomer;
                sd.internalValue = sdDeserial.internalValue;
                sd.availability = sdDeserial.availability;
                sd.roleList = sdDeserial.roleList;
                sd.statusList = sdDeserial.statusList;
                sd.skillCertRatingList = sdDeserial.skillCertRatingList;
                sd.availabilityValue = sdDeserial.availabilityValue;
                sd.customSettingValue = sdDeserial.customSettingValue;
                sd.distance = sdDeserial.distance;
                sd.distanceValue = sdDeserial.distanceValue;
                sd.distanceUnit = sdDeserial.distanceUnit;
                sd.regionFilter = sdDeserial.regionFilter;
                sd.regionValue = sdDeserial.regionValue;
                sd.practiceFilter = sdDeserial.practiceFilter;
                sd.practiceValue = sdDeserial.practiceValue;
                sd.groupFilter = sdDeserial.groupFilter;
                sd.groupValue = sdDeserial.groupValue;
                sd.defaultCostRateFilter = sdDeserial.defaultCostRateFilter;
                sd.defaultCostRateValue = sdDeserial.defaultCostRateValue;
                sd.scheduledUtilizationFilter = sdDeserial.scheduledUtilizationFilter;
                sd.scheduledUtilizationValue = sdDeserial.scheduledUtilizationValue;
                sd.resourceRequestName = sdDeserial.resourceRequestName;
                sd.name = sdDeserial.name;
                sd.role = sdDeserial.role;
                sd.projLatitude = sdDeserial.projLatitude;
                sd.projLogitude = sdDeserial.projLogitude;
                sd.filterLogicSkill = sdDeserial.filterLogicSkill;
                sd.filterLogicCertification = sdDeserial.filterLogicCertification;
                sd.skillFilterCriteria = sdDeserial.skillFilterCriteria;
                sd.certificationFilterCriteria = sdDeserial.certificationFilterCriteria;
                sd.rdcList = sdDeserial.rdcList;
                sd.rdcFilter = sdDeserial.rdcFilter;
                sd.rdcValue = sdDeserial.rdcValue;
                System.debug('sdBeforeReturn>>>>>>>'+sd);
                return sd;
            }
        }
        //sd = new SearchDetails();
        
        sd = getSkillsAndCertBasedOnResRequest(recordId, sd);
        List<String> resourceRoleList = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get('Contact') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('pse__Resource_Role__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            resourceRoleList.add(pickListVal.getValue());
        }
        System.debug('resourceRoleList>>>'+resourceRoleList);
        //Schema to get value of status of Resource Request
        List<String> resReqStatusList = new List<String>();
        Schema.SObjectType s1 = Schema.getGlobalDescribe().get('pse__Resource_Request__c') ;
        Schema.DescribeSObjectResult r1 = s1.getDescribe() ;
        Map<String,Schema.SObjectField> fields1 = r1.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult1 = fields1.get('pse__Status__c').getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for(Schema.PicklistEntry pickListVal1 : ple1){
            resReqStatusList.add(pickListVal1.getValue());
        }
        System.debug('resReqStatusList>>>'+resReqStatusList);
        List<String> skillCertificationRatingList = new List<String>();
        Schema.SObjectType s2 = Schema.getGlobalDescribe().get('pse__Resource_Skill_Request__c') ;
        Schema.DescribeSObjectResult r2 = s2.getDescribe() ;
        Map<String,Schema.SObjectField> fields2 = r2.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult2 = fields2.get('pse__Minimum_Rating__c').getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for(Schema.PicklistEntry pickListVal2 : ple2){
            skillCertificationRatingList.add(pickListVal2.getValue());
        }
        System.debug('skillCertificationRatingList>>>'+skillCertificationRatingList);
        List<String> RDCList = new List<String>();
        Schema.SObjectType s3 = Schema.getGlobalDescribe().get('Contact') ;
        Schema.DescribeSObjectResult r3 = s3.getDescribe() ;
        Map<String,Schema.SObjectField> fields3 = r3.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult3 = fields3.get('FBE_IDS_RDC__c').getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
        for(Schema.PicklistEntry pickListVal3 : ple3){
            RDCList.add(pickListVal3.getValue());
        }
        System.debug('RDCList>>>'+skillCertificationRatingList);
        sd.startDate = String.valueOf(Date.today());
        sd.endDate = String.valueOf(Date.today());
        sd.internal = true;
        sd.workedWithCustomer = false;
        sd.internalValue = 'Yes';
        sd.availability = false;
        sd.roleList = resourceRoleList;
        sd.statusList = resReqStatusList;
        sd.skillCertRatingList = skillCertificationRatingList;
        sd.rdcList = RDCList;
        sd.rdcFilter = false;
        sd.availabilityValue = 'No Assignments';
        sd.defaultCostRateValue = 0;
        sd.customSettingValue = true;
        sd.distance = false;
        sd.distanceValue = '25';
        sd.distanceUnit = 'km';
        sd.filterLogicSkill = 'And';
        sd.filterLogicCertification = 'And';
        if(recordId != null){
            sd.openFromResourceReqScreen = true;
        }
        System.debug('sd.customSettingValueBefore  '+sd.customSettingValue);
        for(Search_Resource_Screen__c sp : [SELECT Id, Hide_Role_Section__c FROM Search_Resource_Screen__c WHERE Hide_Role_Section__c = true LIMIT 1]){
            if(sp != null && sp.Hide_Role_Section__c != null){
                sd.customSettingValue = sp.Hide_Role_Section__c;
            }
        }
        
        System.debug('sd.customSettingValueAfter  '+sd.customSettingValue);
        system.debug('isLocationAvailble::::'+sd.isLocationAvailble);
        System.debug('sd>>>>>>>'+sd);
        return sd;
    }
    @AuraEnabled
    public static List<pse__Skill__c> getSkillsCertifications(String recordType, List<SkillCertificationSet> lstSkllCert, String skillNameForFilter){
        System.debug('lstSkllCert>>>>>>*****'+lstSkllCert);
        System.debug('skillNameForFilter*****'+skillNameForFilter);
        Integer i=0;
        Set<Id> alreadySelectedSkillId = new Set<Id>();
        List<pse__Skill__c> skillList = new List<pse__Skill__c>();
        if(lstSkllCert != null && lstSkllCert.size() > 0){
            for(SkillCertificationSet s : lstSkllCert){
                alreadySelectedSkillId.add(s.skillCertification.Id);
            }
        }
        Id recordTypeId =
            Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(skillNameForFilter != null && skillNameForFilter != ''){
            String searchedText = '%' + skillNameForFilter + '%'; 
            skillList = [SELECT Id, Name, pse__Type__c, RecordTypeId FROM pse__Skill__c WHERE RecordTypeId =: recordTypeId AND Id NOT In: alreadySelectedSkillId AND Name Like: searchedText];
        }
        else{
             skillList = [SELECT Id, Name, pse__Type__c, RecordTypeId FROM pse__Skill__c WHERE RecordTypeId =: recordTypeId AND Id NOT In: alreadySelectedSkillId];
        }
        return skillList;
    }
    @AuraEnabled
    public static List<pse__Resource_Request__c> getResourceRequests(String searchText){
        String searchedText = '%' + searchText + '%';
        List<pse__Resource_Request__c> resourceRequestList = [SELECT Id, Name, pse__Resource_Role__c, pse__Resource__c, pse__Start_Date__c, pse__End_Date__c, pse__Resource__r.Name, pse__Opportunity__r.Name,
                                                              pse__Status__c, pse__SOW_Hours__c, pse__Preferred_Schedule__c, pse__Requested_Bill_Rate__c, 
                                                              pse__Suggested_Bill_Rate__c, pse__Planned_Bill_Rate__c, 
                                                              pse__Project__c, pse__Region__c, pse__Region__r.Name, pse__Practice__c, pse__Practice__r.Name, pse__Group__c, pse__Group__r.Name, pse__Assignment__c
                                                              FROM pse__Resource_Request__c WHERE Name Like: searchedText];
        return resourceRequestList;
    }
    @AuraEnabled
    public static List<pse__Region__c> getRegions(String searchText){
        String searchedText = '%' + searchText + '%';
        List<pse__Region__c> regionList = [SELECT Id, Name, pse__Region_Head__c, pse__Region_Head__r.Name, pse__Parent_Region__c, pse__Parent_Region__r.Name, pse__Headquarters_Region__c, pse__Headquarters_Region__r.Name, pse__Bookings__c, pse__Billings__c, pse__Billable_Internal_Hours__c,
                                           pse__Total_Costs__c, pse__Margin__c
                                           FROM pse__Region__c WHERE Name Like: searchedText];
        return regionList;
    }
    @AuraEnabled
    public static List<pse__Practice__c> getPractices(String searchText){
        String searchedText = '%' + searchText + '%';
        List<pse__Practice__c> practiceList = [SELECT Id, Name, pse__Practice_Head__c, pse__Practice_Head__r.Name, pse__Parent_Practice__c, pse__Parent_Practice__r.Name, pse__Global_Practice__c, pse__Global_Practice__r.Name, pse__Bookings__c, pse__Billings__c, pse__Billable_Internal_Hours__c,
                                               pse__Total_Costs__c, pse__Margin__c
                                               FROM pse__Practice__c WHERE Name Like: searchedText];
        return practiceList;
    }
    @AuraEnabled
    public static List<pse__Grp__c> getGroups(String searchText){
        String searchedText = '%' + searchText + '%';
        List<pse__Grp__c> groupList = [SELECT Id, Name, pse__Group_Head__c, pse__Group_Head__r.Name, pse__Parent_Group__c, pse__Parent_Group__r.Name, pse__Bookings__c, pse__Billings__c, pse__Billable_Internal_Hours__c,
                                       pse__Total_Costs__c, pse__Margin__c
                                       FROM pse__Grp__c WHERE Name Like: searchedText];
        return groupList;
    }
    @AuraEnabled
    public static List<SkillCertificationSet> getSkills(List<String> skillIdList, List<SkillCertificationSet> lstSkll){
        System.debug('###skillIdList'+skillIdList);
        System.debug('###lstSkll'+lstSkll);
        List<SkillCertificationSet> skillsList = new List<SkillCertificationSet>();
        Integer i=0;
        System.debug('lstSkll>>>>>>*****'+lstSkll);
        Set<Id> alreadySelectedSkillId = new Set<Id>();
        if(lstSkll != null && lstSkll.size() > 0){
            for(SkillCertificationSet s : lstSkll){
                alreadySelectedSkillId.add(s.skillCertification.Id);
            }
            skillsList = lstSkll;
        }
        for(pse__Skill__c psc : [SELECT Id, Name, pse__Type__c, RecordTypeId FROM pse__Skill__c WHERE Id In: skillIdList]){
            SkillCertificationSet obj = new SkillCertificationSet();
            obj.skillCertification = psc;
            obj.showAndOrOperator = false;
            obj.index = i;
            obj.isSelected = true;
            obj.recType = 'Skill';
            skillsList.add(obj);
            i++;
        }
        return skillsList;
    }
    @AuraEnabled
    public static List<SkillCertificationSet> getCertifications(List<String> certificationIdList, List<SkillCertificationSet> lstCerti){
        System.debug('###certificationIdList'+certificationIdList);
        System.debug('###lstCerti'+lstCerti);
        List<SkillCertificationSet> certificationList = new List<SkillCertificationSet>();
        Integer i=0;
        System.debug('lstCerti>>>>>>*****'+lstCerti);
        Set<Id> alreadySelectedCertificationsId = new Set<Id>();
        if(lstCerti != null && lstCerti.size() > 0){
            for(SkillCertificationSet s : lstCerti){
                alreadySelectedCertificationsId.add(s.skillCertification.Id);
            }
            certificationList = lstCerti;
        }
        for(pse__Skill__c psc : [SELECT Id, Name, pse__Type__c, RecordTypeId FROM pse__Skill__c WHERE Id In: certificationIdList]){
            SkillCertificationSet obj = new SkillCertificationSet();
            obj.skillCertification = psc;
            obj.showAndOrOperator = false;
            obj.index = i;
            obj.isSelected = true;
            obj.recType = 'Certification';
            certificationList.add(obj);
            i++;
        }
        return certificationList;
    }
    @AuraEnabled
    public static Map<String,pse__Schedule__c> adjustHoursSchedule(pse__Resource_Request__c resReq, Id resId)
    {
        System.debug('resReq>>adjustHoursSchedule'+resReq);
        Map<String,pse__Schedule__c> mapStrategyBasedOnSchdule = new Map<String,pse__Schedule__c>();
        pse__Schedule__c schedule0 = new pse__Schedule__c();
        pse__Schedule__c schedule1 = new pse__Schedule__c();
        pse__Schedule__c schedule2 = new pse__Schedule__c();
        pse__Schedule__c schedule3 = new pse__Schedule__c();
        pse__Schedule__c schedule4 = new pse__Schedule__c();
        pse__Schedule__c schedule5 = new pse__Schedule__c();
        //AdjustHoursPerDay Strategy Service
        
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = getAdjustHoursScheduleDetail( resReq, resId);
        pse.SchedulingStrategyService.SchedulePattern schPattern = ps.schedule;
        schedule0.pse__Start_Date__c= schPattern.startDate;
        schedule0.pse__End_Date__c= schPattern.endDate;
        schedule0.pse__Monday_Hours__c = schPattern.mondayHours;
        schedule0.pse__Tuesday_Hours__c = schPattern.tuesdayHours;
        schedule0.pse__Wednesday_Hours__c = schPattern.wednesdayHours;
        schedule0.pse__Thursday_Hours__c = schPattern.thursdayHours;
        schedule0.pse__Friday_Hours__c = schPattern.fridayHours;
        schedule0.pse__Saturday_Hours__c = schPattern.saturdayHours;
        schedule0.pse__Sunday_Hours__c = schPattern.sundayHours;
        mapStrategyBasedOnSchdule.put('AdjustHoursPerDay', schedule0);
        
        //EndDateLevelScheduleDetail Strategy Service
        pse.SchedulingStrategyService.ProposedScheduleDetail ps2 = getEndDateLevelScheduleDetail( resReq, resId);
        pse.SchedulingStrategyService.SchedulePattern schPattern1 = ps2.schedule;
        schedule1.pse__Start_Date__c = schPattern1.startDate;
        schedule1.pse__End_Date__c = schPattern1.endDate;
        schedule1.pse__Monday_Hours__c = schPattern1.mondayHours;
        schedule1.pse__Tuesday_Hours__c = schPattern1.tuesdayHours;
        schedule1.pse__Wednesday_Hours__c=schPattern1.wednesdayHours;
        schedule1.pse__Thursday_Hours__c=schPattern1.thursdayHours;
        schedule1.pse__Friday_Hours__c=schPattern1.fridayHours;
        schedule1.pse__Saturday_Hours__c=schPattern1.saturdayHours;
        schedule1.pse__Sunday_Hours__c=schPattern1.sundayHours;
        schedule1.pse__Scheduled_Hours__c = resReq.pse__SOW_Hours__c;
        mapStrategyBasedOnSchdule.put('CalculateEndDateLevelSchedule', schedule1);
        
        //IgnoreAvailabilityScheduleDetail Strategy Service
        pse.SchedulingStrategyService.ProposedScheduleDetail ps3 = getIgnoreAvailabilityScheduleDetail( resReq, resId);
        pse.SchedulingStrategyService.SchedulePattern schPattern2 = ps3.schedule;
        schedule2.pse__Start_Date__c=schPattern2.startDate;
        schedule2.pse__End_Date__c=schPattern2.endDate;
        schedule2.pse__Monday_Hours__c=schPattern2.mondayHours;
        schedule2.pse__Tuesday_Hours__c=schPattern2.tuesdayHours;
        schedule2.pse__Wednesday_Hours__c=schPattern2.wednesdayHours;
        schedule2.pse__Thursday_Hours__c=schPattern2.thursdayHours;
        schedule2.pse__Friday_Hours__c=schPattern2.fridayHours;
        schedule2.pse__Saturday_Hours__c=schPattern2.saturdayHours;
        schedule2.pse__Sunday_Hours__c=schPattern2.sundayHours;
        System.debug('schPattern2>>><< '+schPattern2);
        mapStrategyBasedOnSchdule.put('CalculateEndDateIgnoreAvailability', schedule2);
        
        //Custom Strategy Service
        pse.SchedulingStrategyService.ProposedScheduleDetail ps5 = getCustomScheduleDetail( resReq,  resId, schedule3);
        pse.SchedulingStrategyService.SchedulePattern schPatternCustom = ps5.schedule;
        schedule3.pse__Start_Date__c=schPatternCustom.startDate;
        schedule3.pse__End_Date__c=schPatternCustom.endDate;
        schedule3.pse__Monday_Hours__c=schPatternCustom.mondayHours;
        schedule3.pse__Tuesday_Hours__c=schPatternCustom.tuesdayHours;
        schedule3.pse__Wednesday_Hours__c=schPatternCustom.wednesdayHours;
        schedule3.pse__Thursday_Hours__c=schPatternCustom.thursdayHours;
        schedule3.pse__Friday_Hours__c=schPatternCustom.fridayHours;
        schedule3.pse__Saturday_Hours__c=schPatternCustom.saturdayHours;
        schedule3.pse__Sunday_Hours__c=schPatternCustom.sundayHours;
        mapStrategyBasedOnSchdule.put('Custom', schedule3);
        
        //ZeroHourSchedule Strategy Service
        pse.SchedulingStrategyService.ProposedScheduleDetail ps6 = getZeroHourScheduleDetail( resReq,  resId);
        pse.SchedulingStrategyService.SchedulePattern schPattern4 = ps6.schedule;
        schedule4.pse__Start_Date__c = schPattern4.startDate;
        schedule4.pse__End_Date__c= schPattern4.endDate;
        schedule4.pse__Monday_Hours__c=0;
        schedule4.pse__Tuesday_Hours__c=0;
        schedule4.pse__Wednesday_Hours__c=0;
        schedule4.pse__Thursday_Hours__c=0;
        schedule4.pse__Friday_Hours__c=0;
        schedule4.pse__Saturday_Hours__c=0;
        schedule4.pse__Sunday_Hours__c=0;
        mapStrategyBasedOnSchdule.put('ZeroHourSchedule', schedule4);
        System.debug('mapStrategyBasedOnSchdule>>>'+mapStrategyBasedOnSchdule);
        return mapStrategyBasedOnSchdule;
    }
    @AuraEnabled
    public static String assignHoldSchedulePatterns(Map<String,pse__Schedule__c> mapStrategyPattern, String patternKey, Id resouId, pse__Resource_Request__c resReq, String assignHoldValue,string role){
        list<pse__Schedule_Exception__c> listScheduleException = new list<pse__Schedule_Exception__c>();
        //Insert Schedule
        pse__Schedule__c sch = new pse__Schedule__c();
        pse__Schedule__c schIns = new pse__Schedule__c();
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id =: resouId];
        String nameContact = conList[0].Name;
        try{
            if(mapStrategyPattern != null){
                sch = mapStrategyPattern.get(patternKey);
            }
            if(assignHoldValue == 'release'){
                System.debug('Status'+resReq.pse__Status__c);
                if(resReq.pse__Status__c == 'Hold'){
                    System.debug('RRStatusForRelease '+resReq.pse__Status__c);
                    System.debug('PreferredSchedule '+resReq.pse__Preferred_Schedule__c);
                    System.debug('PreferredSchedule '+resReq.pse__Staffer_Resource__c);
                    pse__Resource_Request__c rr = new pse__Resource_Request__c();
                    rr.Id = resReq.Id;
                    rr.pse__Resource_Held__c = false;
                    rr.pse__Status__c = 'Ready to Staff';
                    rr.Released_Resource__c = resReq.pse__Staffer_Resource__c;
                    rr.pse__Staffer_Resource__c = null;
                    
                    if((resReq.pse__Preferred_Schedule__c != null || resReq.pse__Assignment__c != null)){
                    }
                    resReq.pse__Preferred_Schedule__c =null;
                   //pavani
                    resReq.pse__Assignment__c = null;
                    update rr; 
                    
                    
                    pse__Assignment__c tentativeDeleteRec = [SELECT Id,Name, pse__Assignment_Number__c, pse__Project__c, pse__Role__c, pse__Resource__c, 
                                                             pse__Schedule__c, pse__Status__c, pse__Resource_Request__c FROM pse__Assignment__c where pse__Status__c = 'Tentative'];
     
                    delete tentativeDeleteRec;
                    System.debug('@@@@tentativeDeleteRec:::'+tentativeDeleteRec);
                                       
                    Response r = new Response();
                    r.responseMessage = nameContact + ' has been succesfully released';
                    r.responseCode = '750';
                    return JSON.serialize(r);
                }
                else{
                    Response r = new Response();
                    r.responseMessage = 'To release ,' + nameContact + ' ' + resReq.Name + ' staus must be hold';
                    r.responseCode = '800';
                    return JSON.serialize(r);
                }
            }
            else{
                pse.SchedulingStrategyService.ProposedScheduleDetail ps; 
                if(patternKey == 'AdjustHoursPerDay'){
                    ps = getAdjustHoursScheduleDetail(resReq,resouId);
                }else if(patternKey == 'CalculateEndDateLevelSchedule'){
                    ps = getEndDateLevelScheduleDetail(resReq,resouId);
                }else if(patternKey == 'CalculateEndDateIgnoreAvailability'){
                    ps = getIgnoreAvailabilityScheduleDetail(resReq,resouId);
                }else if(patternKey == 'Custom'){
                    ps = getCustomScheduleDetail(resReq,resouId,sch);
                }else if(patternKey == 'ZeroHourSchedule'){
                    ps = getZeroHourScheduleDetail(resReq,resouId);
                }
                System.debug('resReq.pse__SOW_Hours__c>>>>'+resReq.pse__SOW_Hours__c);
                System.debug('sch.pse__Scheduled_Hours__c>>>'+sch.pse__Scheduled_Hours__c);
                schIns.pse__Start_Date__c = sch.pse__Start_Date__c;
                schIns.pse__End_Date__c = sch.pse__End_Date__c;
                schIns.pse__Monday_Hours__c = sch.pse__Monday_Hours__c;
                schIns.pse__Tuesday_Hours__c = sch.pse__Tuesday_Hours__c;
                schIns.pse__Wednesday_Hours__c = sch.pse__Wednesday_Hours__c;
                schIns.pse__Thursday_Hours__c = sch.pse__Thursday_Hours__c;
                schIns.pse__Friday_Hours__c = sch.pse__Friday_Hours__c;
                schIns.pse__Saturday_Hours__c = sch.pse__Saturday_Hours__c;
                schIns.pse__Sunday_Hours__c = sch.pse__Sunday_Hours__c;
                schIns.pse__Scheduled_Hours__c = resReq.pse__SOW_Hours__c;
                insert schIns;	
                for(pse.SchedulingStrategyService.SchedulePattern pss : ps.scheduleExceptions){
                    pse__Schedule_Exception__c scheduleException = new pse__Schedule_Exception__c();
                    scheduleException.pse__Schedule__c = schIns.id;
                    scheduleException.pse__Date__c = pss.startDate;
                    scheduleException.pse__Monday_Hours__c=pss.mondayHours;
                    scheduleException.pse__Tuesday_Hours__c=pss.tuesdayHours;
                    scheduleException.pse__Wednesday_Hours__c=pss.wednesdayHours;
                    scheduleException.pse__Thursday_Hours__c=pss.thursdayHours;
                    scheduleException.pse__Friday_Hours__c=pss.fridayHours;
                    scheduleException.pse__Saturday_Hours__c=pss.saturdayHours;
                    scheduleException.pse__Sunday_Hours__c=pss.sundayHours;
                    scheduleException.pse__End_Date__c = pss.endDate;
                    listScheduleException.add(scheduleException);
                }  
                insert listScheduleException; 
                List<pse__Schedule__c> prefeSche = [SELECT Id, pse__Scheduled_Hours__c FROM pse__Schedule__c WHERE Id =: schIns.Id];
                System.debug('prefeSche'+prefeSche[0]);
                //Insert Assignment
                
                if(assignHoldValue == 'assign'){
                    pse__Assignment__c assignment = new pse__Assignment__c();
                    assignment.pse__Schedule__c = schIns.Id;
                    assignment.pse__Status__c = 'Scheduled';
                    assignment.pse__Resource__c = resouId;
                    assignment.pse__Project__c = resReq.pse__Project__c;
                    
                    assignment.pse__Planned_Hours__c = resReq.pse__SOW_Hours__c;
                    if(role == null || role == ''){
                        assignment.pse__Role__c = resReq.pse__Resource_Role__c;
                    }else{
                        assignment.pse__Role__c = role;
                    }
                    if(resReq.pse__Requested_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = resReq.pse__Requested_Bill_Rate__c;
                    }
                    else if(resReq.pse__Suggested_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = Decimal.valueOf(resReq.pse__Suggested_Bill_Rate__c);
                    }
                    else if(resReq.pse__Planned_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = resReq.pse__Planned_Bill_Rate__c;
                    }
                    insert assignment; 	
                   
                    pse__Resource_Request__c rr = new pse__Resource_Request__c();
                    rr.Id = resReq.Id;
                    rr.pse__Resource_Held__c = false;
                    rr.pse__Status__c = 'Assigned';
                    rr.pse__Preferred_Schedule__c = schIns.Id;
                    rr.pse__Assignment__c = assignment.Id;
                    rr.pse__Staffer_Resource__c = resouId;
                    update rr;		
                    Response r = new Response();
                    r.responseMessage = nameContact + ' has been succesfully assigned';
                    r.responseCode = '900';
                    r.scheduleId = schIns.Id;
                    return JSON.serialize(r);
                }
                else if(assignHoldValue == 'hold'){
                    //pavani
                    pse__Assignment__c assignment = new pse__Assignment__c();
                    assignment.pse__Schedule__c = schIns.Id;
                    assignment.pse__Status__c = 'Tentative';
                    //assignment.Tentative_status_field__c = 'Tentative';
                    assignment.pse__Resource__c = resouId;
                    assignment.pse__Project__c = resReq.pse__Project__c;
                    assignment.pse__Planned_Hours__c = resReq.pse__SOW_Hours__c;
                    if(resReq.pse__Requested_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = resReq.pse__Requested_Bill_Rate__c;
                    }
                    else if(resReq.pse__Suggested_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = Decimal.valueOf(resReq.pse__Suggested_Bill_Rate__c);
                    }
                    else if(resReq.pse__Planned_Bill_Rate__c != null){
                        assignment.pse__Bill_Rate__c = resReq.pse__Planned_Bill_Rate__c;
                    }
                    insert assignment;
                    System.debug('########## Assignment ::: ' +assignment);
                    pse__Resource_Request__c rr = new pse__Resource_Request__c();
                    rr.Id = resReq.Id;
                    rr.pse__Resource_Held__c = true;
                    rr.pse__Status__c = 'Hold';
                    rr.pse__Preferred_Schedule__c = schIns.Id;
                    rr.pse__Staffer_Resource__c = resouId;
                    rr.pse__Assignment__c = assignment.id; 
                    System.debug('########## AssignmentID ::: ' +assignment.id);
                    update rr; 
                    Response r = new Response();
                    r.responseMessage = nameContact + ' has been succesfully hold';
                    r.responseCode = '1000';
                    return JSON.serialize(r);
                }
                return null;
            }
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            Response r = new Response();
            r.responseMessage = e.getMessage();
            r.responseCode = '100';
            return JSON.serialize(r);
        }
    }
    public class SearchDetails{
        //isHoldDisabled is Added as part of story prevent from softbooking or hold- Anisa Khanum
        @AuraEnabled
        public Boolean isHoldDisabled{get;set;}
        @AuraEnabled
        public String skillFilterCriteria{get;set;}
        @AuraEnabled
        public String certificationFilterCriteria{get;set;}
        @AuraEnabled
        public Double projLatitude{get;set;}
        @AuraEnabled
        public Boolean isLocationAvailble{get;set;}
        @AuraEnabled
        public Double projLogitude{get;set;}
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled
        public String zipCode{get;set;}
        @AuraEnabled
        public String startDate{get;set;}
        @AuraEnabled
        public String endDate{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String resourceRequestName{get;set;}
        @AuraEnabled
        public String role{get;set;}
        @AuraEnabled
        public Boolean workedWithCustomer{get;set;}
        @AuraEnabled
        public Boolean availability{get;set;}
        @AuraEnabled
        public String availabilityValue{get;set;}
        @AuraEnabled
        public Boolean internal{get;set;}
        @AuraEnabled
        public String internalValue{get;set;}
        @AuraEnabled
        public Boolean distance{get;set;}
        @AuraEnabled
        public String distanceValue{get;set;}
        @AuraEnabled
        public String distanceUnit{get;set;}
        @AuraEnabled
        public List<string> roleList{get;set;}
        @AuraEnabled
        public List<string> statusList{get;set;}
        @AuraEnabled
        public List<string> skillCertRatingList{get;set;}
        @AuraEnabled
        public Boolean customSettingValue{get;set;}
        @AuraEnabled
        public String filterLogicSkill{get;set;}
        @AuraEnabled
        public String filterLogicCertification{get;set;}
        @AuraEnabled
        public String regionFilter{get;set;}
        @AuraEnabled
        public String regionValue{get;set;}
        @AuraEnabled
        public String practiceFilter{get;set;}
        @AuraEnabled
        public String practiceValue{get;set;}
        @AuraEnabled
        public String groupFilter{get;set;}
        @AuraEnabled
        public String groupValue{get;set;}
        @AuraEnabled
        public String defaultCostRateFilter{get;set;}
        @AuraEnabled
        public Integer defaultCostRateValue{get;set;}
        @AuraEnabled
        public String scheduledUtilizationFilter{get;set;}
        @AuraEnabled
        public Integer scheduledUtilizationValue{get;set;}
        @AuraEnabled
        public Boolean rdcFilter{get;set;}
        @AuraEnabled
        public List<String> rdcList{get;set;}
        @AuraEnabled
        public String rdcValue{get;set;}
        @AuraEnabled
        public Boolean openFromResourceReqScreen{get;set;}
        @AuraEnabled
        public pse__Resource_Request__c selectedResourceRequest{get;set;}
        @AuraEnabled
        public Boolean showSubmitForPdMApproval{get;set;}
        @AuraEnabled
        public List<SkillCertificationSet> lstSkill{get;set;}
        @AuraEnabled
        public List<SkillCertificationSet> lstCertification{get;set;}
    }
    public class SkillCertificationSet{
        @AuraEnabled
        public pse__Skill__c skillCertification{get;set;}
        @AuraEnabled
        public Boolean showAndOrOperator{get;set;}
        @AuraEnabled
        public Integer index{get;set;}
        @AuraEnabled
        public String skillExp{get;set;}
        @AuraEnabled
        public String recType{get;set;}
        @AuraEnabled
        public String andOrOperator{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
    }
    public class ContactPageWrapper {
        @AuraEnabled
        public Integer pageSize{get;set;}
        @AuraEnabled
        public Integer page{get;set;}
        @AuraEnabled
        public Integer total{get;set;}
        @AuraEnabled
        public List<Contact> contacts{get;set;}
        @AuraEnabled
        public Boolean resRequestAvailability{get;set;}
    }
    public class Response{
        @AuraEnabled
        public String responseCode {get;set;}
        @AuraEnabled
        public String responseMessage {get;set;}
        @AuraEnabled
        public Id scheduleId {get;set;}
    }
    public static map<ID,Contact> calculateDistance(List<Contact> contactDistanceList, String disValue2, String disUnit,Double projLongitude , Double projLatitude,Boolean distanceChecked){
        if(disValue2 == 'All'){
            disValue2 = '300.00';
        }
        Decimal disValue = Decimal.valueOf(disValue2);
        map<ID,Contact> distanceMatchedContact = new map<Id,Contact>();
        //List<Decimal> distance  = new List<Decimal>();
        Location projLocation = Location.newInstance(projLatitude,projLongitude);
        system.debug('projLocation::::'+projLocation);
        for(Contact c : contactDistanceList){
            if(c.mailinglatitude != null && c.mailinglongitude != null){
                Location contactLocation = Location.newInstance(c.mailinglatitude,c.mailinglongitude);
                system.debug('contactLocation::::'+contactLocation);
                Decimal distanceValue = Location.getDistance(projLocation,contactLocation, disUnit);                
                system.debug('D1::::'+distanceValue);
                system.debug('disValue:::'+disValue);
                if(!distanceChecked || (distanceValue > 0.0 && distanceValue <= disValue)){
                        system.debug('Inside If Val');
                    //distance.add(Location.getDistance(projLocation,contactLocation,disUnit));
                    //Decimal decValue = Decimal.valueOf(Location.getDistance(projLocation,contactLocation,disUnit));
                    Decimal roundedValue = distanceValue.setScale(2);
                    system.debug('roundedValue::::'+roundedValue);
                    if(disUnit == 'km'){
                        c.FBE_IDS_Distance__c = String.valueOf(roundedValue) + ' KM';
                    }else{
                        c.FBE_IDS_Distance__c = String.valueOf(roundedValue) + ' MI';
                    }
                    system.debug('distance::::'+c.FBE_IDS_Distance__c);
                    distanceMatchedContact.put(c.Id,c);
                }
            }
        }
        system.debug('distanceMatchedContact+++'+distanceMatchedContact);
        return distanceMatchedContact;
    }
    /***********************************************************************************
* Purpose - getting assignment records based on start date and end date
of resource request if present
***********************************************************************************/
    public static Set<Id> getAssignmentOnSearchReq(SearchResourcesController.SearchDetails searchDetailList, List<pse__Resource_Request__c> resRequestList, String endDate,  String startDate){
        String whereClauseAssign = ' WHERE  pse__Resource__c != ' + null ;
        String finalQueryAssign = 'SELECT Id, pse__Resource__c FROM pse__Assignment__c ';
        Set<Id> contactIdResourceSet = new Set<Id>();
        if(startDate != null && endDate != null){
            whereClauseAssign += ' And pse__End_Date__c >= ' + startDate + ' AND pse__Start_Date__c <= ' + endDate;
            
        }else if(searchDetailList.availabilityValue == 'No Assignments'){
            whereClauseAssign +=  ' And pse__Start_Date__c <= TODAY  and pse__End_Date__c >= TODAY';
        }
        finalQueryAssign = finalQueryAssign + whereClauseAssign;
        assignmentListGlobal = DataBase.query(finalQueryAssign);
        System.debug('assignmentListGlobal:::'+assignmentListGlobal);
        system.debug('finalQueryAssign:::::'+finalQueryAssign);
        for(pse__Assignment__c assign : DataBase.query(finalQueryAssign)){
            contactIdResourceSet.add(assign.pse__Resource__c);
        }
        return contactIdResourceSet;
        
    }
    @AuraEnabled
    public static SearchDetails getSkillsAndCertBasedOnResRequest(String recordId , SearchDetails lstSearchDetail){
        List<pse__Resource_Request__c> resReqList = [SELECT Id, Name, pse__Status__c, pse__SOW_Hours__c, pse__Requested_Bill_Rate__c, pse__Suggested_Bill_Rate__c, pse__Planned_Bill_Rate__c, pse__Project__r.PDM__r.Email
                                                     , pse__Project__r.Name, pse__Opportunity__r.Name, pse__Resource_Role__c, pse__Start_Date__c, pse__End_Date__c, pse__Resource__r.Name, pse__Preferred_Schedule__c, pse__Project__c, pse__Project__r.PDM__c, pse__Region__r.Name, pse__Practice__c, 
                                                     pse__Practice__r.Name, pse__Group__c, pse__Group__r.Name, pse__Staffer_Resource__c, pse__Assignment__c
                                                     FROM pse__Resource_Request__c WHERE Id =: recordId];
        
        SearchDetails sd = lstSearchDetail;
        sd.lstSkill = new List<SkillCertificationSet>();
        sd.lstCertification = new List<SkillCertificationSet>();
        if(resReqList.size() > 0){
            Map<Id, String> mapSkillIdWithRating = new Map<Id, String>();
            Set<Id> skillCertificationId = new Set<Id>();
            for(pse__Resource_Skill_Request__c prsrc : [SELECT Id, pse__Resource_Request__c, pse__Skill_Certification__c, pse__Minimum_Rating__c
                                                        FROM pse__Resource_Skill_Request__c WHERE pse__Resource_Request__c In: resReqList]){
                                                            skillCertificationId.add(prsrc.pse__Skill_Certification__c);
                                                            mapSkillIdWithRating.put(prsrc.pse__Skill_Certification__c, prsrc.pse__Minimum_Rating__c);
                                                        }
            Integer skillIndex = 0;
            Integer certIndex = 0;
            for(pse__Skill__c psc : [SELECT Id, Name, pse__Type__c, RecordType.Name FROM pse__Skill__c WHERE Id In: skillCertificationId]){
                
                SkillCertificationSet obj = new SkillCertificationSet();
                if(psc.RecordType.Name == 'Skill'){
                    obj.skillCertification = psc;
                    obj.showAndOrOperator = false;
                    obj.index = skillIndex;
                    obj.isSelected = true;
                    obj.skillExp = mapSkillIdWithRating.get(psc.Id);
                    obj.recType = 'Skill';
                    sd.lstSkill.add(obj);
                    skillIndex++;
                }
                else if(psc.RecordType.Name == 'Certification'){
                    obj.skillCertification = psc;
                    obj.showAndOrOperator = false;
                    obj.index = certIndex;
                    obj.isSelected = true;
                    obj.skillExp = mapSkillIdWithRating.get(psc.Id);
                    obj.recType = 'Certification';
                    sd.lstCertification.add(obj);
                    certIndex++;
                }
            }
            sd.selectedResourceRequest = resReqList[0];
        }
        return sd;
    }
    
    public static List<pse__Resource_Request__c> getResourceReqList(SearchResourcesController.SearchDetails searchDetailList){
        List<pse__Resource_Request__c> resRequestList = new List<pse__Resource_Request__c>();
        String queryResouReq = 'Select Id,pse__Project__c,pse__Project__r.pse__Account__r.shippinglatitude,pse__Project__r.pse__Account__r.shippinglongitude, pse__Resource_Role__c,pse__Start_Date__c, pse__End_Date__c, pse__Project__r.pse__Account__c, pse__Region__r.Name, pse__Practice__c, pse__Practice__r.Name, pse__Staffer_Resource__c, pse__Assignment__c FROM pse__Resource_Request__c ';
        String whereClauseResReq = 'WHERE';
        Boolean queryResourceReqRecords = false;
        String finalQueryResReq;
        /***********************************************************************************
* Purpose - Search Resources based on the Name Feild
on the basic of insert and update the name of Resource
***********************************************************************************/
        system.debug('searchDetailList##' + searchDetailList);
        /* if(searchDetailList.resourceRequestName != null){
whereClauseResReq += ' Name = ' + '\'' + searchDetailList.resourceRequestName + '\'';
queryResourceReqRecords = true;
}*/
        /***********************************************************************************
* Purpose - Search Resources based on the Name Feild
on the basic of insert and update the name
of Resource when user select the Resource request from the resource reqest record
***********************************************************************************/
        
        
        /*else*/ if(searchDetailList.selectedResourceRequest != null && searchDetailList.selectedResourceRequest.Name != null){
            whereClauseResReq += ' Name = ' + '\'' + searchDetailList.selectedResourceRequest.Name + '\'';
            queryResourceReqRecords = true;
        }
        
        /***********************************************************************************
* Purpose - Query on the based on where clause  Resource request
***********************************************************************************/
        if(whereClauseResReq == 'WHERE'){
            finalQueryResReq = queryResouReq;
        }
        else{
            finalQueryResReq = queryResouReq + whereClauseResReq;
        }
        System.debug('###finalQueryResReq'+finalQueryResReq);
        
        /***********************************************************************************
* Purpose - Query on the Resource request
***********************************************************************************/
        if(queryResourceReqRecords){
            resRequestList = DataBase.query(finalQueryResReq);
        }
        System.debug('###resRequestList'+resRequestList);
        System.debug('###resRequestListSize'+resRequestList.size());
        if(resRequestList.size() > 0){
            return resRequestList;
        }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static Boolean saveFilterForScreen(SearchDetails lstSearchDetail){
        List<pse__Region__c> reg = new List<pse__Region__c>();
        List<pse__Practice__c> prac = new List<pse__Practice__c>();
        List<pse__Grp__c> grou = new List<pse__Grp__c>();
        List<Contact> con = new List<Contact>();
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionValue != null && lstSearchDetail.regionValue != ''){
            reg = [SELECT Id, Name FROM pse__Region__c WHERE Name =: lstSearchDetail.regionValue];
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceValue != null && lstSearchDetail.practiceValue != ''){
            prac = [SELECT Id, Name FROM pse__Practice__c WHERE Name =: lstSearchDetail.practiceValue];
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupValue != null && lstSearchDetail.groupValue != ''){
            grou = [SELECT Id, Name FROM pse__Grp__c WHERE Name =: lstSearchDetail.groupValue];
        }
        if(lstSearchDetail.resourceRequestName != null && lstSearchDetail.resourceRequestName != ''){
            con = [SELECT Id, Name FROM Contact WHERE Name =: lstSearchDetail.resourceRequestName];
        }
        System.debug('lstSearchDetail.resourceRequestName>>'+lstSearchDetail.resourceRequestName);
        System.debug('con><<>>'+con);
        String serializeSearchDetail = JSON.serialize(lstSearchDetail);
        pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
        resRequest.Id = lstSearchDetail.selectedResourceRequest.Id;
        resRequest.SearchFilterForPDM__c = serializeSearchDetail;
        resRequest.pse__Start_Date__c = Date.valueOf(lstSearchDetail.startDate);
        resRequest.pse__End_Date__c = Date.valueOf(lstSearchDetail.endDate);
        resRequest.pse__Resource_Role__c = lstSearchDetail.role;
        if(lstSearchDetail.regionFilter != null && lstSearchDetail.regionFilter != '' && lstSearchDetail.regionValue != null && lstSearchDetail.regionValue != ''){
            resRequest.pse__Region__c = reg[0].Id;
        }
        if(lstSearchDetail.practiceFilter != null && lstSearchDetail.practiceFilter != '' && lstSearchDetail.practiceValue != null && lstSearchDetail.practiceValue != ''){
            resRequest.pse__Practice__c = prac[0].Id;
        }
        if(lstSearchDetail.groupFilter != null && lstSearchDetail.groupFilter != '' && lstSearchDetail.groupValue != null && lstSearchDetail.groupValue != ''){
            resRequest.pse__Group__c = grou[0].Id;        }
        if(lstSearchDetail.resourceRequestName != null && lstSearchDetail.resourceRequestName != ''){
            resRequest.pse__Resource__c = con[0].Id;
        }
        update resRequest;
        return true;
    }
    @AuraEnabled
    public static String submitForApprovalPDM(pse__Resource_Request__c resRequ, SearchDetails lstSearchDetail){
        System.debug('resRequ>>>>'+resRequ);
        String urler = URL.getSalesforceBaseUrl().toString();
        System.debug('Beforeurler>>>>'+urler);
        urler = urler.replace('Url:[delegate=','');
        urler = urler.replace(']','');
        System.debug('urler>>>>'+urler);
        if(resRequ != null && resRequ.pse__Status__c == 'Approval Pending'){
            String serializeSearchDetail = JSON.serialize(lstSearchDetail);
            pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
            resRequest.Id = resRequ.Id;
            resRequest.pse__Status__c = resRequ.pse__Status__c;
            resRequest.PDM__c = resRequ.pse__Project__r.PDM__c;
            resRequest.Resource_Screen_URL__c = urler + '/lightning/cmp/c__SearchResources?c__ResourceRequestID=' + resRequ.Id;
            resRequest.SearchFilterForPDM__c = serializeSearchDetail;
            update resRequest; 
            System.debug('updated ResourceRequestBaased>>>>'+resRequest);
            return 'status is Send For PDM Approval';
        }
        else{
            return 'status is not Send For PDM Approval';
        }
    }
    @AuraEnabled
    public static String getPartiallyAllocatedResource(){
        
        return null;         
    }
    // To display columns dynamically from fieldset  
    public class ColumnsSettings{
        @AuraEnabled
        public list<WrapperColumns> columns {get;set;}
        @AuraEnabled 
        public Map<String,String> lookUpFieldsWithvalue {get;set;}
    }
    public class WrapperColumns{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public Integer initialWidth {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean sortable {get;set;}
        @AuraEnabled
        public Attributes typeAttributes {get;set;}
        
    }
    public class Attributes{
        @AuraEnabled 
        public Label label {get;set;}
        @AuraEnabled
        public String target {get;set;}
        
    }
    public class Label{
        @AuraEnabled
        public String fieldName {get;set;}
    }    
    @AuraEnabled
    public static ColumnsSettings DisplayColumns1(String objApi, String fieldSetName){
        
        //List<FieldSetProperties> lstOfWrapper = new List<FieldSetProperties>();
        ColumnsSettings cs = new ColumnsSettings();
        cs.columns = new list<WrapperColumns>();
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objApi);
        Schema.DescribeSObjectResult desSObjRslt = sObjType.getDescribe();            
        Schema.FieldSet fieldSetIns = desSObjRslt.FieldSets.getMap().get(fieldSetName);
        cs.lookUpFieldsWithvalue = new Map<String,String>();
        set<String> referenceFieldSet = getReferenceField();
        
        for( Schema.FieldSetMember f : fieldSetIns.getFields() ){
            WrapperColumns wc = new WrapperColumns();
            String fieldName = f.getFieldPath();
            String lowerCaseFieldName = fieldName.toLowerCase();
            if(fieldName == 'MasterRecordId'){
                fieldName = 'Name';
            }
            if(f.getLabel() == 'Master Record ID'){
                wc.label = 'Contact Name';
                system.debug('f.getFieldPath():::::'+fieldName);
            }
            else{
                wc.label = f.getLabel() ;
            }
            wc.initialWidth = 200;
            wc.sortable = true;
            system.debug('referenceFieldSet:::'+referenceFieldSet);
            system.debug('fieldName:::::::::::'+fieldName);
            
            if(referenceFieldSet.Contains(fieldName) || referenceFieldSet.Contains(lowerCaseFieldName)){
                //add Lookup Field Name With Relation Field Name
                if(fieldName.contains('__c')){
                    String relationshipName = fieldName.substring(0,fieldName.length()-3);
                    cs.lookUpFieldsWithvalue.put(fieldName,relationshipName+'__r');
                }else{
                    String relationshipName = fieldName.substring(0,fieldName.length()-2);
                    cs.lookUpFieldsWithvalue.put(fieldName,relationshipName);
                }
                wc.fieldName = 'link'+fieldName;
                wc.type = 'url';
                Label l = new Label();
                l.fieldName = fieldName;
                Attributes att = new Attributes();
                att.label = l;
                att.target = '_blank';
                wc.typeAttributes = att;
            }else{
                wc.type = 'text';
                wc.fieldName = fieldName ;
            }
            
            cs.columns.add(wc);
            
        }
        
        return cs;
    }
    public static Set<String> getReferenceField(){
        Set<String> mySet = new Set<String>();
        SObjectType objType = Schema.getGlobalDescribe().get('Contact');
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        for(String  fieldName : fieldMap.keySet()){ 
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType.name().toUpperCase() == 'REFERENCE'){
                mySet.add(fieldName); 
            }
        }
        return mySet;
    }
    
    public static Set<Id> getWrokedWithCustomerResource(List<Contact> selectedContact, Id projectAccountId){ 
        Set<Id> workedWithCustomerResource = new Set<Id>();
        for(pse__Assignment__c assignment : [Select Id , pse__Resource__c, pse__Assignment__c.pse__Project__r.pse__Account__c From pse__Assignment__c where  pse__Resource__c IN : selectedContact AND pse__Project__c != null AND pse__Project__r.pse__Account__c = : projectAccountId ]){
            workedWithCustomerResource.add(assignment.pse__Resource__c);   
        } 
        System.debug('workedWithCustomerResource@@@ ' + workedWithCustomerResource);
        return workedWithCustomerResource;
    }
    
    //Start For New FilterLogicSkill
   /* public static Set<Id> getAllSkilledContacts(List<Contact> selectedContacts, SearchDetails searchDetailList){
        Set<Id> filteredSkilledContact = new Set<Id>();
        Set<String> setSkillIds = new Set<String>();
        Set<String> setSkillIdsWithRating = new Set<String>();
        Set<String> setCertificationIdsWithRating = new Set<String>();
        Map<Id,Set<String>> contactIdWithSkillRating = new Map<Id,Set<String>>();
        Set<String> rating = new Set<String>();
        if(!searchDetailList.lstSkill.isEmpty()){
            for(SkillCertificationSet skil : searchDetailList.lstSkill){
                if(skil.isSelected){
                    if(skil.skillExp == ''){
                        skil.skillExp = null;
                    }
                    setSkillIds.add(skil.skillCertification.Id);
                    rating.add(skil.skillExp);
                    setSkillIdsWithRating.add(skil.skillCertification.Id + '#' + skil.skillExp);
                }
            }
            
        }
        System.debug('setSkillIdsAfterSkill '+setSkillIds);
        System.debug('ratingAfterSkill '+rating);
        System.debug('setSkillIdsWithRatingAfterSkill '+setSkillIdsWithRating);
        System.debug('selectedContacts::: '+selectedContacts);
        if(!setSkillIds.isEmpty()){
            for(pse__Skill_Certification_Rating__c src : [SELECT Id, pse__Skill_Certification__c, pse__Rating__c, pse__Resource__c
                                                          FROM pse__Skill_Certification_Rating__c
                                                          WHERE pse__Resource__c in:selectedContacts And pse__Skill_Certification__c In: setSkillIds AND pse__Rating__c In: rating]){
                                                              if(!contactIdWithSkillRating.containsKey(src.pse__Resource__c)){
                                                                  contactIdWithSkillRating.put(src.pse__Resource__c, new Set<String>());
                                                              }
                                                              contactIdWithSkillRating.get(src.pse__Resource__c).add(src.pse__Skill_Certification__c + '#' + src.pse__Rating__c);
                                                          }
        }
        System.debug('contactIdWithSkillRating  '+contactIdWithSkillRating);
        if(contactIdWithSkillRating.size() > 0 && searchDetailList.skillFilterCriteria != null && searchDetailList.skillFilterCriteria != ''){
            for(Id contactId : contactIdWithSkillRating.keySet()){
                integer count =1;
                string filterCriteria = searchDetailList.skillFilterCriteria;
                system.debug('filterCriteria::skill :: 11:::'+filterCriteria);
                Set<String> contactSkills = contactIdWithSkillRating.get(contactId);
                for(String resourceSkill : setSkillIdsWithRating){
                    string skillMatch = 'False';
                    if(contactSkills.contains(resourceSkill)){
                        skillMatch = 'True';
                    }
                    system.debug('resourceSkill: skill ::'+resourceSkill);
                    system.debug('skillMatch: skill ::'+skillMatch);
                    string countString = string.valueOf(count);
                    system.debug('countString::skill::'+countString);
                    count++;
                    filterCriteria = filterCriteria.replace(countString,skillMatch);
                }
                system.debug('filterCriteria::skill :: 22:::'+filterCriteria);
                if(BooleanExpression.eval(filterCriteria)){
                    filteredSkilledContact.add(contactId);
                }
            }
        } 
        else if(contactIdWithSkillRating.size() > 0 && searchDetailList.filterLogicSkill == 'And'){
            for(Id contactId : contactIdWithSkillRating.keySet()){
                Boolean allSkillMatch = true;
                Set<String> contactSkills = contactIdWithSkillRating.get(contactId);
                for(String resourceSkill : setSkillIdsWithRating){
                    if(!contactSkills.contains(resourceSkill)){
                        allSkillMatch = false;
                    }
                }
                if(allSkillMatch == true){
                    filteredSkilledContact.add(contactId);
                }
            }
        } 
        else if(contactIdWithSkillRating.size() > 0 && searchDetailList.filterLogicSkill == 'Or'){
            for(Id contactId : contactIdWithSkillRating.keySet()){
                Boolean allSkillMatch = false;
                Set<String> contactSkills = contactIdWithSkillRating.get(contactId);
                for(String resourceSkill : setSkillIdsWithRating){
                    if(contactSkills.contains(resourceSkill)){
                        allSkillMatch = true;
                        break;
                    }
                }
                if(allSkillMatch == true){
                    filteredSkilledContact.add(contactId);
                }
            }
        }
        System.debug('>>>filteredSkilledContact '+filteredSkilledContact);
        return filteredSkilledContact;
    }
    //Start For New FilterLogicCertification
    public static Set<Id> getAllCertifiedContacts(List<Contact> selectedContacts, SearchDetails searchDetailList){
        Set<Id> filteredCertifiedContact = new Set<Id>();
        Set<String> setSkillIds = new Set<String>();
        Set<String> setCertificationIdsWithRating = new Set<String>();
        Map<Id,Set<String>> contactIdWithCertRating = new Map<Id,Set<String>>();
        Set<String> rating = new Set<String>();
        if(!searchDetailList.lstCertification.isEmpty()){
            for(SkillCertificationSet cert : searchDetailList.lstCertification){
                if(cert.isSelected){
                    if(cert.skillExp == ''){
                        cert.skillExp = null;
                    }
                    setSkillIds.add(cert.skillCertification.Id);
                    rating.add(cert.skillExp);
                    setCertificationIdsWithRating.add(cert.skillCertification.Id + '#' + cert.skillExp);
                }
            }
        }
        System.debug('setSkillIdsAfterSkillCert::::'+setSkillIds);
        System.debug('ratingAfterSkillCert::::'+rating);
        System.debug('setCertificationIdsWithRatingAfterSkillCert::::'+setCertificationIdsWithRating);
        System.debug('selectedContacts::: '+selectedContacts);
        if(!setSkillIds.isEmpty()){
            for(pse__Skill_Certification_Rating__c src : [SELECT Id, pse__Skill_Certification__c, pse__Rating__c, pse__Resource__c
                                                          FROM pse__Skill_Certification_Rating__c
                                                          WHERE pse__Resource__c in:selectedContacts And pse__Skill_Certification__c In: setSkillIds AND pse__Rating__c In: rating]){
                                                              if(!contactIdWithCertRating.containsKey(src.pse__Resource__c)){
                                                                  contactIdWithCertRating.put(src.pse__Resource__c, new Set<String>());
                                                              }
                                                              contactIdWithCertRating.get(src.pse__Resource__c).add(src.pse__Skill_Certification__c + '#' + src.pse__Rating__c);
                                                          }
        }
        System.debug('contactIdWithCertRating  '+contactIdWithCertRating);
        if(contactIdWithCertRating.size() > 0 && searchDetailList.certificationFilterCriteria != null && searchDetailList.certificationFilterCriteria != ''){
            for(Id contactId : contactIdWithCertRating.keySet()){
                integer count =1;
                string filterCriteria = searchDetailList.certificationFilterCriteria;
                system.debug('filterCriteria::11:::'+filterCriteria);
                Set<String> contactSkills = contactIdWithCertRating.get(contactId);
                for(String resourceSkill : setCertificationIdsWithRating){
                    string skillMatch = 'False';
                    if(contactSkills.contains(resourceSkill)){
                        skillMatch = 'True';
                    }
                    system.debug('resourceSkill::'+resourceSkill);
                    system.debug('skillMatch:::'+skillMatch);
                    
                    string countString = string.valueOf(count);
                    system.debug('countString:::'+countString);
                    count++;
                    filterCriteria = filterCriteria.replace(countString,skillMatch);
                }
                system.debug('filterCriteria::22:::'+filterCriteria);
               /* if(BooleanExpression.eval(filterCriteria)){
                    filteredCertifiedContact.add(contactId);
                }*/
           /* }
        } 
        else if(contactIdWithCertRating.size() > 0 && searchDetailList.filterLogicCertification == 'And'){
            for(Id contactId : contactIdWithCertRating.keySet()){
                Boolean allSkillMatch = true;
                Set<String> contactSkills = contactIdWithCertRating.get(contactId);
                for(String resourceSkill : setCertificationIdsWithRating){
                    if(!contactSkills.contains(resourceSkill)){
                        allSkillMatch = false;
                    }
                }
                if(allSkillMatch == true){
                    filteredCertifiedContact.add(contactId);
                }
            }
        } 
        else if(contactIdWithCertRating.size() > 0 && searchDetailList.filterLogicCertification == 'Or'){
            for(Id contactId : contactIdWithCertRating.keySet()){
                Boolean allSkillMatch = false;
                Set<String> contactSkills = contactIdWithCertRating.get(contactId);
                for(String resourceSkill : setCertificationIdsWithRating){
                    if(contactSkills.contains(resourceSkill)){
                        allSkillMatch = true;
                        break;
                    }
                }
                if(allSkillMatch == true){
                    filteredCertifiedContact.add(contactId);
                }
            }
        }
        System.debug('>>>filteredCertifiedContact '+filteredCertifiedContact);
        return filteredCertifiedContact;
    }*/
        //Start For New FilterLogicSkill
    public static Set<Id> getAllSkilledCertifiedContacts(List<Contact> selectedContacts, SearchDetails searchDetailList,List<SkillCertificationSet> lstSkillCertification){
        Set<Id> filteredSkilledContact = new Set<Id>();
        Set<String> setSkillIds = new Set<String>();
        Set<String> setCertificationIdsWithRating = new Set<String>();
        Map<Id,Set<String>> contactIdWithSkill = new Map<Id,Set<String>>();
        Map<Id,Integer> skillIDWithRating = new Map<Id,Integer>();
        Map<string,Integer> contactSkillIDWithRating = new Map<string,Integer>();
        Set<integer> selsetedratingNumber = new Set<integer>();
        for(SkillCertificationSet skil : lstSkillCertification){
            if(skil.isSelected){
                if(skil.skillExp == ''){
                    skil.skillExp = null;
                }else{
                    selsetedratingNumber.add(Integer.valueOf(skil.skillExp));
                }
                setSkillIds.add(skil.skillCertification.Id);
                skillIDWithRating.put(skil.skillCertification.Id,Integer.valueOf(skil.skillExp));
            }
        }
        System.debug('setSkillIdsAfterSkill '+setSkillIds);
        System.debug('selectedContacts::: '+selectedContacts);
        if(!setSkillIds.isEmpty()){
            for(pse__Skill_Certification_Rating__c src : [SELECT Id, pse__Skill_Certification__c, pse__Rating__c, pse__Resource__c,pse__Numerical_Rating__c
                                                          FROM pse__Skill_Certification_Rating__c
                                                          WHERE pse__Resource__c in:selectedContacts And pse__Skill_Certification__c In: setSkillIds AND (pse__Numerical_Rating__c >=: selsetedratingNumber or pse__Numerical_Rating__c = null)]){
                                                              if(!contactIdWithSkill.containsKey(src.pse__Resource__c)){
                                                                  contactIdWithSkill.put(src.pse__Resource__c, new Set<String>());
                                                              }
                                                              contactIdWithSkill.get(src.pse__Resource__c).add(src.pse__Skill_Certification__c);
                                                              string strKey = src.pse__Resource__c+'#'+src.pse__Skill_Certification__c;
                                                              contactSkillIDWithRating.put(strKey,integer.valueOf(src.pse__Numerical_Rating__c));
                                                          }
        }
        System.debug('contactIdWithSkill  '+contactIdWithSkill);
        if(contactIdWithSkill.size() > 0 && searchDetailList.skillFilterCriteria != null && searchDetailList.skillFilterCriteria != ''){
            for(Id contactId : contactIdWithSkill.keySet()){
                integer count =1;
                string filterCriteria = searchDetailList.skillFilterCriteria;
                system.debug('filterCriteria::skill :: 11:::'+filterCriteria);
                Set<String> contactSkills = contactIdWithSkill.get(contactId);
                for(String skillId : setSkillIds){
                    string skillMatch = 'False';
                    string strKey = contactId+'#'+skillId;
                    if(contactSkillIDWithRating.containsKey(strKey)){
                        // check the rating is matching
                        integer selectedRating = skillIDWithRating.get(skillId);
                        integer contactSkillRating = contactSkillIDWithRating.get(strKey);
                        if(contactSkillRating >= selectedRating){
                            skillMatch = 'True';
                        }
                        
                    }
                    system.debug('skillMatch: skill ::'+skillMatch);
                    string countString = string.valueOf(count);
                    system.debug('countString::skill::'+countString);
                    count++;
                    filterCriteria = filterCriteria.replace(countString,skillMatch);
                }
                system.debug('filterCriteria::skill :: 22:::'+filterCriteria);
                if(BooleanExpression.eval(filterCriteria)){
                    filteredSkilledContact.add(contactId);
                }
            }
        } 
        else if(contactIdWithSkill.size() > 0 && searchDetailList.filterLogicSkill == 'And'){
            for(Id contactId : contactIdWithSkill.keySet()){
                
                Boolean allSkillMatch = true;
                Set<String> contactSkills = contactIdWithSkill.get(contactId);
                system.debug('And :::::');
                system.debug('contactSkills ::'+contactSkills);
                system.debug('setSkillIds ::'+setSkillIds);
                for(String skillID : setSkillIds){
                    string strKey = contactId+'#'+skillId;
                    if(contactSkillIDWithRating.containsKey(strKey)){
                        // check the rating is matching
                        integer selectedRating = skillIDWithRating.get(skillId);
                        integer contactSkillRating = contactSkillIDWithRating.get(strKey);
                        system.debug('selectedRating ::'+selectedRating);
                		system.debug('contactSkillRating ::'+contactSkillRating);
                        if(contactSkillRating < selectedRating){
                            allSkillMatch = false;
                            break;
                        }
                    }else{
                        allSkillMatch = false;
                        break;
                    }
                }
                system.debug('contactId ::'+contactId);
                system.debug('allSkillMatch ::'+allSkillMatch);
                if(allSkillMatch == true){
                    filteredSkilledContact.add(contactId);
                }
            }
        } 
        else if(contactIdWithSkill.size() > 0 && searchDetailList.filterLogicSkill == 'Or'){
            for(Id contactId : contactIdWithSkill.keySet()){
                Boolean allSkillMatch = false;
                Set<String> contactSkills = contactIdWithSkill.get(contactId);
                for(String skillID : setSkillIds){
                    string strKey = contactId+'#'+skillId;
                    if(contactSkillIDWithRating.containsKey(strKey)){
                        // check the rating is matching
                        integer selectedRating = skillIDWithRating.get(skillId);
                        integer contactSkillRating = contactSkillIDWithRating.get(strKey);
                        if(contactSkillRating >=  selectedRating){
                            allSkillMatch = true;
                        	break;
                        }
                    }
                }
                if(allSkillMatch == true){
                    filteredSkilledContact.add(contactId);
                }
            }
        }
        System.debug('>>>filteredSkilledContact '+filteredSkilledContact);
        return filteredSkilledContact;
    }
    public class PercentageAllocationData{
        @AuraEnabled
        public Date startDate {get;set;}
        @AuraEnabled
        public Date endDate {get;set;}
        @AuraEnabled
        public Decimal percentageAllocation {get;set;}
        @AuraEnabled
        public Decimal monHrs {get;set;}
        @AuraEnabled
        public Decimal tueHrs {get;set;}
        @AuraEnabled
        public Decimal wedHrs {get;set;}
        @AuraEnabled
        public Decimal thrHrs {get;set;}
        @AuraEnabled
        public Decimal friHrs {get;set;}
        @AuraEnabled
        public Decimal satHrs {get;set;}
        @AuraEnabled
        public Decimal sunHrs {get;set;}
        @AuraEnabled
        public Decimal totalHours {get;set;}
        @AuraEnabled
        public pse__Schedule__c schedule {get;set;}
        
    }
    @AuraEnabled 
    public static PercentageAllocationData getPercentageAllocationData (String resourceId , pse__Resource_Request__c resReq){
        system.debug('resourceId:::'+resourceId);
        system.debug('resReq:::'+resReq);
        PercentageAllocationData p = new PercentageAllocationData();
        p.startDate = resReq.pse__Start_Date__c;
        p.endDate = resReq.pse__End_Date__c;
        //integer numberOdDays = startDate.daysBetween(endDate);
        p.percentageAllocation = 50;
        pse__Schedule__c sc = new pse__Schedule__c();
        sc.pse__Start_Date__c =  resReq.pse__Start_Date__c;
        sc.pse__End_Date__c = resReq.pse__End_Date__c;
        //list<PercentageAllocationData> perAllocationList = new list<PercentageAllocationData>();
        Id workCalenderID = [Select pse__Work_Calendar__c from Contact where id =: resourceId].pse__Work_Calendar__c;
        for(pse__Work_Calendar__c wc : [Select pse__Friday_Hours__c,pse__Monday_Hours__c,pse__Saturday_Hours__c,pse__Sunday_Hours__c,
                                        pse__Thursday_Hours__c,pse__Wednesday_Hours__c,pse__Tuesday_Hours__c,pse__Week_Total_Hours__c from
                                        pse__Work_Calendar__c where id =:workCalenderID]){
                                            p.monHrs =  wc.pse__Monday_Hours__c;
                                            p.tueHrs =  wc.pse__Tuesday_Hours__c;
                                            p.wedHrs =  wc.pse__Wednesday_Hours__c;
                                            p.thrHrs =  wc.pse__Thursday_Hours__c;
                                            p.friHrs =  wc.pse__Friday_Hours__c;
                                            p.satHrs =  wc.pse__Saturday_Hours__c;
                                            p.sunHrs =  wc.pse__Sunday_Hours__c;
                                            sc.pse__Monday_Hours__c = wc.pse__Monday_Hours__c;
                                            sc.pse__Tuesday_Hours__c = wc.pse__Tuesday_Hours__c;
                                            sc.pse__Wednesday_Hours__c = wc.pse__Wednesday_Hours__c;
                                            sc.pse__Thursday_Hours__c = wc.pse__Thursday_Hours__c;
                                            sc.pse__Friday_Hours__c = wc.pse__Friday_Hours__c;
                                            sc.pse__Saturday_Hours__c = wc.pse__Saturday_Hours__c;
                                            sc.pse__Sunday_Hours__c = wc.pse__Sunday_Hours__c;
                                        }
        system.debug('sc:::'+sc); 
        p.schedule = sc;
        return p;
    } 
    public static pse.SchedulingStrategyService.ProposedScheduleDetail getAdjustHoursScheduleDetail(pse__Resource_Request__c resReq, Id resId){
        pse.SchedulingStrategyService.AdjustHoursScheduleDetail schDet = new pse.SchedulingStrategyService.AdjustHoursScheduleDetail();
        schDet.startDate = resReq.pse__Start_Date__c;
        schDet.endDate = resReq.pse__End_Date__c;
        schDet.resourceId = resId;
        schDet.respectHoliday=true;
        schDet.scheduledHours = resReq.pse__SOW_Hours__c;
        pse.SchedulingStrategyService ser = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = ser.prepareSchedule(schDet);
        return ps;
    }
    public static pse.SchedulingStrategyService.ProposedScheduleDetail getEndDateLevelScheduleDetail(pse__Resource_Request__c resReq, Id resId){
        pse.SchedulingStrategyService.EndDateLevelScheduleDetail schDet1 = new pse.SchedulingStrategyService.EndDateLevelScheduleDetail();
        schDet1.startDate = resReq.pse__Start_Date__c;
        schDet1.endDate = resReq.pse__End_Date__c;
        schDet1.resourceId = resId;
        schDet1.scheduledHours = resReq.pse__SOW_Hours__c;
        pse.SchedulingStrategyService ser = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = ser.prepareSchedule(schDet1);
        return ps;
    }
    private static pse.SchedulingStrategyService.ProposedScheduleDetail getIgnoreAvailabilityScheduleDetail(pse__Resource_Request__c resReq, Id resId){
        pse.SchedulingStrategyService.IgnoreAvailabilityScheduleDetail schDet = new pse.SchedulingStrategyService.IgnoreAvailabilityScheduleDetail();
        schDet.startDate = resReq.pse__Start_Date__c;
        schDet.endDate = resReq.pse__End_Date__c;
        schDet.resourceId = resId;
        schDet.scheduledHours = resReq.pse__SOW_Hours__c;
        pse.SchedulingStrategyService ser = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = ser.prepareSchedule(schDet);
        return ps;
    }
    
    private static pse.SchedulingStrategyService.ProposedScheduleDetail getCustomScheduleDetail(pse__Resource_Request__c resReq, Id resId, pse__Schedule__c schedule){
        pse.SchedulingStrategyService.CustomScheduleDetail schDet = new pse.SchedulingStrategyService.CustomScheduleDetail();
        schDet.startDate = resReq.pse__Start_Date__c;
        schDet.endDate = resReq.pse__End_Date__c;
        schDet.resourceId = resId;
        schDet.scheduledHours = resReq.pse__SOW_Hours__c;
        pse.SchedulingStrategyService.SchedulePattern patern = new pse.SchedulingStrategyService.SchedulePattern();
        patern.startDate  = resReq.pse__Start_Date__c;
        patern.endDate  = resReq.pse__End_Date__c;
        patern.mondayHours = schedule.pse__Monday_Hours__c;
        patern.tuesdayHours = schedule.pse__Tuesday_Hours__c;
        patern.wednesdayHours  = schedule.pse__Wednesday_Hours__c;
        patern.thursdayHours  = schedule.pse__Thursday_Hours__c;
        patern.fridayHours  = schedule.pse__Friday_Hours__c;
        patern.saturdayHours  = schedule.pse__Saturday_Hours__c;
        patern.sundayHours = schedule.pse__Sunday_Hours__c;
        schDet.schedulePattern = patern;
        pse.SchedulingStrategyService ser = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = ser.prepareSchedule(schDet);
        return ps;
    } 
    private static pse.SchedulingStrategyService.ProposedScheduleDetail getZeroHourScheduleDetail(pse__Resource_Request__c resReq, Id resId){
        pse.SchedulingStrategyService.ZeroHourScheduleDetail schDet = new pse.SchedulingStrategyService.ZeroHourScheduleDetail();
        schDet.startDate = resReq.pse__Start_Date__c;
        schDet.endDate = resReq.pse__End_Date__c;
        schDet.resourceId = resId;
        pse.SchedulingStrategyService ser = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = ser.prepareSchedule(schDet);
        return ps;
    }
    private static pse.SchedulingStrategyService.ProposedScheduleDetail getPercentAllocationScheduleDetail(pse__Resource_Request__c resReq, Id resId,WrapperPercentageAllocationRow rowAllocation,Boolean ignoreHoliday){
        pse.SchedulingStrategyService.PercentAllocationScheduleDetail schDet3 = new pse.SchedulingStrategyService.PercentAllocationScheduleDetail();
        list<pse.SchedulingStrategyService.PercentAllocationRow> perRowLst = new list<pse.SchedulingStrategyService.PercentAllocationRow>();
        pse.SchedulingStrategyService.PercentAllocationRow schPercent = new pse.SchedulingStrategyService.PercentAllocationRow();
        schPercent.endDate = rowAllocation.endDate;
        schPercent.percentAllocated = rowAllocation.percentageAllocation;
        schPercent.startDate = rowAllocation.startDate;
        perRowLst.add(schPercent);
        system.debug('rowAllocation.endDate:::'+rowAllocation.endDate);
        //schDet3.startDate = resReq.pse__Start_Date__c;
        //schDet3.endDate = resReq.pse__End_Date__c;
        schDet3.startDate = rowAllocation.startDate;
        schDet3.endDate = rowAllocation.endDate;
        schDet3.resourceId = resId;
        //schDet3.percentAllocated = rowAllocation.percentageAllocation;
        schDet3.percentAllocationRows = perRowLst;
        schDet3.respectHoliday = ignoreHoliday;
        system.debug('schDet3+++'+schDet3);
        system.debug('schPercent++++'+schPercent);
        pse.SchedulingStrategyService ser3 = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps3 = ser3.prepareSchedule(schDet3);
        return ps3;
    }
    @AuraEnabled 
    public static list<WrapperPercentageAllocationRow> updatePercentAllocationScheduleRows(pse__Resource_Request__c resReq, Id resId,list<WrapperPercentageAllocationRow> lstAllocationRow,Boolean ignoreHoliday,Boolean isUpdated,String assignHoldValue,string role){
        list<WrapperPercentageAllocationRow> updatedRowList = new list<WrapperPercentageAllocationRow>();
        list<Date> startDateLst = new list<Date>();
        list<Date> endDateLst = new list<Date>();
        for(WrapperPercentageAllocationRow rowAllocation : lstAllocationRow){
            Date startDate = rowAllocation.startDate;
            Date endDate = rowAllocation.endDate;
            startDateLst.add(startDate);
            endDatelst.add(endDate);
            system.debug('rowAllocation::'+rowAllocation);
        }
        Boolean isOverLapping = isDateOverLapping(startDateLst,endDatelst);
        if(isUpdated){
            list<pse.SchedulingStrategyService.PercentAllocationRow> perRowLst = new list<pse.SchedulingStrategyService.PercentAllocationRow>(); 
            pse.SchedulingStrategyService.PercentAllocationScheduleDetail schDet3 = new pse.SchedulingStrategyService.PercentAllocationScheduleDetail();
            for(WrapperPercentageAllocationRow row : lstAllocationRow){
                system.debug('isOverLapping:::'+isOverLapping);
                pse__Schedule__c schedule = new pse__Schedule__c();
                pse.SchedulingStrategyService.ProposedScheduleDetail ps = getPercentAllocationScheduleDetail(resReq, resId,row,ignoreHoliday);
                pse.SchedulingStrategyService.SchedulePattern schPattern3 = ps.schedule;
                if((row.startDate >= resReq.pse__Start_Date__c && row.startDate <= resReq.pse__End_Date__c && 
                    row.endDate <= resReq.pse__End_Date__c && row.endDate >= resReq.pse__Start_Date__c) && (isOverLapping)){
                        schedule.pse__Start_Date__c = schPattern3.startDate;
                        schedule.pse__End_Date__c=schPattern3.endDate;
                        schedule.pse__Monday_Hours__c= (schPattern3.mondayHours*row.percentageAllocation)/100;
                        schedule.pse__Tuesday_Hours__c=(schPattern3.tuesdayHours*row.percentageAllocation)/100;
                        schedule.pse__Wednesday_Hours__c=(schPattern3.wednesdayHours*row.percentageAllocation)/100;
                        schedule.pse__Thursday_Hours__c=(schPattern3.thursdayHours*row.percentageAllocation)/100;
                        schedule.pse__Friday_Hours__c=(schPattern3.fridayHours*row.percentageAllocation)/100;
                        schedule.pse__Saturday_Hours__c=(schPattern3.saturdayHours*row.percentageAllocation)/100;
                        schedule.pse__Sunday_Hours__c=(schPattern3.sundayHours*row.percentageAllocation)/100;
                        system.debug('schedule:::'+schedule);
                        row.schedule = schedule;
                        Decimal totalHours = 0;
                        list<pse__Schedule_Exception__c> seList1 = new list<pse__Schedule_Exception__c>();
                        Map<Date,pse__HolidayObj__c> holidayDateMap = getResourceHoliday(schPattern3.startDate,resId,schPattern3.endDate);
                        System.debug('holidayDateMap::::'+holidayDateMap);
                        for(Date startDate = schPattern3.startDate; startDate <= schPattern3.endDate ; ){
                            System.debug('ignoreHoliday::::'+ignoreHoliday);
                            System.debug('holidayDateMap.containsKeystartDate::::'+holidayDateMap.containsKey(startDate));
                            if(ignoreHoliday || !holidayDateMap.containsKey(startDate)){
                                Datetime dt = (DateTime)startDate;
                                String dayOfWeek = dt.format('EEEE');
                                if(dayOfWeek == 'Monday'){
                                    totalHours +=  schedule.pse__Monday_Hours__c;
                                }else if(dayOfWeek == 'Tuesday'){
                                    totalHours += schedule.pse__Tuesday_Hours__c;
                                }else if(dayOfWeek == 'Wednesday'){
                                    totalHours += schedule.pse__Wednesday_Hours__c;
                                }else if(dayOfWeek == 'Thursday'){
                                    totalHours += schedule.pse__Thursday_Hours__c;
                                }else if(dayOfWeek == 'Friday'){
                                    totalHours += schedule.pse__Friday_Hours__c;
                                }else if(dayOfWeek == 'Saturday'){
                                    totalHours += schedule.pse__Saturday_Hours__c;
                                }else if(dayOfWeek == 'Sunday'){
                                    totalHours += schedule.pse__Sunday_Hours__c;
                                }
                            }else{
                                if(holidayDateMap.get(startDate) != Null){
                                    system.debug('startDate::'+startDate);
                                    system.debug('holidayDateMap::'+holidayDateMap);
                                    pse__Schedule_Exception__c scheduleException = new pse__Schedule_Exception__c();
                                    scheduleException.pse__Schedule__c = schedule.id;
                                    //scheduleException.pse__End_Date__c = holidayDateMap.get(schedule.pse__Start_Date__c).pse__Date__c;
                                    scheduleException.pse__Date__c = holidayDateMap.get(startDate).pse__Date__c;
                                    system.debug('Inside Scheule Exception Holiday Map');
                                    Datetime dt = (DateTime)startDate;
                                    String dayOfWeek = dt.format('EEEE');
                                    system.debug('dayOfWeek:::'+dayOfWeek);
                                    if(dayOfWeek == 'Monday'){
                                        system.debug('Monday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Monday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }else if(dayOfWeek == 'Tuesday'){
                                        system.debug('Tuesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Tuesday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c/100;
                                    }else if(dayOfWeek == 'Wednesday'){
                                        system.debug('Wednesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Wednesday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }else if(dayOfWeek == 'Thursday'){
                                        system.debug('Thrusday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Thursday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }else if(dayOfWeek == 'Friday'){
                                        system.debug('Friday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Friday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }else if(dayOfWeek == 'Saturday'){
                                        system.debug('Saturday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Saturday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }else if(dayOfWeek == 'Sunday'){
                                        system.debug('Sunday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        scheduleException.pse__Sunday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                                    }
                                    seList1.add(scheduleException);
                                }
                                if(holidayDateMap.get(startDate).pse__Work_Hours__c != Null){
                                    totalHours += (holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                }
                            }
                            //1 else end
                            startDate = startDate.addDays(1);
                        }   
                        row.totalHours = totalHours;
                        row.exceptionLst = seList1;
                        system.debug('seList'+seList1);
                        updatedRowList.add(row);
                    }else{
                        string errMessage = 'Please Select Correct Date form';
                        AuraHandledException ex = new AuraHandledException(errMessage);
                        ex.setMessage(errMessage);
                        throw ex;
                    }
            }
            system.debug('lstAllocationRow:::'+lstAllocationRow);
            system.debug('updatedRowList:::'+updatedRowList);
            return updatedRowList;
        }else{
            list<pse__Schedule_Exception__c> seList = new list<pse__Schedule_Exception__c>();
            pse__Schedule__c schedul = createSchedule(resReq, resId,ignoreHoliday);
            list<pse__Assignment__c> assignmentLst = new list<pse__Assignment__c>();
            Map<pse__Schedule__c,WrapperPercentageAllocationRow> scheduleMapWithPattern = new Map<pse__Schedule__c,WrapperPercentageAllocationRow>();
            Map<pse__Schedule__c,list<pse__Schedule_Exception__c>> mapScheduleWithScheduleException = new Map<pse__Schedule__c,list<pse__Schedule_Exception__c>>();
            list<pse__Schedule__c> scheduleLst = new list<pse__Schedule__c>();
            Integer count = 0;
            Map<Integer,pse__Schedule_Exception__c> countWithException = new Map<Integer,pse__Schedule_Exception__c>();
            for(WrapperPercentageAllocationRow row : lstAllocationRow){
                if((row.startDate >= resReq.pse__Start_Date__c && row.startDate <= resReq.pse__End_Date__c && 
                    row.endDate <= resReq.pse__End_Date__c && row.endDate >= resReq.pse__Start_Date__c) && (isOverLapping)){
                        pse.SchedulingStrategyService.ProposedScheduleDetail ps = getPercentAllocationScheduleDetail(resReq, resId,row,ignoreHoliday);
                        pse.SchedulingStrategyService.SchedulePattern schPattern3 = ps.schedule;
                        Decimal totalHours = 0;
                        pse__Schedule_Exception__c excp ;
                        Date starDate ;
                        Date endDate ;
                        Date expDate ;
                        Map<Date,pse__HolidayObj__c> holidayDateMap = getResourceHoliday(schPattern3.startDate,resId,schPattern3.endDate);
                        for(Date startDate = schPattern3.startDate; startDate <= schPattern3.endDate ; ){
                            if(ignoreHoliday || !holidayDateMap.containsKey(startDate)){
                                system.debug('INDIDE LOOPPP');
                                if(startDate == schPattern3.startDate || (excp != Null && expDate != null && expDate.addDays(1) == startDate)){
                                    excp = new pse__Schedule_Exception__c();
                                    starDate = startDate;
                                    endDate = startDate;
                                    count++;
                                    countWithException.put(count,excp);
                                }
                                if(excp != null){
                                    excp.pse__Schedule__c = schedul.id;
                                    excp.pse__Monday_Hours__c = (schPattern3.mondayHours*row.percentageAllocation)/100;
                                    excp.pse__Tuesday_Hours__c = (schPattern3.tuesdayHours*row.percentageAllocation)/100;
                                    excp.pse__Wednesday_Hours__c = (schPattern3.wednesdayHours*row.percentageAllocation)/100;
                                    excp.pse__Thursday_Hours__c = (schPattern3.thursdayHours*row.percentageAllocation)/100;
                                    excp.pse__Friday_Hours__c = (schPattern3.fridayHours*row.percentageAllocation)/100;
                                    excp.pse__Saturday_Hours__c = (schPattern3.saturdayHours*row.percentageAllocation)/100;
                                    excp.pse__Sunday_Hours__c = (schPattern3.sundayHours*row.percentageAllocation)/100;
                                    excp.pse__Date__c = starDate;
                                    excp.pse__End_Date__c = endDate;
                                    countWithException.put(count,excp);
                                    system.debug('starDate:::'+starDate);
                                    system.debug('endDate:::'+endDate);
                                    endDate = endDate.addDays(1);
                                    seList.add(excp);
                                }
                                
                            }else{
                                system.debug('Inside Else');
                                excp = new pse__Schedule_Exception__c();
                                starDate = startDate;
                                expDate = starDate;
                                count++;
                                countWithException.put(count,excp);
                                if(holidayDateMap.get(startDate) != Null){
                                    system.debug('startDate::'+startDate);
                                    system.debug('holidayDateMap::'+holidayDateMap);
                                    //pse__Schedule_Exception__c scheduleException = new pse__Schedule_Exception__c();
                                    excp.pse__Schedule__c = schedul.id;
                                    //scheduleException.pse__End_Date__c = holidayDateMap.get(schedule.pse__Start_Date__c).pse__Date__c;
                                    //excp.pse__Date__c = holidayDateMap.get(startDate).pse__Date__c;
                                    excp.pse__Date__c = startDate;
                                    system.debug('Inside Scheule Exception Holiday Map');
                                    Datetime dt = (DateTime)startDate;
                                    String dayOfWeek = dt.format('EEEE');
                                    system.debug('dayOfWeek:::'+dayOfWeek);
                                    if(dayOfWeek == 'Monday'){
                                        system.debug('Monday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Monday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Tuesday'){
                                        system.debug('Tuesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Tuesday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Wednesday'){
                                        system.debug('Wednesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Wednesday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Thursday'){
                                        system.debug('Thrusday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Thursday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Friday'){
                                        system.debug('Friday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Friday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Saturday'){
                                        system.debug('Saturday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Saturday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }else if(dayOfWeek == 'Sunday'){
                                        system.debug('Sunday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                                        excp.pse__Sunday_Hours__c=(holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                                    }
                                    starDate = starDate.addDays(1);
                                    if(excp != null){
                                        countWithException.put(count,excp);
                                        seList.add(excp);    
                                    }
                                }
                            }
                            system.debug('countWithException:::::'+countWithException);
                            startDate = startDate.addDays(1);
                        }
                        row.exceptionLst = seList;
                    }
                
                else{
                    string errMessage = 'Please Select Correct Date form';
                    AuraHandledException ex = new AuraHandledException(errMessage);
                    ex.setMessage(errMessage);
                    throw ex;
                }
            }
            system.debug('mapScheduleWithScheduleException:::::111'+mapScheduleWithScheduleException);
            if(schedul.id != null ){
                system.debug('countWithException::::'+countWithException);
                insert countWithException.values();
                pse__Assignment__c assignment = new pse__Assignment__c();
                assignment.pse__Schedule__c = schedul.Id;
                assignment.pse__Resource__c = resId;
                assignment.pse__Project__c = resReq.pse__Project__c;
                assignment.pse__Percent_Allocated__c = 100;
                if(role == null || role == ''){
                    assignment.pse__Role__c = resReq.pse__Resource_Role__c;
                }else{
                    assignment.pse__Role__c = role;
                }
                if(resReq.pse__Requested_Bill_Rate__c != null){
                    assignment.pse__Bill_Rate__c = resReq.pse__Requested_Bill_Rate__c;
                }
                else if(resReq.pse__Suggested_Bill_Rate__c != null){
                    assignment.pse__Bill_Rate__c = Decimal.valueOf(resReq.pse__Suggested_Bill_Rate__c);
                }
                else if(resReq.pse__Planned_Bill_Rate__c != null){
                    assignment.pse__Bill_Rate__c = resReq.pse__Planned_Bill_Rate__c;
                }
                if(assignHoldValue == 'Assign' ){
                    insert assignment; 
                    pse__Resource_Request__c rr = new pse__Resource_Request__c();
                    rr.Id = resReq.Id;
                    rr.pse__Resource_Held__c = false;
                    rr.pse__Status__c = 'Assigned';
                    rr.pse__Preferred_Schedule__c = schedul.Id;
                    rr.pse__Assignment__c = assignment.Id;
                    rr.pse__Staffer_Resource__c = resId;
					update rr;
                    
                }else if(assignHoldValue == 'hold'){
                    pse__Resource_Request__c rr = new pse__Resource_Request__c();
                    rr.Id = resReq.Id;
                    rr.pse__Resource_Held__c = true;
                    rr.pse__Status__c = 'Hold';
                    rr.pse__Preferred_Schedule__c = schedul.Id;
                    rr.pse__Staffer_Resource__c = resId;
					update rr; 
                }
            }
        }
        return lstAllocationRow;
    }
    public static pse__Schedule__c createSchedule(pse__Resource_Request__c resReq , Id resId ,Boolean respectHoliday){
        pse__Schedule__c schedule = new pse__Schedule__c();
        pse.SchedulingStrategyService.PercentAllocationScheduleDetail schDet3 = new pse.SchedulingStrategyService.PercentAllocationScheduleDetail();
        list<pse.SchedulingStrategyService.PercentAllocationRow> perRowLst = new list<pse.SchedulingStrategyService.PercentAllocationRow>();
        pse.SchedulingStrategyService.PercentAllocationRow schPercent = new pse.SchedulingStrategyService.PercentAllocationRow();
        schPercent.endDate = resReq.pse__End_Date__c;
        schPercent.percentAllocated = 100;
        schPercent.startDate = resReq.pse__Start_Date__c;
        perRowLst.add(schPercent);
        //system.debug('rowAllocation.endDate:::'+rowAllocation.endDate);
        //schDet3.startDate = resReq.pse__Start_Date__c;
        //schDet3.endDate = resReq.pse__End_Date__c;
        schDet3.startDate = resReq.pse__Start_Date__c;
        schDet3.endDate = resReq.pse__End_Date__c;
        schDet3.resourceId = resId;
        //schDet3.percentAllocated = rowAllocation.percentageAllocation;
        schDet3.percentAllocationRows = perRowLst;
        schDet3.respectHoliday = respectHoliday;
        system.debug('schDet3+++'+schDet3);
        system.debug('schPercent++++'+schPercent);
        pse.SchedulingStrategyService ser3 = new pse.SchedulingStrategyService();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps3 = ser3.prepareSchedule(schDet3);
        pse.SchedulingStrategyService.SchedulePattern schPattern3 = ps3.schedule;
        schedule.pse__Start_Date__c = schPattern3.startDate;
        schedule.pse__End_Date__c=schPattern3.endDate;
        schedule.pse__Monday_Hours__c= schPattern3.mondayHours;
        schedule.pse__Tuesday_Hours__c= schPattern3.tuesdayHours;
        schedule.pse__Wednesday_Hours__c= schPattern3.wednesdayHours;
        schedule.pse__Thursday_Hours__c= schPattern3.thursdayHours;
        schedule.pse__Friday_Hours__c= schPattern3.fridayHours;
        schedule.pse__Saturday_Hours__c= schPattern3.saturdayHours;
        schedule.pse__Sunday_Hours__c= schPattern3.sundayHours;
        insert schedule;	
        return schedule;
    }
    
    public static Boolean isDateOverLapping(list<Date> startDate,list<Date> endDate){
        Boolean isOverLapping = true;
        for(Integer i = 0 ; i < startDate.size() ; i++ ){
            for(Integer j = 0 ; j < endDate.size() ; j++){
                if(i == j){
                    continue ;
                }else if((startDate[i] <= endDate[j] && startDate[j] <= endDate[i]) || (endDate[i] <= startDate[j] && endDate[j] <= startDate[i])){
                    isOverLapping = false;
                }
            }
        }
        return isOverLapping;
    }
    
    @AuraEnabled 
    public static WrapperPercentageAllocationRow createPercentAllocationScheduleRows(pse__Resource_Request__c resReq, Id resId,Boolean ignoreHoliday, decimal allocation, Integer indexForDeletionOfRow ){
        list<pse.SchedulingStrategyService.PercentAllocationRow> perRowLst = new list<pse.SchedulingStrategyService.PercentAllocationRow>(); 
        pse.SchedulingStrategyService.PercentAllocationScheduleDetail schDet3 = new pse.SchedulingStrategyService.PercentAllocationScheduleDetail();
        WrapperPercentageAllocationRow row = new WrapperPercentageAllocationRow();
        row.percentageAllocation = allocation;
        row.startDate = resReq.pse__Start_Date__c;
        row.endDate = resReq.pse__End_Date__c;
        row.indexForDeletion = indexForDeletionOfRow;
        row.isSelectedCheck = true;
        pse__Schedule__c schedule = new pse__Schedule__c();
        pse.SchedulingStrategyService.ProposedScheduleDetail ps = getPercentAllocationScheduleDetail(resReq, resId,row,ignoreHoliday);
        pse.SchedulingStrategyService.SchedulePattern schPattern3 = ps.schedule;
        schedule.pse__Start_Date__c = schPattern3.startDate;
        schedule.pse__End_Date__c=schPattern3.endDate;
        schedule.pse__Monday_Hours__c=schPattern3.mondayHours;
        schedule.pse__Tuesday_Hours__c=schPattern3.tuesdayHours;
        schedule.pse__Wednesday_Hours__c=schPattern3.wednesdayHours;
        schedule.pse__Thursday_Hours__c=schPattern3.thursdayHours;
        schedule.pse__Friday_Hours__c=schPattern3.fridayHours;
        schedule.pse__Saturday_Hours__c=schPattern3.saturdayHours;
        schedule.pse__Sunday_Hours__c=schPattern3.sundayHours;
        row.schedule = schedule;
        Decimal totalHours = 0;
        list<pse__Schedule_Exception__c> seList = new list<pse__Schedule_Exception__c>();
        Map<Date,pse__HolidayObj__c> holidayDateMap = getResourceHoliday(schPattern3.startDate,resId,schPattern3.endDate);
        for(Date startDate = schPattern3.startDate; startDate <= schPattern3.endDate ; ){
            if(ignoreHoliday || !holidayDateMap.containsKey(startDate)){
                Datetime dt = (DateTime)startDate;
                String dayOfWeek = dt.format('EEEE');
                if(dayOfWeek == 'Monday'){
                    totalHours +=  schedule.pse__Monday_Hours__c;
                }else if(dayOfWeek == 'Tuesday'){
                    totalHours += schedule.pse__Tuesday_Hours__c;
                }else if(dayOfWeek == 'Wednesday'){
                    totalHours += schedule.pse__Wednesday_Hours__c;
                }else if(dayOfWeek == 'Thursday'){
                    totalHours += schedule.pse__Thursday_Hours__c;
                }else if(dayOfWeek == 'Friday'){
                    totalHours += schedule.pse__Friday_Hours__c;
                }else if(dayOfWeek == 'Saturday'){
                    totalHours += schedule.pse__Saturday_Hours__c;
                }else if(dayOfWeek == 'Sunday'){
                    totalHours += schedule.pse__Sunday_Hours__c;
                }
            }else{
                if(holidayDateMap.get(startDate) != Null){
                    system.debug('startDate::'+startDate);
                    system.debug('holidayDateMap::'+holidayDateMap);
                    pse__Schedule_Exception__c scheduleException = new pse__Schedule_Exception__c();
                    scheduleException.pse__Schedule__c = schedule.id;
                    //scheduleException.pse__End_Date__c = holidayDateMap.get(schedule.pse__Start_Date__c).pse__Date__c;
                    scheduleException.pse__Date__c = holidayDateMap.get(startDate).pse__Date__c;
                    system.debug('Inside Scheule Exception Holiday Map');
                    Datetime dt = (DateTime)startDate;
                    String dayOfWeek = dt.format('EEEE');
                    system.debug('dayOfWeek:::'+dayOfWeek);
                    if(dayOfWeek == 'Monday'){
                        system.debug('Monday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Monday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Tuesday'){
                        system.debug('Tuesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Tuesday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Wednesday'){
                        system.debug('Wednesday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Wednesday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Thursday'){
                        system.debug('Thrusday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Thursday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Friday'){
                        system.debug('Friday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Friday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Saturday'){
                        system.debug('Saturday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Saturday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }else if(dayOfWeek == 'Sunday'){
                        system.debug('Sunday'+holidayDateMap.get(startDate).pse__Work_Hours__c);
                        scheduleException.pse__Sunday_Hours__c=holidayDateMap.get(startDate).pse__Work_Hours__c;
                    }
                    seList.add(scheduleException);
                }
                if(holidayDateMap.get(startDate).pse__Work_Hours__c != Null){
                    totalHours += (holidayDateMap.get(startDate).pse__Work_Hours__c*row.percentageAllocation)/100;
                }
            }
            startDate = startDate.addDays(1);
        }   
        row.totalHours = totalHours;
        row.exceptionLst = seList;
        return row;
    }
    @AuraEnabled 
    public static list<WrapperPercentageAllocationRow> getPercentAllocationRows (pse__Resource_Request__c resReq, Id resId,list<WrapperPercentageAllocationRow> lstAllocationRow,Boolean ignoreHoliday,Integer indexForDeletionOfRow){
        if(lstAllocationRow == null || lstAllocationRow.isEmpty()){
            lstAllocationRow = new list<WrapperPercentageAllocationRow>();
        }
        lstAllocationRow.add(createPercentAllocationScheduleRows( resReq, resId, ignoreHoliday,100,indexForDeletionOfRow));
        system.debug('lstAllocationRow::::::'+lstAllocationRow);
        return lstAllocationRow;
    } 
    
    public static Map<Date,pse__HolidayObj__c> getResourceHoliday(Date startDate,Id resId,Date endDate ){
        Map<Date,pse__HolidayObj__c> holidayDateMap = new map<Date,pse__HolidayObj__c>();
        Id workCalender = [Select pse__Work_Calendar__c from Contact where id =:resId].pse__Work_Calendar__c;
        While(startDate<endDate){
            for(pse__HolidayObj__c ps : [Select pse__Date__c,pse__Work_Hours__c from pse__HolidayObj__c where pse__Work_Calendar__c =:workCalender]){
                if(startDate == ps.pse__Date__c){
                    holidayDateMap.put(startDate,ps);
                }
            }
            startDate = startDate.addDays(1);
        }
        return holidayDateMap;
    }
    @AuraEnabled
    public static void sendEmailToParticularResource(String emailAdd, String emailSub, String emailBody){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {emailAdd};
            message.subject = emailSub;
        message.plainTextBody = emailBody;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    @AuraEnabled
    public static List<pse__Assignment__c> displayAssignmentsBasedOnResource(String resourceRecordId){
        List<pse__Assignment__c> assignmentList = [SELECT Id, Name, pse__Start_Date__c, pse__End_Date__c, pse__Status__c, 
                                                   pse__Role__c, pse__Project__c, pse__Project__r.Name
                                                   FROM pse__Assignment__c 
                                                   WHERE pse__Resource__c =: resourceRecordId ORDER BY pse__Start_Date__c DESC LIMIT 20];
        return assignmentList;
    }
    @AuraEnabled
    public static SkillCertificationRatingWithRecordTypes getCompetenceQualifications(String resourceRecordId){
        Set<Id> skillCertificationIdSet = new Set<Id>();
        List<pse__Skill_Certification_Rating__c> skillRatingList = new List<pse__Skill_Certification_Rating__c>();
        List<pse__Skill_Certification_Rating__c> certificationRatingList = new List<pse__Skill_Certification_Rating__c>();
        Map<Id, String> skillCertificationWithIdMap = new Map<Id, String>();
        for(pse__Skill_Certification_Rating__c p : [SELECT Id, pse__Skill_Certification__c, pse__Skill_Certification__r.Name, pse__Rating__c, pse__Notes__c, pse__Evaluation_Date__c, pse__Expiration_Date__c, pse__Resource__c, LastModifiedDate FROM pse__Skill_Certification_Rating__c WHERE pse__Resource__c =: resourceRecordId]){
            skillCertificationIdSet.add(p.pse__Skill_Certification__c);
        }
        for(pse__Skill__c p : [SELECT Id, RecordTypeId, RecordType.Name FROM pse__Skill__c WHERE Id In: skillCertificationIdSet]){
            if(p.recordType.Name == 'Skill'){
                skillCertificationWithIdMap.put(p.Id, 'Skill');
            }
            else if(p.recordType.Name == 'Certification'){
                skillCertificationWithIdMap.put(p.Id, 'Certification');
            }
        }
        for(pse__Skill_Certification_Rating__c p : [SELECT Id, pse__Skill_Certification__c, pse__Skill_Certification__r.Name, pse__Rating__c, pse__Notes__c, pse__Evaluation_Date__c, pse__Expiration_Date__c, pse__Resource__c, LastModifiedDate FROM pse__Skill_Certification_Rating__c WHERE pse__Resource__c =: resourceRecordId]){
            if(skillCertificationWithIdMap.get(p.pse__Skill_Certification__c) == 'Skill'){
                skillRatingList.add(p);
            }
            else if(skillCertificationWithIdMap.get(p.pse__Skill_Certification__c) == 'Certification'){
                certificationRatingList.add(p);
            }
        }
        System.debug('skillRatingList::::'+skillRatingList);
        System.debug('certificationRatingList::::'+certificationRatingList);
        SkillCertificationRatingWithRecordTypes skr = new SkillCertificationRatingWithRecordTypes();
        skr.skillRatList = skillRatingList;
        skr.certificationRatList = certificationRatingList;
        return skr;
    }
    public class SkillCertificationRatingWithRecordTypes{
        @AuraEnabled
        public List<pse__Skill_Certification_Rating__c> skillRatList{get;set;}
        @AuraEnabled
        public List<pse__Skill_Certification_Rating__c> certificationRatList{get;set;}
    }
    public class WrapperPercentageAllocationRow {
        @AuraEnabled
        public Date startDate {get;set;}
        @AuraEnabled
        public Date endDate {get;set;}
        @AuraEnabled
        public Decimal percentageAllocation {get;set;}
        @AuraEnabled
        public Pse__Schedule__c schedule {get;set;}
        @AuraEnabled
        public Decimal totalHours {get;set;}
        @AuraEnabled
        public Integer indexForDeletion {get;set;}
        @AuraEnabled
        public Boolean isSelectedCheck {get;set;}
        @AuraEnabled
        public list<pse__Schedule_Exception__c> exceptionLst {get;set;}
        
        
    }
    //Method to get count of assignment based on project complexity
    public static map<id,list<Integer>> getComplexProjectCount(list<Contact> resLst, Date startDate , Date endDate){
        System.debug('resLst::::'+resLst);
        System.debug('startDate::::'+startDate);
        System.debug('endDate::::'+endDate);
        Map<id,list<Integer>> resorceWithAssignmentCount = new map<id,list<Integer>>();
        integer lowCount = 0;
        integer meduimCount = 0;
        integer highCount = 0;
        map<id,list<pse__Assignment__c>> resourceAssignmentMap = new map<id,list<pse__Assignment__c>>();
        for(pse__Assignment__c assignmet : [SELECT id,pse__Project__c,pse__Project__r.Project_Complexity__c, pse__Resource__c FROM 
                                            pse__Assignment__c WHERE pse__Resource__c IN : resLst And (pse__Start_Date__c >= :startDate AND pse__End_Date__c <= :endDate) AND pse__Project__c != null AND pse__Project__r.Project_Complexity__c != Null]){
                                                if(!resourceAssignmentMap.containsKey(assignmet.pse__Resource__c)){
                                                    resourceAssignmentMap.put(assignmet.pse__Resource__c,new list<pse__Assignment__c>()); 
                                                }
                                                resourceAssignmentMap.get(assignmet.pse__Resource__c).add(assignmet);
                                            }
        System.debug('resourceAssignmentMap::::'+resourceAssignmentMap);
        if(!resourceAssignmentMap.isEmpty()){
            for(id resourceId : resourceAssignmentMap.keyset()){
                list<Integer> countLst = new list<Integer>();
                //low
                countLst.add(0);
                //Medium
                countLst.add(0);
                //High
                countLst.add(0);
                set<id> allreadyCountProj = new set<id>();
                for(pse__Assignment__c assignmet : resourceAssignmentMap.get(resourceId)){
                    if(!allreadyCountProj.contains(assignmet.pse__Project__c)){
                        if(assignmet.pse__Project__r.Project_Complexity__c == 'Low'){
                            countLst[0] = countLst[0]+1;
                        }else if(assignmet.pse__Project__r.Project_Complexity__c == 'Medium'){
                            countLst[1] = countLst[1]+1;
                        }else if(assignmet.pse__Project__r.Project_Complexity__c == 'High'){
                            countLst[2] = countLst[2]+1;
                        }
                        allreadyCountProj.add(assignmet.pse__Project__c);
                    }
                }
                resorceWithAssignmentCount.put(resourceId,countLst);
            }
        }
        System.debug('resorceWithAssignmentCount::::'+resorceWithAssignmentCount);
        return resorceWithAssignmentCount;
    }
}
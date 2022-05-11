/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       ContactTriggerHandler
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/23/2018     1.0            Prasanth               Initial Release
07/08/2020 	   1.1	   Deloitte - Abhishek			 Added logic to create Service Resource records when a PSA Resource Contact 
													 is created in system
02/05/2021	   1.2	   Deloitte - Abhishek			 Added new methods - accountContactRelOnInsert, accountContactRelOnUpdate
												     for Account Contact Relation. Story #9911522
02/08/2021	   1.3	   Deloitte - Abhishek           Added new method - updateSharingAccount for Story #9911522. This field is used to drive
											         Visibility in PRM - Sharing Sets
-------------------------------------------------------------------------------------------------------------------------- 
*/
public class ContactTriggerHandler
{   
    public static void callBeforeMethods(List<Contact> Contacts)
    {
        if(trigger.isbefore && trigger.isinsert)
        {
            beforeInsert(Contacts);
        }
         if(trigger.isbefore && trigger.isupdate)
        {
            beforeUpdate(Contacts);
        }
    }
    
    public static void callAfterUpdate(Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap)
    {        
        updateTimeZoneOnSA(oldContactMap,newContactMap);
    }
    
    //before Insert logic
    public static void beforeInsert(List<Contact> Contacts)
    {
        for(Contact A:Contacts)
        {
            if(A.AccountId != NULL)
            {
                A.Account_Id__c = A.AccountId;
            }
        }
    
    
    //Bulk Load via API --> Prevent duplciate records from entering system --> Start    
    Map<string, contact> retainOneMainContactEmailValid = new Map<string, contact>();
    Map<string, contact> retainOneMainContactPhoneValid = new Map<string, contact>();

    for(Contact c: Contacts){
        
        if(c.AccountId != null || c.AccountId != '')
        {
            //Check if Email repeats
            if((c.Email != null || c.Email != '') && (c.Primary_Phone__c == null || c.Primary_Phone__c == ''))
            {
                String EmailKey = c.FirstName+c.LastName+c.AccountId+c.Email;
                if(!retainOneMainContactEmailValid.containsKey(EmailKey))
                {
                    retainOneMainContactEmailValid.put(EmailKey,c);
                }
                else{
                    c.addError('Duplicate contact found , Please use another email id');
                }
            }
            
            //Check if Phone repeats
            if((c.Email == null || c.Email == '') && (c.Primary_Phone__c != null || c.Primary_Phone__c != ''))
            {
                String PhoneKey = c.FirstName+c.LastName+c.AccountId+c.Primary_Phone__c;
                if(!retainOneMainContactPhoneValid.containsKey(PhoneKey))
                {
                    retainOneMainContactPhoneValid.put(PhoneKey,c);
                }
                else{
                    c.addError('Duplicate contact found, Please use another phone number');
                }
            }    
        }   
    }
    //Bulk Load via API --> Prevent duplciate records from entering system --> End
    }     
    
    //before update logic
    public static void beforeUpdate(List<Contact> Contacts)
    {
        for(Contact A1:Contacts)
        {    
            if(A1.AccountId  !=  A1.Account_Id__c)
            {
                A1.Account_Id__c = A1.AccountId;
            }  
        }  
        
    }
    
    //[Deloitte Consulting - Abhishek Kawle] : 02/05/2021: Added new method to update the Sharing Account custom field on Contact
    //										   This field drives visibility under PRM Sharing Sets. Story #9911522    
    public static void updateSharingAccount(Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap){
        Set<Id> contactSharingAccSet = new Set<Id>();
        for(Contact eaCon: newContactMap.values()){
            if(eaCon.FBE_FPRM_Reseller_Account__c != oldContactMap.get(eaCon.Id).FBE_FPRM_Reseller_Account__c
               || eaCon.AccountId != oldContactMap.get(eaCon.Id).AccountId){
                   contactSharingAccSet.add(eaCon.Id);
               }
        }
        
        if(!contactSharingAccSet.isEmpty()){
            Map<Id, User> conUserMap = new Map<Id, User>();
            for(User eaUser : [SELECT Id, ContactId, Profile.Name, FBE_FPRM_OnlineRole__c FROM User WHERE ContactId IN :contactSharingAccSet]){
                conUserMap.put(eaUser.ContactId, eaUser);
            }
              
            List<Contact> updateContactsList = new List<Contact>();
            for(Id contactId : contactSharingAccSet){
                Contact contact = newContactMap.get(contactId);
                if(conUserMap.containsKey(contactId)){
                    User eachUser = conUserMap.get(contactId);
                    if(eachUser != null && contact.AccountId != oldContactMap.get(contactId).AccountId){
                        if((eachUser.Profile.Name == 'FBE FPRM Partner Distributor' || eachUser.Profile.Name == 'FBE FPRM Partner Reseller') &&
                           (eachUser.FBE_FPRM_OnlineRole__c == 'Site Admin' || eachUser.FBE_FPRM_OnlineRole__c == 'Sales Rep All Opty')){
                               contact.FBE_FPRM_Sharing_Account__c = contact.AccountId;
                           }
                    }
                    
                    if(eachUser != null && contact.FBE_FPRM_Reseller_Account__c != oldContactMap.get(contactId).FBE_FPRM_Reseller_Account__c){
                        if(eachUser.Profile.Name == 'FBE FPRM Partner Disty Managed' && 
                        (eachUser.FBE_FPRM_OnlineRole__c == 'Disty Managed Site Admin' || eachUser.FBE_FPRM_OnlineRole__c == 'Disty Managed Sales Rep All Opty')){
                            contact.FBE_FPRM_Sharing_Account__c = contact.FBE_FPRM_Reseller_Account__c;
                        }
                    }
                }
            }
        }
    }
    
    public static void createServiceResource(List<Contact> contacts){
        
        List<ServiceResource> srList = new List<ServiceResource>();
        Id psaResourceRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PSA_Resource').getRecordTypeId();
        Set<id> userIdSet = new Set<id>();
        Map<Id, Id> userToProfileMap = new Map<Id,Id>();
        
        List<Profile> userProfile = [SELECT Id, Name 
                               FROM Profile 
                               WHERE Name = 'PSA Technical Resource'];
        
        for(Contact eaContact : contacts){
            userIdSet.add(eaContact.pse__Salesforce_User__c);
        }
        
        for(User eaUser : [SELECT Id, ProfileId FROM User WHERE Id IN :userIdSet]){
            userToProfileMap.put(eaUser.Id, eaUser.ProfileId);
        }
        
        for(Contact eachContact : contacts){
            if(eachContact.RecordTypeId == psaResourceRecordType && eachContact.pse__Salesforce_User__c != null 
               && userToProfileMap.size() > 0 && !userProfile.isEmpty()){ 
                   
                   if(userToProfileMap.get(eachContact.pse__Salesforce_User__c) == userProfile[0].Id){
                       
                       ServiceResource sr = new ServiceResource(
                           Name = eachContact.FirstName + ' ' + eachContact.LastName,
                           //AccountId = cntct.AccountId,
                           IsActive = true,
                           ResourceType = 'T',
                           FBE_Contact__c = eachContact.Id,
                           RelatedRecordId = eachContact.pse__Salesforce_User__c
                       );
                       
                       srList.add(sr);
                   } 
               }
        }
        
        
        System.debug('Service Resources to be inserted: '+srList);
        if(!srList.isEmpty()){
            insert srList;
        }
    } 
    
    //Added for the story #9873713 to match Contact(Assignee)'s timezone with the ServiceAppointment's 'Resource Time_Zone' field
    //here updating Res_timeZone__c field to reflect in the ServiceAppointment  'Resource Time_Zone' formula field
    public static void updateTimeZoneOnSA(Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap){
        List<ServiceAppointment> saUpdateList = new List<ServiceAppointment>();
        Set<Id> contIds = new Set<Id>();
        
        for(Contact cont: newContactMap.values()){
            if(cont.TimeZone__c!= oldContactMap.get(cont.Id).TimeZone__c){
                contIds.add(cont.Id);
            }
        }
        
        Map<String,String> valueLabelMap = new Map<String,String>(); 
		Schema.DescribeFieldResult field = Contact.TimeZone__c.getDescribe();
        for(Schema.PicklistEntry entry : field.getPicklistValues()){
        	valueLabelMap.put(entry.getValue(),entry.getLabel());  
        }
        
        if(!contIds.isEmpty()){
        List<ServiceAppointment> salist = [Select id,Res_timeZone__c,Assignee__c from ServiceAppointment where Assignee__c IN : contIds];
            
        String labelName;       
        for(ServiceAppointment sa :salist){
            labelName = valueLabelMap.get(newContactMap.get(sa.Assignee__c).TimeZone__c);                
            sa.Res_timeZone__c = labelName;
            saUpdateList.add(sa);
        }
        //try{
        update saUpdateList;
         //}catch(Exception e){system.debug('error occured'+e.getMessage());}
        }
    }
    
    public static void preventCDLfieldupdate(Map<Id,Contact> oldMap, List<Contact> newConList){
        List<Contact> newContacts = (List<Contact>) newConList;
        Map<Id, Contact> oldContactsMap = (Map<Id, Contact>)oldMap;
        Set<Id> serviceresIds = new Set<id>();
        Set<Id> contactIds = new Set<Id>();
        List<ServiceResource> srList = [SELECT Id, Name, FBE_Contact__c, (select id, ServiceTerritory.Name, effectivestartdate, serviceterritoryid, serviceresource.name, effectiveenddate from ServiceTerritories Where (EffectiveStartDate <= TODAY AND EffectiveEndDate >= TODAY)) FROM ServiceResource];
        System.debug('srList'+srList);
        for(ServiceResource sr: srList)
        {
            if(sr.ServiceTerritories.size() > 0)
            {
            contactIds.add(sr.FBE_Contact__c);
            System.debug('contactIds'+contactIds);
            }
        }
       
        for(Contact conrec : newContacts)
        {
            if(contactIds.contains(conrec.Id))
            {
                Contact actualrecord = oldContactsMap.get(conrec.ID);
                if (conrec.FBE_IDS_RDC__c != oldContactsMap.get(conrec.Id).FBE_IDS_RDC__c)
                {
                    conrec.addError('The associated ServiceResource has the different ServiceTerritory compared to the selected field value');
                }
            }
        }
    }
    
    //[Deloitte Consulting - Abhishek Kawle] : 02/05/2021: Added new method to insert Account Contact relation on new Contacts with 
    //										   Reseller Account. Story #9911522
    public static void accountContactRelOnInsert(List<Contact> conList){
        List<AccountContactRelation> accContactList = new List<AccountContactRelation>();
        
        for(Contact eaCon : conList){
            if(eaCon.FBE_FPRM_Reseller_Account__c != null){
                
                AccountContactRelation accConObj = new AccountContactRelation();
                accConObj.AccountId = eaCon.FBE_FPRM_Reseller_Account__c;
                accConObj.ContactId = eaCon.Id;
                
                accContactList.add(accConObj);
            }            
        }
        
        if(!accContactList.isEmpty()){
            try{    
                insert accContactList;
            }
            
            catch(Exception e){
                System.debug('Error occured during Account Contact Relation Insert: '+ e.getMessage());
            }
        }
    }
    
    //[Deloitte Consulting - Abhishek Kawle] : 02/05/2021: Added new method to update / delete Account Contact relation 
    //										   when Reseller Account and Primary Account field is updated.
    //										   This method also updates a custom field - 'Sharing Account' on the Contact whenever
    //										   Primary Account / Reseller Account is updated based on Associated User
    //										   Story #9911522
    public static void accountContactRelOnUpdate(Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap){
        List<AccountContactRelation> accContactList = new List<AccountContactRelation>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact eaCon: newContactMap.values()){
            if(eaCon.FBE_FPRM_Reseller_Account__c != oldContactMap.get(eaCon.Id).FBE_FPRM_Reseller_Account__c
               || eaCon.AccountId != oldContactMap.get(eaCon.Id).AccountId){
                   contactIds.add(eaCon.Id);
               }
        }
        
        if(!contactIds.isEmpty()){
            Map<Id, List<AccountContactRelation>> exAccConRelMap = new Map<Id, List<AccountContactRelation>>();
            Map<Id, List<Id>> mapOfContWithAccIds = new Map<Id, List<Id>>();
            for(AccountContactRelation eachAccRel : [SELECT Id, AccountId,ContactId FROM AccountContactRelation
                                                     WHERE ContactId IN :contactIds])
            {
                if(exAccConRelMap.containsKey(eachAccRel.ContactId)){
                    exAccConRelMap.get(eachAccRel.ContactId).add(eachAccRel);
                    mapOfContWithAccIds.get(eachAccRel.ContactId).add(eachAccRel.AccountId);
                }
                
                else{
                    exAccConRelMap.put(eachAccRel.ContactId, new List<AccountContactRelation>{ eachAccRel });
                    mapOfContWithAccIds.put(eachAccRel.ContactId, new List<Id>{eachAccRel.AccountId});
                }
            }
            
            List<AccountContactRelation> delAccConList = new List<AccountContactRelation>();
            List<AccountContactRelation> insAccConList = new List<AccountContactRelation>();
            Map<String,AccountContactRelation> mapOfconAccStrWithRecord = new Map<String,AccountContactRelation>();
            
            for(Id conId : contactIds){
                if(exAccConRelMap.containsKey(conId)){                    
                    for(AccountContactRelation eaRel : exAccConRelMap.get(conId)){

                        //Execute below only if Reseller Account Field is updated
                        if(newContactMap.get(conId).FBE_FPRM_Reseller_Account__c != oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c){
                            if(oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c != null
                               && eaRel.AccountId == oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c
                              && oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c != newContactMap.get(conId).AccountId){
                                   delAccConList.add(eaRel);
                               }
                            	
                             if(newContactMap.get(conId).FBE_FPRM_Reseller_Account__c != null && !mapOfContWithAccIds.get(conId).contains(newContactMap.get(conId).FBE_FPRM_Reseller_Account__c)){
                                String key = (String)conId + (String)newContactMap.get(conId).FBE_FPRM_Reseller_Account__c;
                                system.debug('Before key:'+key);
                                //I dont see any use of below 2 lines - 294 & 295.
                                if(//(eaRel.AccountId == oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c
                                   //|| oldContactMap.get(conId).FBE_FPRM_Reseller_Account__c == null )  &&
                                  !mapOfconAccStrWithRecord.containsKey(key)){
                                      system.debug('key:'+key);
                                       AccountContactRelation accRel = new AccountContactRelation(
                                           AccountId = newContactMap.get(conId).FBE_FPRM_Reseller_Account__c,
                                           ContactId = conId
                                       );
                                       insAccConList.add(accRel);
                                       
                                       mapOfconAccStrWithRecord.put(key,accRel);
                                   }
                            }
                        }
                        //End Reseller Account Field Updates
                        // When AccountId,Reseller is same and AccountId updated to new Account
                         //(Start)Stroy 10817483 :-17-Aug-2021 Added as part the oct rel for primary account from siebel-start
                        system.debug(conId+'Reseller Acc : '+newContactMap.get(conId).FBE_FPRM_Reseller_Account__c);
                        
                        if(newContactMap.get(conId).AccountId != oldContactMap.get(conId).AccountId &&
                         !mapOfContWithAccIds.get(conId).contains(newContactMap.get(conId).FBE_FPRM_Reseller_Account__c) &&
                          newContactMap.get(conId).FBE_FPRM_Reseller_Account__c!=null)
                        {
                            String key = (String)conId + (String)newContactMap.get(conId).FBE_FPRM_Reseller_Account__c;
                            system.debug(conId+'Inside if *:'+newContactMap.get(conId).FBE_FPRM_Reseller_Account__c);
                            system.debug('Account Updated :'+newContactMap.get(conId).AccountId);
                            AccountContactRelation accRel = new AccountContactRelation(
                               AccountId = newContactMap.get(conId).FBE_FPRM_Reseller_Account__c,
                               ContactId = conId);
                            mapOfconAccStrWithRecord.put(key,accRel);
                        }
                        //(end)Stroy 10817483 : Added as part the oct rel for primary account from siebel
                    }
                }
            }
            
            if(!delAccConList.isEmpty()){
                map<id,AccountContactRelation> deleteAccConRelMap = new map<id,AccountContactRelation>();
                deleteAccConRelMap.putall(delAccConList);
                delete deleteAccConRelMap.values();
            }
            
            /*if(!insAccConList.isEmpty()){
                insert insAccConList;
            }*/
            
            if(!mapOfconAccStrWithRecord.values().isEmpty()){
                insert mapOfconAccStrWithRecord.values();
                system.debug('success Relations:'+mapOfconAccStrWithRecord.values());
            }
        }
        
    }
}
/**************
*@ Class Name                                                    : FBE_LeadConvertCtrl
*@ Description                                                   : Created for Story#8506722.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 06-23-2020
*@ Modification Log                                              : [Abhishek Kawle - Deloitte] 07/24/2020 - Added record type 'FBE_Customer_Contact'
                                                                   to new contact creation script.
                                                                   [Rakesh - Dell] 09/28/2020 Defect 9513684 - Modified getRelatedOppty(),getSearchedOppty() methods with 
                                                                   new soql filter condition to return oppties based on End User Field
                                                                   [Rakesh -Dell] 12/10/2020 Story 9157003 - Removed 'Opportunity product Classification Field' Reference
                                                                   and modified code to skip this field value mappings to new/existing opportunity.  
                                                                   [Siva Kumar Valluru-Dell] Defect #11317030 - Appended the FBE_Formatted_Amount__c in the SOQL queries.  
                                                                   
***************/ 
public class FBE_LeadConvertCtrl {
    
    public static wrapResult returnVal = new wrapResult();
    @AuraEnabled
    public static Lead getLeadDetails(Id leadId){
        try{
            Lead lrec = [SELECT Id,FirstName, LastName, Phone, Email,FBE_End_User_Account__c,FBE_Account_Name__c,FBE_End_User_Account__r.Name,FBE_Account_Name__r.Name,FBE_Campaign__c,Opportunity_Product_Classification__c,FBE_Funding_Source__c,FBE_Customer_Comments__c,FBE_Project_ID__c,FBE_Expected_Opportunity_Type__c,Company FROM Lead where Id=:leadId limit 1];
            return lrec;
        }catch(Exception e)
        {
            System.debug('Error occured '+e.getMessage());
            return null;
        }                     
    }
    
    // This Method is invoked from the Lightning JS Controller of FBE_LeadConversion component.
    // It converts the Lead to Contact and opportunity(optional) and handles the mapping of Lead values into the Contact and Opportunity using custom meta data 
    @AuraEnabled
    public static wrapResult LeadConvert(lead leadRec,contact newCont,opportunity newOppty,string existingOpp,string existingCont,string accountId,string convertStatus,string recordOwner){
      
        Opportunity oppToInsert;
        Opportunity oppToUpdate;
        contact ConToInsert;
        Contact ConToUpdate;
        
        List<sObject> retList = new List<sObject>();
        FBE_Lead_Conversion_Mapping__mdt[] leadMapMDT = [Select MasterLabel, FBE_Lead_Field_API_Name__c, FBE_Opportunity_Field_API_Name__c, FBE_Contact_Field_API_Name__c from FBE_Lead_Conversion_Mapping__mdt];
        
        Map<String, Object> queriedFieldValues = new Map<String, Object>();
        Map<String, String> leadOptyFieldMap = new Map<String, String>();
        Map<String, String> leadContactFieldMap = new Map<String, String>();
        Map<Id, Object> leadwithValues = new Map<Id, Object>();
        
        for(FBE_Lead_Conversion_Mapping__mdt mapObj : leadMapMDT){
            queriedFieldValues.put(mapObj.FBE_Lead_Field_API_Name__c, leadRec.get(mapObj.FBE_Lead_Field_API_Name__c));
            if(mapObj.FBE_Opportunity_Field_API_Name__c != NULL){
                leadOptyFieldMap.put(mapObj.FBE_Lead_Field_API_Name__c, mapObj.FBE_Opportunity_Field_API_Name__c);
            }
            if(mapObj.FBE_Contact_Field_API_Name__c != NULL){
                leadContactFieldMap.put(mapObj.FBE_Lead_Field_API_Name__c,mapObj.FBE_Contact_Field_API_Name__c);   
            }            
        }
        leadwithValues.put(leadRec.id, queriedFieldValues);
        
        Savepoint sp = Database.setSavepoint();
        
        if((existingOpp == NULL || existingOpp == '') && convertStatus == 'Converted to New Opportunity' ){        
            oppToInsert = new Opportunity ();
            
           for(String fieldName : leadOptyFieldMap.keySet()){
                if(queriedFieldValues.containsKey(fieldName)){
                    String optyField = leadOptyFieldMap.get(fieldName);
                    System.debug('OptyField: '+ optyField);
                    if(! fieldName.contains('Opportunity_Product_Classification__c')){
                        oppToInsert.put(optyField, queriedFieldValues.get(fieldName));
                        system.debug('inside new - optyField'+optyField);
                    }
                }               
            } 
            oppToInsert.Name = newOppty.Name;
            oppToInsert.RecordTypeId = newOppty.RecordTypeId;
            oppToInsert.AccountId = id.valueOf(accountId);
            oppToInsert.CloseDate = newOppty.CloseDate;
            oppToInsert.StageName = newOppty.StageName;
            oppToInsert.FBE_Pursuit_Type__c = newOppty.FBE_Pursuit_Type__c;
            oppToInsert.FBE_Contracting_Status__c = newOppty.FBE_Contracting_Status__c;
            oppToInsert.Type = newOppty.Type;
            oppToInsert.FBE_Funding_Source__c = newOppty.FBE_Funding_Source__c;
         // removed Federal Alliance Segment field for Story#11852419   
         // oppToInsert.FBE_Federal_Alliance_Segment__c = newOppty.FBE_Federal_Alliance_Segment__c;
            oppToInsert.FBE_Storage_Selling_Motion__c = newOppty.FBE_Storage_Selling_Motion__c;
            oppToInsert.FBE_FSI_Not_Applicable__c = true;
            oppToInsert.FBE_Distributor_Not_Applicable__c = true;
            oppToInsert.FBE_Reseller_VAR_Not_Applicable__c = true; 
            oppToInsert.OwnerId = id.valueOf(recordOwner);
            
            Database.SaveResult[] srList = Database.insert(new List<Opportunity>{oppToInsert}, false);
            handleSaveResult(srList, oppToInsert);
            retList.add(oppToInsert);  
        }
        else if((existingOpp != NULL || existingOpp != '' ) && convertStatus == 'Converted to Existing Opportunity'){           
            oppToUpdate = [select id,Name,FBE_Campaigns__c from opportunity where id =:existingOpp];
              for(String fieldName : leadOptyFieldMap.keySet()){
                if(queriedFieldValues.containsKey(fieldName)){
                    String optyField = leadOptyFieldMap.get(fieldName);
                    System.debug('OptyField: '+ optyField);
                    if(fieldName.contains('FBE_Campaign__c') && oppToUpdate.FBE_Campaigns__c == NULL){ 
                        oppToUpdate.put(optyField, queriedFieldValues.get(fieldName));
                        system.debug('inside existing- optyField'+optyField);
                    }                   
                }
            } 
            Database.SaveResult[] srList = Database.update(new List<Opportunity>{oppToUpdate}, false);
            handleSaveResult(srList, oppToUpdate);          
            retList.add(oppToUpdate);     
        }
        
        if(existingCont == NULL || existingCont == ''){
            ConToInsert = new contact();            
            for(String fieldName : leadContactFieldMap.keySet()){
                if(queriedFieldValues.containsKey(fieldName)){
                    String optyField = leadContactFieldMap.get(fieldName);
                    System.debug('ConField: '+ optyField);
                    ConToInsert.put(optyField, queriedFieldValues.get(fieldName));
                }
            }
            ConToInsert.FirstName = newCont.FirstName;
            ConToInsert.LastName = newCont.LastName;
            ConToInsert.Phone = newCont.Phone;
            ConToInsert.Email = newCont.Email;
            ConToInsert.AccountId = accountId;
            ConToInsert.OwnerId = recordOwner;
            ConToInsert.Country_Code_CAM__c = newCont.Country_Code_CAM__c;
            ConToInsert.Extension_CAM__c = newCont.Extension_CAM__c;
            ConToInsert.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FBE_Customer_Contact').getRecordTypeId();
            Database.SaveResult[] srList = Database.insert(new List<Contact>{ConToInsert}, false);
            handleSaveResult(srList, ConToInsert);
            retList.add(ConToInsert);
        }
        else if(existingCont != NULL || existingCont != ''){
            ConToUpdate = [select id,FirstName,LastName,Phone,email from Contact where id =:existingCont]; 
            
            for(String fieldName : leadContactFieldMap.keySet()){
                if(queriedFieldValues.containsKey(fieldName)){
                    String conField = leadContactFieldMap.get(fieldName);
                    System.debug('conField: '+ conField);
                    ConToUpdate.put(conField, queriedFieldValues.get(fieldName));
                }
            }
            Database.SaveResult[] srList = Database.update(new List<Contact>{ConToUpdate}, false);
            handleSaveResult(srList, ConToUpdate);
            retList.add(ConToUpdate); 
        }
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadRec.id);
        system.debug('oppToInsert: '+oppToInsert );
        system.debug('oppToUpdate: '+oppToUpdate );
        system.debug('ConToInsert: '+ConToInsert );
        system.debug('ConToUpdate: '+ConToUpdate );
        lc.setConvertedStatus(convertStatus);        
        if(oppToInsert!=Null && oppToInsert.Id != Null){
            lc.setOpportunityId(oppToInsert.ID);
        }else{
            if(oppToUpdate != NULL){
                system.debug('inside else : ' +oppToUpdate);
                lc.setOpportunityId(oppToUpdate.ID);
            }
            else{
                lc.setDoNotCreateOpportunity(true);
            }
            
        }
        
        if(ConToInsert!=null){
            lc.setContactId(ConToInsert.ID);
        }else{
            lc.setContactId(ConToUpdate.ID);
        }
        
        lc.setAccountId(accountId);
        
        if(returnVal.failureResult == NULL){
            system.debug('inside zero failures');
            Database.LeadConvertResult lcr;
            try{
                lcr = Database.convertLead(lc); 
                if(lcr.isSuccess()){
                    system.debug('lcr oppId' +lcr.getOpportunityId());
                }else{
                    system.debug('inside rollback-1');
                    system.debug('lcr errors' +lcr.getErrors());
                    Database.rollback(sp);
                    for(Database.Error err : lcr.getErrors()){
                        returnVal.failureResult = new List<String>{err.getMessage()};
                            //returnVal.failureResult.add(err.getMessage());
                            }
                }
            }
            catch(System.DmlException ex){
                system.debug('inside rollback-2');
                Database.rollback(sp);
                system.debug('LeadConversion Exception' +ex.getDmlMessage(0));
                returnVal.failureResult = new List<String>{ex.getDmlMessage(0)};
                    //returnVal.failureResult.add(e.getMessage());
                    }
            catch(Exception e){
                system.debug('inside rollback-3');
                Database.rollback(sp);
                system.debug('LeadConversion Exception' +e.getMessage());
                returnVal.failureResult = new List<String>{e.getMessage()};
            }
            
        }else{
            system.debug('inside rollback-3');
            Database.rollback(sp);
        }
        system.debug('returnValue: ' +returnVal);
        return returnVal; 
    } 
    public class wrapResult {
        @AuraEnabled
        public  List<sObject> successResult {get; set;}
        @AuraEnabled
        public  List<String> failureResult {get; set;}
    }
    
    public  static void handleSaveResult(Database.SaveResult[] srList, sObject sobj){
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('isSuccess   '+sobj);
                if(returnVal.successResult == null){
                    returnVal.successResult = new List<sObject>{sobj};
                        }else{
                            returnVal.successResult.add(sobj);
                        }
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('isFail  '+sobj);
                    if(returnVal.failureResult == null){
                        returnVal.failureResult = new List<String>{err.getMessage()};
                            }else{
                                returnVal.failureResult.add(err.getMessage());
                            }
                }
            }
        }
        System.debug('returnVal:::- handleSaveResult '+returnVal);
    }
    
    @AuraEnabled
    public static List<Contact> getRelatedActConts(Id actId){
        return [SELECT Id,firstName,lastName,email,Account.Name FROM Contact WHERE accountId =:actId];
    }
     
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead'];
        
        return listviews;
    }
    
    @AuraEnabled
    public static List<sObject> getUpdateValues(String aId, String oId, String cId) {
        System.debug('inside getUpdateValues: '+ 'aId ' + aId + ' oId'+oId + ' cId'+cId);
        Opportunity opty = new Opportunity();
        list<Opportunity> lstoppty = new list<Opportunity>();
        List<sObject> retList = new List<sObject>();
        Account act = [SELECT Id,Phone,Type,Website,FBE_Account_Class__c,Name,OwnerId,Owner.name FROM Account WHERE Id =:aId];
        
        if(String.isNotBlank(oId)){
        system.debug('Entered##### '+oId );
            lstoppty = [SELECT Id,AccountId,Account.Name,RecordTypeId,RecordType.Name,CloseDate,Amount,OwnerId,Owner.Name,Name,FBE_Formatted_Book_Date__c,FBE_Storage_Selling_Motion__c FROM Opportunity WHERE Id =:oId limit 1];
            
        }
        Contact cnt = [SELECT Id,Title,AccountId,Account.Name,Phone,Email,MobilePhone,Name,FirstName FROM Contact WHERE Id =:cId];
        retList.add(act);
        retList.add(cnt);
        if(lstoppty.size() > 0){
        opty = lstoppty[0];
        retList.add(opty);
        }
        
        return retList;
        
    }
    
     
    @AuraEnabled   
     public static List<Opportunity> getRelatedOppty(Id accountId){
       List<Opportunity> opptyList = [SELECT Id, OwnerId,Owner.Name,AccountId,Account.Name, Name,FBE_Opportunity_Number__c,Amount,FBE_Formatted_Amount__c, RecordTypeId,RecordType.Name,CloseDate,FBE_Formatted_Book_Date__c
                   FROM Opportunity
                   where StageName NOT IN('Won - 100%','Lost - 0%','Cancelled - 0%') 
                   and FBE_End_User__c=:accountId
                   and RecordType.developername = 'FBE_Standard_Opportunity'];
         
         return opptyList;
    }
    @AuraEnabled    
    public static List<Opportunity> getSearchedOppty(Id accountId,String sname){         
         List<Opportunity> opptyList = new List<Opportunity>();
        String queryString = 'SELECT Id, OwnerId,Owner.Name,AccountId,Account.Name,Name,FBE_Opportunity_Number__c,'
            +'Amount,FBE_Formatted_Amount__c, RecordTypeId,RecordType.Name,CloseDate,FBE_Formatted_Book_Date__c FROM Opportunity where '+
            'StageName NOT IN(\'Won - 100%\',\'Lost - 0%\',\'Cancelled - 0%\') and FBE_End_User__c=:accountId and FBE_End_User__c=:accountId and RecordType.developername = \'FBE_Standard_Opportunity\'';
        String filterCondition = '';
                           
         if(sname!=null && sname!=''){
             filterCondition = filterCondition+' and (Name like \'%'+String.escapeSingleQuotes(sname)+'%\' OR FBE_Opportunity_Number__c like \'%'+String.escapeSingleQuotes(sname)+'%\')';
         }
         queryString = queryString + filterCondition ;
            System.debug('queryString '+queryString);
            try{
                opptyList = Database.query(queryString);
            }
            catch(Exception e){
                system.debug('Error '+e.getMessage());
            }   

        return opptyList;
    }
    
    @AuraEnabled 
    Public Static boolean getCurrentUser(){     
        User currentUser = [ SELECT Id,Role_Name__c,UserRole.Name FROM User WHERE Id = : UserInfo.getUserId() ];
        system.debug( 'User Role  ' + currentUser.UserRole.Name );
        List<String> userRolesList = new List<String>();
        
        if(currentUser.UserRole.Name != Null){
            for(User_Roles__mdt userRole :  [SELECT Id, FBE_User_Roles__c,MasterLabel FROM User_Roles__mdt WHERE MasterLabel != NULL]) {
                if(userRole.MasterLabel.contains('ISG')) {
                    userRolesList.addAll(userRole.FBE_User_Roles__c.split(','));
                } 
            }
            if(userRolesList.contains(currentUser.UserRole.Name)){
               return true;  
            }
            else{
                return false;
            }
        }
        else {
            return false;
        }
        
    }
}
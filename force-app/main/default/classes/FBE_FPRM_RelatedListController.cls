/**************
 * @ Class Name        : FBE_FPRM_RelatedListController
 * @ Description       : This is a controller class with methods for Lightning Component - FBE_FPRM_ContactsRelatedList
 *                       Developed as part of PRM Story #10138414
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 02-11-2021
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/

public class FBE_FPRM_RelatedListController {
    public static final String RECORDS = 'records';
    public static final String OBJFIELDS = 'objfields';
    public static final String OBJAPINAME = 'sobjectApiName';
    public static final String RECORDID = 'recordId';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectName';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectNamePlural';
    public static final String CONDITION_FIELD_API_NAME = 'conditionFieldApiName';
    public static final String PARENT_REL_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String PRM_VISIBILITY_FLAG = 'prmVisibilityFlag';
    public static final String CURRENT_USER_ID ='currentUserId';
    public static final String CAN_CREATE_RECORDS = 'canCreateRecords';
    public static final String VIEW_ALL_RECORDS_FLAG = 'viewAllRecordsFlag';
    public static final String VIEW_ALL_ROW_LIMIT = 'rowLimit';
    public static final String VIEW_ALL_TOTAL_ROWS = 'totalRows';
    public static final String VIEW_ALL_OFFSET = 'rowsOffset';
    public static final String RECORD_ID_SOBJECT_LABEL_NAME = 'recordSObjectName';
    public static final String RECORD_NAME = 'recordName';
    public static final String AFFILIATIONS_FLAG = 'affiliationsListFlag';
    public static Map<String, Object> responseMap{get;set;}
    
	@AuraEnabled
    public static String setContext(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        responseMap = new Map<String, Object>();
        responseMap.put(RECORDS, getDataRecords(jsonData));
        System.debug('Invoked setContext: Response Map: '+responseMap);
        
        String objectApiName = (String)requestMap.get(OBJAPINAME);
        String recordId = (String)requestMap.get(RECORDID);
        String conditionFieldApiName = (String)requestMap.get(CONDITION_FIELD_API_NAME);
        String currentUserId = (String)requestMap.get(CURRENT_USER_ID);
        Boolean prmVisibilityFlag = (Boolean)requestMap.get(PRM_VISIBILITY_FLAG);
        Boolean affiliationsFlag = (Boolean)requestMap.get(AFFILIATIONS_FLAG);
        responseMap.put(PARENT_REL_API_NAME_PARAM, getParentRelationshipName(recordId, objectApiName, conditionFieldApiName));
        //System.debug('Parent Relationship API Name: '+getParentRelationshipName(recordId, objectApiName, conditionFieldApiName));
        
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        responseMap.put(CAN_CREATE_RECORDS, getUserPermissions(recordId, currentUserId, affiliationsFlag));
        //responseMap.put(VIEW_ALL_TOTAL_ROWS, getTotalRows(recordId, objectApiName, conditionFieldApiName));
        
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static List<Sobject> getDataRecords(String jsonData){

        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        String objFields = (String)jsonMap.get(OBJFIELDS);
        String recordId = (String)jsonMap.get(RECORDID);
        String objectApiName = (String)jsonMap.get(OBJAPINAME);
        Integer numberOfRecords = (Integer)jsonMap.get(NUMBER_OF_RECORDS_PARAM);
        String conditionFieldApiName = (String)jsonMap.get(CONDITION_FIELD_API_NAME);
        Boolean prmVisibilityFlag = (Boolean)jsonMap.get(PRM_VISIBILITY_FLAG);
        String currentUserId = (String)jsonMap.get(CURRENT_USER_ID);
        Boolean viewAllRecordsFlag = (Boolean)jsonMap.get(VIEW_ALL_RECORDS_FLAG);
        Integer rowLimit = (Integer)jsonMap.get(VIEW_ALL_ROW_LIMIT);
        Integer rowOffset = (Integer)jsonMap.get(VIEW_ALL_OFFSET);
        Boolean affiliationsFlag = (Boolean)jsonMap.get(AFFILIATIONS_FLAG);
        List<Sobject> totalRows = new List<Sobject>();
        
        String query='';
        String totalRowsQuery = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId';
        if(viewAllRecordsFlag){
            query += 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId'+' Limit :numberOfRecords';
            System.debug('View All Records: True : Default Query>>> '+query);
        }
        else{
            if(rowOffset == 0 || rowOffset == null){
                query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId'+' LIMIT :rowLimit OFFSET 0';
                System.debug('View All Records no offset Initial Query: '+query); 
            }
            else{
                query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId'+' LIMIT :rowLimit OFFSET :rowOffset';
                //query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId';
                System.debug('View All Records with offset >> Default Query>>> '+query);  
            }
        }

        
        System.debug('Object Fields: '+objFields);
        
        System.debug('PRM Visibility Flag: '+prmVisibilityFlag+' and Current UserID: '+currentUserId);
        if(prmVisibilityFlag && currentUserId!=null){
            User userObj = [SELECT Id, ContactId, Contact.FBE_FPRM_Reseller_Account__c, Contact.AccountId, Profile.Name FROM User WHERE Id =:currentUserId LIMIT 1];
            Account accountObj = [SELECT Id, FBE_Partner_Type__c FROM Account Where Id =:recordId];
            String contactResellerAcc = userObj.Contact.FBE_FPRM_Reseller_Account__c;
            String contactAccount = userObj.Contact.AccountId;
            if(userObj.Profile.Name == 'FBE FPRM Partner Disty Managed' && userObj.ContactId != null){ 

                query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ';
                String condition = '';
                if(viewAllRecordsFlag){
                    if(affiliationsFlag){
                        condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' Limit :numberOfRecords';
                    }
                    else{
                        condition = conditionFieldApiName+' =:contactResellerAcc'+' OR FBE_FPRM_Reseller_Account__c' +'=:contactResellerAcc'+' Limit :numberOfRecords';
                    }
                }
                else{
                    if(rowOffset == 0 || rowOffset == null){
                        if(affiliationsFlag){
                            condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET 0';
                        }
                        else{
                        condition = conditionFieldApiName+' =:contactResellerAcc'+' OR FBE_FPRM_Reseller_Account__c' +'=:contactResellerAcc'+' LIMIT :rowLimit OFFSET 0';
                        //System.debug('View All Records no offset Initial Query: '+condition); 
                        }
                    }
                    else{
                        if(affiliationsFlag){
                            condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET :rowOffset';
                        }
                        else{
                          condition = conditionFieldApiName+' =:contactResellerAcc'+' OR FBE_FPRM_Reseller_Account__c' +'=:contactResellerAcc'+' LIMIT :rowLimit OFFSET :rowOffset';  
                        }
                    }
                    //condition = conditionFieldApiName+' =:contactResellerAcc'+' OR FBE_FPRM_Reseller_Account__c' +'=:contactResellerAcc';
                }
                query +=condition;
                System.debug('Query for PRM Disty Managed: '+query);
                if(affiliationsFlag){
                    totalRowsQuery = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)';
                }
                else{
                    totalRowsQuery = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+' =:contactResellerAcc'+' OR FBE_FPRM_Reseller_Account__c' +'=:contactResellerAcc';
                }
                
                System.debug('Total Rows Query for PRM Disty Managed: '+totalRowsQuery);
            }
            
            if((userObj.Profile.Name == 'FBE FPRM Partner Distributor' || userObj.Profile.Name == 'FBE FPRM Partner Reseller') 
               && userObj.ContactId != null){    
                   
                   query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ';
                   String condition;
                   if(viewAllRecordsFlag){
                       if(affiliationsFlag){
                           if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                               condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' Limit :numberOfRecords';    
                           }
                           else{
                           	condition = conditionFieldApiName+' =:recordId'+' AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' Limit :numberOfRecords';    
                           }
                           
                       }
                       else{
                           if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                               condition = conditionFieldApiName+' =:recordId'+' AND FBE_FPRM_Reseller_Account__c'+' =:contactAccount'+' Limit :numberOfRecords';     
                           }
                           else{
                               condition = conditionFieldApiName+' =:recordId'+' OR FBE_FPRM_Reseller_Account__c' +'=:recordId'+' Limit :numberOfRecords';    
                           }
                       }  
                   } 
                   else{
                       if(rowOffset == 0 || rowOffset == null){
                           if(affiliationsFlag){
                               if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                                   condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET 0';    
                               }
                               else{
                               	condition = conditionFieldApiName+' =:recordId'+' AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET 0';    
                               }
                               
                           }
                           else{
                               if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                                   condition = conditionFieldApiName+' =:recordId'+' AND FBE_FPRM_Reseller_Account__c'+' =:contactAccount'+' LIMIT :rowLimit OFFSET 0';     
                               }
                               else{
                                   condition = conditionFieldApiName+' =:recordId'+' OR FBE_FPRM_Reseller_Account__c' +'=:recordId'+' LIMIT :rowLimit OFFSET 0';    
                               }
                           }
                           
                           //System.debug('View All Records no offset Initial Query: '+condition); 
                       }
                       else{
                           if(affiliationsFlag){
                               if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                                   condition = conditionFieldApiName+' =:recordId'+' AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET :rowOffset';   
                               }
                               else{
                                condition = conditionFieldApiName+' =:recordId'+' AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)'+' LIMIT :rowLimit OFFSET :rowOffset';   
                               }
                                
                           }
                           else{
                               if(contactAccount != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                                   condition = conditionFieldApiName+' =:recordId'+' AND FBE_FPRM_Reseller_Account__c'+' =:contactAccount'+' LIMIT :rowLimit OFFSET :rowOffset';     
                               }
                               else{
                                   condition = conditionFieldApiName+' =:recordId'+' OR FBE_FPRM_Reseller_Account__c' +'=:recordId'+' LIMIT :rowLimit OFFSET :rowOffset';    
                               }
                               
                           }                           
                           //query = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+ '= :recordId';
                           //System.debug('View All Records with offset >> Default Query>>> '+query);  
                       }
                       
                       //condition = conditionFieldApiName+' =:recordId'+' OR FBE_FPRM_Reseller_Account__c' +'=:recordId';
                   }
                query +=condition;
                System.debug('Query for PRM Distributor / Reseller: '+query);
                   if(affiliationsFlag){
                       totalRowsQuery = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+' =:recordId'+' AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)';
                   }
                   else{
                       totalRowsQuery = 'SELECT '+objFields+' FROM '+objectApiName+' WHERE ' +conditionFieldApiName+' =:recordId'+' OR FBE_FPRM_Reseller_Account__c' +'=:recordId';   
                   }
                   System.debug('Total Rows Query for PRM Dist / Reseller: '+totalRowsQuery);
            }
        }
        totalRows = Database.query(String.escapeSingleQuotes(totalRowsQuery));
        responseMap.put(VIEW_ALL_TOTAL_ROWS, totalRows);
        return Database.query(String.escapeSingleQuotes(query));  
    }
    
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String sObjectLabelName = recordId.getSObjectType().getDescribe().getName();
        responseMap.put(RECORD_ID_SOBJECT_LABEL_NAME,sObjectLabelName);
        
        String recordNameQuery = 'SELECT Id, Name FROM '+sObjectLabelName+' WHERE Id'+'= :recordId';
        responseMap.put(RECORD_NAME, Database.query(String.escapeSingleQuotes(recordNameQuery)));
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }
        return name;
    }
    
        private static boolean getUserPermissions(Id recordId, Id userId, boolean affiliationsFlag){
        boolean canCreateRecords = true;
            if(affiliationsFlag){
                canCreateRecords = false;
            }
            User userObj = [SELECT Id, ContactId, Contact.FBE_FPRM_Reseller_Account__c, Contact.AccountId, Profile.Name FROM User WHERE Id =:userId LIMIT 1];
            Account accountObj = [SELECT Id, FBE_Partner_Type__c FROM Account Where Id =:recordId];
            
            if(userObj.Contact.AccountId != recordId && (accountObj.FBE_Partner_Type__c == 'Reseller' || accountObj.FBE_Partner_Type__c == 'Distributor')){
                canCreateRecords = false;
            }
        /*if(prmVisibilityFlag && userId!=null){
            User userObj = [SELECT Id, ContactId, Contact.FBE_FPRM_Reseller_Account__c, Profile.Name FROM User WHERE Id =:userId LIMIT 1];
            /*if(userObj.Contact.FBE_FPRM_Reseller_Account__c != null 
              && userObj.Contact.FBE_FPRM_Reseller_Account__c != recordId ){
               canCreateRecords = false;
            } 
        } */
        return canCreateRecords;
    }
    
    /*private static Integer getTotalRows(Id recordId, String sobjectApiName, String relatedFieldApiName){
        Integer totalRows = 0;
        String query = 'SELECT COUNT() FROM '+sobjectApiName+' WHERE ' +relatedFieldApiName+ '= :recordId';
        totalRows = Database.countQuery(String.escapeSingleQuotes(query));
        
        return totalRows;
    }*/
}
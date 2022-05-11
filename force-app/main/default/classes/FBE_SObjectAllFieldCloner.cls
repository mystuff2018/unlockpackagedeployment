/**************
*@ Class Name                                                    : FBE_SObjectAllFieldCloner
*@ Description                                                   : This is written for Clone Opportunity and Line Items and this class would be invoke on Submit of Clone new Opportunity.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 19-Feb-2020 [Sireesha Myla]
*@ Modification Log                                              : 05-October-2020[DEFECT 9470841 - Sireesha Myla], Story 9015810  - 14-Dec-2020 [Sireesha Myla],Defect#10024409 - Sireesha Myla[01/20/2021]
***************/ 
public class FBE_SObjectAllFieldCloner 
{
   // Clone a list of objects to a particular object type
    // Parameters
    // - List<sObject> sObjects - the list of objects to be cloned
    // - Schema.SobjectType objectType - the type of object to be cloned.
    // The sObjects you pass in must include the ID field,
    // and the object must exist already in the database,
    // otherwise the method will not work.
    @testVisible
    public static List<sObject> cloneObjects(List<Id> sObjectIds, Schema.SObjectType objectType, 
                                             	Map<Id, Sobject> mapSobject, List<String> lstFields)
    {
        
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>();
        // A list of new cloned sObjects
        List<sObject> clonedSObjects = new List<sObject>();
        
        // Get all the fields from the selected object type using
        // the get describe method on the object type.
        if(objectType != null){
            sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        }
        /* Using the list of sObject IDs and the object type,
		we can construct a string based SOQL query
		to retrieve the field values of all the objects.*/
        
        String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);
        
        for (Integer i=1 ; i < sObjectFields.size() ; i++){
            allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
        }
        
        allSObjectFieldsQuery += ' FROM ' +
            					objectType.getDescribe().getName() +
            					' WHERE ID IN: sObjectIds' ;
        
        
        System.debug('SOQL **** ' + allSObjectFieldsQuery);
        
        try{
            // Execute the query. For every result returned,
            // use the clone method on the generic sObject
            // and add to the collection of cloned objects
            Integer i = 0;
            for (SObject sObjectFromDatabase:Database.query(allSObjectFieldsQuery))
            {
                system.debug('for loop called for '+(++i)+' times.');
                system.debug('sObjectFromDatabase='+sObjectFromDatabase);
                Sobject sobjFromCmp = mapSobject.get(sObjectFromDatabase.Id);
                for(String fieldAPI:lstFields)
                {
                    system.debug('===='+fieldAPI); 
                    
                    sObjectFromDatabase.put(fieldAPI, sobjFromCmp.get(fieldAPI));
                    system.debug('Opp Object ****'+sObjectFromDatabase);
                   
                }
                /* Story 9015810 - BDD2[Sireesha Myla]-12/14/2020*/
                if(objectType.getDescribe().getName() == 'Opportunity')
                {
                    if(sObjectFromDatabase.get('StageName')== 'Plan - 1%')
                       sObjectFromDatabase.put('Probability',1);
                    if(sObjectFromDatabase.get('StageName')== 'Discover - 10%')
                       sObjectFromDatabase.put('Probability',10);
                    if(sObjectFromDatabase.get('StageName')== 'Qualify - 30%')
                       sObjectFromDatabase.put('Probability',30); 
                    if(sObjectFromDatabase.get('StageName')== 'Propose - 60%')
                       sObjectFromDatabase.put('Probability',60);  
                    if(sObjectFromDatabase.get('StageName')== 'Commit - 90%')
                       sObjectFromDatabase.put('Probability',90); 
                    if(sObjectFromDatabase.get('StageName')== 'Won - 100%')
                       sObjectFromDatabase.put('Probability',100);
                    if(sObjectFromDatabase.get('StageName')== 'Lost - 0%')
                       sObjectFromDatabase.put('Probability',0);
                    if(sObjectFromDatabase.get('StageName')== 'Cancelled - 0%')
                       sObjectFromDatabase.put('Probability',0);
                    //Defect#10024409 - Sireesha Myla[01/20/2021]
                    sObjectFromDatabase.put('FBE_Win_Loss_Flag__c',false);
                     
                }
                
                //Added as part of DEFECT 9470841, get all the Boolean fields where the value is null and make them false
                if(objectType == Opportunity.getsObjectType()) // The checkbox fields needs to check only for Opportunity.
                {
                    Map<String, Schema.DisplayType> fieldsMap = booleanFieldsType('Opportunity');
                    for(String field: fieldsMap.keySet())
                    {
                        system.debug('field value &&&'+sObjectFromDatabase.get(field));
                        if(sObjectFromDatabase.get(field)== null)
                            sObjectFromDatabase.put(field, false);
                    }
                }
                                
                if(objectType.getDescribe().getName() == 'OpportunityLineItem'){//added this because it was throwing error like we can't provide unitprice and total together
                    sObjectFromDatabase.put('TotalPrice', null);
                    system.debug('Opty Line Item Object &&&'+objectType.getDescribe().getName());
                }
                system.debug('Opp and OLI values in Map &&&'+sObjectFromDatabase);
               
                clonedSObjects.add(sObjectFromDatabase.clone(false,true));
                system.debug('clonedSObjects='+clonedSObjects);
            }
            System.debug('clonedSObjects **** ' + clonedSObjects);
         }catch (exception e)
         {
                System.debug('======>>'+e);
         }
        return clonedSObjects;
    }
    /* This method created as part of Nov Release 2020 DEFECT 9470841- from comments Clarificaions point of View.
     *'Error Received, MIT Assessment Completed: value not of required type' - checkbox field errors
     * Error received by few profiles where The checkbox fields are hidden and Because of that backend script paasing 
     * null as value instead of True or false.
     * This method returns the map where it stores all the sObject Boolean field names and the datatype.
     */
    public static Map<String, Schema.DisplayType> booleanFieldsType(String sObjectName)
    {
                 
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType OpptySchema = schemaMap.get(sObjectName);
		    Map<String, Schema.DisplayType> fieldsMap = new Map<String, Schema.DisplayType>();
            Map<String, Schema.SObjectField> fieldMap = OpptySchema.getDescribe().fields.getMap();

            for (String fieldName: fieldMap.keySet()) 
            {
               //It provides to get the object fields data type.
                
                 System.debug('%%%% field name api &&'+fieldName);
                 Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                 if(fielddataType == Schema.DisplayType.Boolean)
                     fieldsMap.put(fieldName, fielddataType);
            }
            return fieldsMap;

    }
}
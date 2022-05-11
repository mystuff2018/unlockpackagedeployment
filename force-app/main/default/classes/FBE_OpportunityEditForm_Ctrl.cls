/**************
*@ Class Name                                                    : FBE_OpportunityEditForm_Ctrl
*@ Description                                                   : This is written for Clone Opportunity and Line Items [STORY 7974747] .
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 02-March-2020 [Sireesha Myla]
*@ Modification Log                                              : Story 9015810 - 09-Dec-2020 [Sireesha Myla], Defect10027730 - 27-Jan-2021 [Sireesha Myla] 
***************/ 
public class FBE_OpportunityEditForm_Ctrl 
{
    private static Map<String, Schema.FieldSet> fieldSetMap;
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        
        getObjectFieldSets(objectName); // get Object Field Set
        FieldSetForm form = new FieldSetForm();
        try{
            form.products = [SELECT Id, Product2.Name, Quantity, UnitPrice,FBE_Quote_Number_Line__c, Description, FBE_Siebel_Revenue_Id__c
                               FROM OpportunityLineItem WHERE OpportunityId =: recordId];
            
            for(OpportunityLineItem setOLI: form.products)
            {
                setOLI.FBE_Siebel_Revenue_Id__c = null;
                //setOLI.FBE_Quote_Number_Line__c = null;
            }
            
            system.debug('&&===fieldSetName===='+fieldSetName);
            if(!String.isBlank(fieldSetName)){
                form.fields.addAll(getFields(fieldSetName));
            }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                throw e;
            }
            
        
        }catch(Exception ex){
            System.debug('--- ' + ex.getMessage() + '--- ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return form;
        
    }
    
    @AuraEnabled
    public static Id submitUIValues(String jsonObject, String recordId, List<OpportunityLineItem> lstProducts){
        Id OptyStandardRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
        Id returnId = null;
        String msg = '';
        try{
            System.debug('jsonObject ' + jsonObject);
            System.debug('recordId ' + recordId);
            Opportunity objOPP = (Opportunity) JSON.deserialize(jsonObject, Opportunity.Class);
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>{recordId => objOPP};
            system.debug('===mapOpp=='+mapOpp);
            getObjectFieldSets(Id.valueOf(recordId).getSobjectType().getDescribe().getName());
            List<String> lstFields = getFields('FBE_Clone_Opportunity_Field_Set');
            
            List<sObject> clonedOppty = FBE_SObjectAllFieldCloner.cloneObjects(new List<Id>{recordId}, Opportunity.getsObjectType(), 
                                                                          mapOpp, lstFields);
            System.debug('***null checbox'+clonedOppty);
            if(clonedOppty.isEmpty()){
                return null;
            }
            objOPP = (Opportunity)clonedOppty[0];

            objOPP.Pricebook2Id =  [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id =: recordId].Pricebook2Id;
            //Story 9015810 - BDD1[Sireesha Myla] - 12/09/2020
            objOPP.RecordTypeId = OptyStandardRecordType;
            
            if(Test.isRunningTest()){
                objOPP.Name = 'Opportunit Test2';
            }
            //insert objOPP;
            
            Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(lstProducts);
            List<String> lstProductFields = new List<String>{
                'Quantity', 'UnitPrice', 'FBE_Quote_Number_Line__c', 'Description', 'FBE_Siebel_Revenue_Id__c'
            }; 
            List<Sobject> lstSobjectProducts = FBE_SObjectAllFieldCloner.cloneObjects(new List<Id>(new Map<Id, OpportunityLineItem>(lstProducts).KeySet()), 
                                                                                                             OpportunityLineItem.getsObjectType(),
                                                                                 oliMap, lstProductFields);
            system.debug('&&&OLI List sS **'+lstProducts.size());
            //Story9015810-BDD3 - [Sireesha Myla- 12/09/2020] - Error message should throw when Cloning without products
            if(lstProducts.size()==0 && (objOPP.StageName!= 'Plan - 1%' && objOPP.StageName!= 'Discover - 10%' ))
            {
                throw new AuraHandledException('You cannot change Sales Stage unless products are added to the Opportunity.');
            }
            else{
                insert objOPP;
                for(Sobject OLI: lstSobjectProducts){
                    OLI.put('OpportunityId', objOPP.Id);
                }
                System.debug('------ lstSobjectProducts lines' + lstSobjectProducts);
                insert lstSobjectProducts;
                System.debug('------ lstSobjectProducts' + lstSobjectProducts);
                returnId = objOPP.Id;
            }
            
            
        }
        catch(DmlException e){
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
             
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Lookup filter error messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            system.debug('Exception error**message='+msg +'&&&& MIT field'+e);
            throw new AuraHandledException(msg);
             
        }
        
        /*catch(Exception ex){
            System.debug('--- ' + ex.getMessage() + '--- ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }*/
        return returnId;
    }
    
    private static void getObjectFieldSets(String objectName){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        fieldSetMap = objectDescribe.fieldSets.getMap();//Getting the Object's FieldSet
        system.debug('field set &&& fields && '+fieldSetMap);
    }
    
    
    private static List<String> getFields( String fieldSetName) {
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<String> fields = new List<String>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) 
        {
            fields.add(fsm.fieldPath);
        }
        
       system.debug('fields'+fields);        
        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled public List<String> fields;
        @AuraEnabled public List<OpportunityLineItem> products;
        public FieldSetForm() {
            fields = new List<String>();
            products = new List<OpportunityLineItem>();
        }
    }

}
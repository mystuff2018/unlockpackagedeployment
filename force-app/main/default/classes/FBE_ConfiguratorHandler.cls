/**************
*@ Class Name                                                    : FBE_ConfiguratorHandler
*@ Description                                                   : This class is to handle all configurator logics.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 04-01-2020 [Lavakumar Tonupunuri]
*@ Modification Log                                              : 
***************/ 
public class FBE_ConfiguratorHandler{
    public static void onAfterUpdate(List<FBE_Configurator__c> configList,Map<ID,FBE_Configurator__c> oldMap){
        Map<ID,ID> confidIdWithAttchIds = new Map<ID,ID>();
        for(FBE_Configurator__c conf : configList){
            if(conf.FBE_Status__c == 'Uploading...' && conf.FBE_Attachment_Reference_ID__c != NULL && oldMap.get(conf.id).FBE_Status__c != conf.FBE_Status__c){
                confidIdWithAttchIds.put(conf.id,conf.FBE_Attachment_Reference_ID__c);
            }
        }
        if(! confidIdWithAttchIds.isEmpty()){
            Map<string,ID> priceBookMap = new Map<string,ID>();
            for(pricebook2 pBook : [select id,Name from pricebook2 where IsActive = true]){
                if(pBook.Name == 'Dell PriceBook'){
                    priceBookMap.put('Dell DFN Siebel',pBook.id);
                }else if(pBook.Name == 'EMC PriceBook'){
                    priceBookMap.put('EMC Fed SFDC',pBook.id);
                }else if(pBook.Name == 'Standard Price Book'){
                    priceBookMap.put('Standard Price Book',pBook.id);
                }
            }
            if(priceBookMap.values().size() >= 3){
                for(Attachment atch : [SELECT Id, Body,BodyLength,ParentId FROM Attachment
                WHERE Id IN : confidIdWithAttchIds.values() limit 1]){
                    FBE_FileUploadControllerUtility.processLoad(EncodingUtil.base64Encode(atch.Body),atch.ParentId);
                    system.debug('method called');
                }
            }else{
                updateErrorLog(JSON.Serialize(confidIdWithAttchIds),'Check the Price books are active or not');
            }
            
        }
        
    }
    @future 
    public static void updateErrorLog(string confidIdWithAttchIds,string errorLog){

        Map<ID,ID> confidIdWithAttchId = (Map<ID,ID>)JSON.deserialize(confidIdWithAttchIds, Map<ID,ID>.class);
        List<FBE_Configurator__c> configToInsert = new List<FBE_Configurator__c>();
        for(ID config : confidIdWithAttchId.keySet()){
            FBE_Configurator__c conf = new FBE_Configurator__c();
            conf.id = config;
            conf.FBE_Error_Log__c = errorLog;
            conf.FBE_Status__c = 'Please check the Error log';
            configToInsert.add(conf);
        }
        if(configToInsert.size() > 0){
            UPDATE configToInsert;
        }
    }
}
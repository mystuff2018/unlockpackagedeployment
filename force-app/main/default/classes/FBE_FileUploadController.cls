public with sharing class FBE_FileUploadController {
 	public static string base64Data1='';
 
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        
        //integer length = EncodingUtil.base64Decode(base64Data1).toString().length();
        
        //system.debug('existingBody '+length);
        base64Data1 = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        } 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 		FBE_Configurator__c config = new FBE_Configurator__c();
        config.FBE_Status__c = 'File attached to load';
        config.RecordTypeId = Schema.SObjectType.FBE_Configurator__c.getRecordTypeInfosByName().get('Configurator').getRecordTypeId();
        config.Name = 'Products requested to load on '+system.today().month()+'/'+system.today().day()+'/'+system.today().year();
        INSERT config;
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = config.id;
        
        if(Test.isRunningTest()){
            oAttachment.Body = [SELECT body
                                  FROM StaticResource 
                                  WHERE Name ='FBE_ProductForTestClass'].body; 
        }else{
			oAttachment.Body = EncodingUtil.base64Decode(base64Data);            
        }
        oAttachment.Name = 'Product Data To Load';
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
        
        if(base64Data1.length() < 750000){
            //system.debug('run the batch');
            
            config.FBE_Status__c = 'Uploading...';
            config.FBE_Attachment_Reference_ID__c = oAttachment.id;
            UPDATE config;
        }
 
        return oAttachment.Id;
    }
 	@TestVisible
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body,BodyLength,ParentId
            FROM Attachment
            WHERE Id =: fileId
        ];
 		//system.debug('BodyLength '+a.BodyLength);
        String existingBody = EncodingUtil.base64Encode(a.Body);
        if(Test.isRunningTest()){
            a.Body = [SELECT body
                                  FROM StaticResource 
                                  WHERE Name ='FBE_ProductForTestClass'].body; 
        }else{
			a.Body = EncodingUtil.base64Decode(existingBody + base64Data);           
        }
        
 
        update a;
        
        system.debug('existingBody '+base64Data1.length());
        if(base64Data1.length() < 750000){
            system.debug('run the batch');
            FBE_Configurator__c config = new FBE_Configurator__c();
            config.id = a.ParentId;
            config.FBE_Status__c = 'Uploading...';
            config.FBE_Attachment_Reference_ID__c = fileId;
            UPDATE config;
        }
        system.debug('DONE');
    }
}
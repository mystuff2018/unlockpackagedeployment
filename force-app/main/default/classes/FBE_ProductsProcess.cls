public with sharing class FBE_ProductsProcess implements Database.Batchable<String>,Database.Stateful {
    public list<String> productsCsv;
    public ID parentId;
    Map<String,ID> prodLobWithId;
    public List<string> countOfstrings = new List<string>();
    Map<integer,string> csvWithIndexvalue = new Map<integer,string>();
    public integer j=0;
    public integer i=0;
    Map<integer,string> successRecs = new Map<integer,string>();
    Map<integer,string> errorRecs = new Map<integer,string>();
    List<String> prodsToSkipDuplicates = new List<String>();
    List<String> duplicateProducts = new List<String>();
    public FBE_ProductsProcess (List<string> productsCsv,ID parentId,Map<String,ID> prodLobWithId){
        this.productsCsv = productsCsv;
        this.parentId = parentId;
        this.prodLobWithId = prodLobWithId;
    }
    public Iterable<String> start(Database.BatchableContext BC) {
        return productsCsv;
    }

    public void execute(Database.BatchableContext info, List<String> prodsToInsert) {
        system.debug('prodsToInsert '+prodsToInsert[0]);
        // Do something really expensive with the string!
        countOfstrings.addAll(prodsToInsert);
        //prodsToInsert.remove(0);
        system.debug('dataToInsert +++ '+prodsToInsert.size());
        system.debug('dataToInsert +++ '+prodsToInsert[prodsToInsert.size()-1]);
        list<product2> prodToInsert = new List<product2>();
        
        List<string> dataProd;
        for(string str : prodsToInsert){
            //system.debug('$$$$$1');
            i++;
            csvWithIndexvalue.put(i,str);
            dataProd = str.split('~');
            product2 prod = new product2();
            if(dataProd.size() > 0 && ! prodsToSkipDuplicates.contains(dataProd[1].toUpperCase())){
                if(dataProd.size() > 0)
                    prod.productcode = dataProd[0]; //ROW_ID
                if(dataProd.size() > 1){
                    if(prodLobWithId != NULL && prodLobWithId.get(dataProd[1].toUpperCase()) != NULL){
                        prod.Id = prodLobWithId.get(dataProd[1].toUpperCase());
                    }
                    prod.Product_Brand_LOB_Combination__c = dataProd[1];//X_FBE_PROD_BRAND
                    prod.Name = dataProd[1];//X_FBE_PROD_BRAND
                    prodsToSkipDuplicates.add(dataProd[1].toUpperCase());
                }
                
                if(dataProd.size() > 2)
                    prod.FBE_LOB__c = dataProd[2];//X_FBE_LOB
                if(dataProd.size() > 3)
                    prod.FBE_Source__c = dataProd[3];//TYPE
                if(dataProd.size() > 4)
                    prod.FBE_Product_Type__c = dataProd[4];//X_FBE_PROD_TYPE
                if(dataProd.size() > 5)
                    prod.FBE_Business_Unit__c = dataProd[5];//X_FBE_PROD_GROUP
                if(dataProd.size() > 6)
                    prod.FBE_DPS_Product__c = dataProd[6]=='Y' ? true : false;//X_RECURRING_BILL_FLG
                if(dataProd.size() > 7)
                    prod.FBE_UDS_Product__c = dataProd[7]=='Y' ? true : false;//X_NDAA_FLG
                if(dataProd.size() > 8)
                    prod.FBE_Enterprise_Product__c = dataProd[8]=='Y' ? true : false;//X_CORP_DISC_FLG
                if(dataProd.size() > 9)
                    prod.FBE_MDC_Product__c = dataProd[9]=='Y' ? true : false;//X_EXCEPTION_FLG
                
                if(dataProd.size() > 10){
                    System.debug('BU Category-2 '+ dataProd[10]);
                    System.debug('BU Category of : '+ dataProd[0] + ' IS '+ dataProd[10]);
                    prod.FBE_BU_Category__c = dataProd[10];//BU Category
                }else{
                    prod.FBE_BU_Category__c = '';
                }
                
                    
                    prod.IsActive = true;
                    prodToInsert.add(prod);
            }else{
                duplicateProducts.add(dataProd[1].toUpperCase());
            }

            
                //system.debug('$$$$$1');
        }
        //system.debug('$$$$$2'+csvWithIndexvalue.size());
            if(prodToInsert.size() > 0 && ! csvWithIndexvalue.isEmpty()){
                
                //system.debug('$$$$$3');
                prodsToInsert.clear();
                system.debug('HEAP SIZE 3 '+Limits.getHeapSize() );
                //system.debug('$$$$$4'+prodToInsert.size());
                
                system.debug('HEAP SIZE 3 1 '+Limits.getHeapSize() );

                    //Database.saveResult[] srList=Database.INSERT(prodToInsert, false);
                    Schema.SObjectField f = Product2.Fields.Id;
                    Database.UpsertResult[] srList = Database.upsert(prodToInsert,f,false);
                    system.debug('$$$$$5');
                    for(Database.UpsertResult r: srList){
                        j++;
                        if(r.isSuccess()){
                            successRecs.put(j,'SUCCESS');
                        }
                        else{
                            for(Database.Error err : r.getErrors()){
                                errorRecs.put(j,err.getMessage());
                                system.debug('j_j_j'+j+'-----'+err.getMessage());
                            }
                        }
                    }
                    system.debug('HEAP SIZE -4 '+Limits.getHeapSize() +'____'+successRecs.size());
                  
                if(! successRecs.isEmpty()){
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
                        if(! priceBookMap.isEmpty()){
                            List<PricebookEntry> insertStandardPriceBookEntr = new List<PricebookEntry>();
                /*for(product2 prod : prodToInsert){
                                if(priceBookMap.get(prod.FBE_Source__c) != NULL){
                                    PricebookEntry priceBk = new PricebookEntry();
                                    priceBk.Product2Id = prod.id;
                                    priceBk.Pricebook2Id = priceBookMap.get('Standard Price Book');
                                    priceBk.unitprice = 0;
                                    priceBk.IsActive = true;
                                    insertStandardPriceBookEntr.add(priceBk);
                                }
                            }
                            if(insertStandardPriceBookEntr.size() > 0){
                                DATABASE.INSERT(insertStandardPriceBookEntr,FALSE);
                                system.debug('insertStandardPriceBookEntr '+insertStandardPriceBookEntr.size());
                                insertStandardPriceBookEntr.clear();
                                system.debug('insertStandardPriceBookEntr @@@2 '+insertStandardPriceBookEntr.size());
                            }*/
                            List<PricebookEntry> insertPriceBookEntr = new List<PricebookEntry>();
                            for(product2 prod : prodToInsert){
                                //added as per pricebook story
                                if(prod.FBE_Source__c == 'Dell DFN Siebel'){
                                    PricebookEntry priceBk = new PricebookEntry();
                                    priceBk.Product2Id = prod.id;
                                    priceBk.Pricebook2Id = priceBookMap.get('Standard Price Book');
                                    priceBk.unitprice = 0;
                                    priceBk.IsActive = true;
                                    insertStandardPriceBookEntr.add(priceBk);
                                }
                                if(prod.FBE_Source__c == 'EMC Fed SFDC'){
                                    PricebookEntry priceBk = new PricebookEntry();
                                    priceBk.Product2Id = prod.id;
                                    priceBk.Pricebook2Id = priceBookMap.get('Standard Price Book');
                                    priceBk.unitprice = 0;
                                    priceBk.IsActive = false;
                                    insertStandardPriceBookEntr.add(priceBk);
                                }
                                if(priceBookMap.get(prod.FBE_Source__c) != NULL){
                                    PricebookEntry priceBk = new PricebookEntry();
                                    priceBk.Product2Id = prod.id;
                                    priceBk.Pricebook2Id = priceBookMap.get(prod.FBE_Source__c);
                                    priceBk.unitprice = 0;
                                    priceBk.IsActive = true;
                                    insertPriceBookEntr.add(priceBk);
                                }
                                
                            }
                            //added as per pricebook story
                            if(insertStandardPriceBookEntr.size() > 0){
                                DATABASE.INSERT(insertStandardPriceBookEntr,FALSE);
                                system.debug('insertStandardPriceBookEntr '+insertStandardPriceBookEntr.size());
                                insertStandardPriceBookEntr.clear();
                                system.debug('insertStandardPriceBookEntr @@@2 '+insertStandardPriceBookEntr.size());
                            }
                            if(insertPriceBookEntr.size() > 0){
                                DATABASE.INSERT(insertPriceBookEntr,FALSE);
                                system.debug('insertPriceBookEntr '+insertPriceBookEntr.size());
                            }
                        }

                        prodToInsert.clear();
                        
                    }

                system.debug('HEAP SIZE 4 '+Limits.getHeapSize());
            }
        system.debug('HEAP SIZE 2 '+Limits.getHeapSize() );
        
    }

    public void finish(Database.BatchableContext info) {
        system.debug('COunt'+countOfstrings.size());
        system.debug('error'+errorRecs.values().size());
        system.debug('success'+successRecs.values().size());
        system.debug('products '+csvWithIndexvalue.size());
        system.debug('parentId '+parentId);
        string errorBody = '';
        string successBody = '';
        /*string csvBody = '';
        if(! csvWithIndexvalue.isEmpty()){
            for(string str : csvWithIndexvalue.values()){
                csvBody+=str+'\r';
            }
            if(csvBody != ''){
                Attachment oAttachment = new Attachment();
                oAttachment.parentId = parentId;
                oAttachment.Body = blob.valueOf(csvBody);
                oAttachment.Name = 'Csv File';
                INSERT oAttachment;
            }
        }*/
        if(errorRecs.keySet().size() > 0){
            for(integer i : errorRecs.keySet()){
                if(csvWithIndexvalue.get(i) != NULL && errorRecs.get(i) != NULL){
                    errorBody+=csvWithIndexvalue.get(i)+'~'+errorRecs.get(i)+'\r';
                    system.debug('Error Recs '+errorRecs.get(i)+'___'+i);
                }
            }
        }
        
        if(successRecs.keySet().size() > 0){
            for(integer i : successRecs.keySet()){
                if(csvWithIndexvalue.get(i) != NULL && successRecs.get(i) != NULL){
                    successBody+=csvWithIndexvalue.get(i)+'~'+successRecs.get(i)+'\r';
                }
                
            }
        }
        FBE_Configurator__c config = new FBE_Configurator__c();
        if(errorBody != '' && successBody != ''){
            List<Attachment> attchToInsert = new List<Attachment>();
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            oAttachment.Body = blob.valueOf(errorBody);
            oAttachment.Name = 'Error File';
            attchToInsert.add(oAttachment);
            
            Attachment oAttachment1 = new Attachment();
            oAttachment1.parentId = parentId;
            oAttachment1.Body = blob.valueOf(successBody);
            oAttachment1.Name = 'Success File';
            attchToInsert.add(oAttachment1);
            INSERT attchToInsert;
            config.id = parentId;
            config.FBE_Status__c = 'Succesfully processed';
        }else if(successBody != '' && errorBody == ''){
            List<Attachment> attchToInsert = new List<Attachment>();
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            oAttachment.Body = blob.valueOf(successBody);
            oAttachment.Name = 'Success File';
            attchToInsert.add(oAttachment);
            INSERT attchToInsert;
            config.id = parentId;
            config.FBE_Status__c = 'Succesfully processed';
        }else if(successBody == '' && errorBody != ''){
            List<Attachment> attchToInsert = new List<Attachment>();
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            oAttachment.Body = blob.valueOf(errorBody);
            oAttachment.Name = 'Error File';
            attchToInsert.add(oAttachment);
            INSERT attchToInsert;
            config.id = parentId;
            config.FBE_Status__c = 'Succesfully processed';
        }
        //config.FBE_Error_Log__c = 'found '+duplicateProducts.size()+' duplicate records.';
        if(config != NULL){
            UPDATE config;
        }
    }
}
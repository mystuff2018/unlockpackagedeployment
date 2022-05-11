public class IDS_ProcessSkuData {
    public static void IDS_Process(Map<String,List<String>> skuString,Boolean callBatch){
        List<SKU_Effort_Map__c> skuMap = new List<SKU_Effort_Map__c>();
        for(String str : skuString.keySet()){
                SKU_Effort_Map__c sku = new SKU_Effort_Map__c();
            	sku.Description__c = str;
            	/*sku.Duration_Days__c = Decimal.valueOf(skuString.get(str)[0].split('~')[2]);
            	string skustr = skuString.get(str)[0];
                if(skustr.split('~').size() > 3){
                    sku.Distinct_Project__c = (! string.isBlank(skustr.split('~')[3]) && skustr.split('~')[3] != '0')?true:false;
                }
                if(skustr.split('~').size() > 22){
                    sku.Residency__c = (! string.isBlank(skustr.split('~')[22]) && skustr.split('~')[22] != '0')?true:false;
                }*/
            	//sku.Distinct_Project__c = skuString.get(str)[0].split('~')[3];
            	sku.IDS_SKU_Combination__c = String.join(skuString.get(str),'\r');
            	skuMap.add(sku);
        }
        if(skuMap.size() > 0){
            system.debug('skuMap '+ skuMap.size());
        	//UPSERT skuMap Description__c;
        	List<Database.upsertResult> skueffortMap = Database.upsert(skuMap,SKU_Effort_Map__c.Fields.Description__c,false);
            //IDS_SKU_Loader_Logic.ids_SKu_Loader(JSON.Serialize(skuMap));
            if(callBatch){
                IDS_Data_Loader_SKU be = new IDS_Data_Loader_SKU();
				database.executeBatch(be,200);
            }
    	}
    }
}
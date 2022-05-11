public class IDS_DataLoaderController {
 	public static string base64Data1='';
    public static boolean callBatch = false;
    @AuraEnabled
    public static string saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        Map<String,List<String>> skuWithCombinations = new Map<String,List<String>>();
        Map<integer,string> skuDescOrder = new Map<integer,string>();
        integer i=1;
        string concate;
        base64Data1 = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String dataChunk;
        if(fileId != '' && fileId != NULL){
            dataChunk = fileId+EncodingUtil.base64Decode(base64Data1).toString();
        }else{
            dataChunk = EncodingUtil.base64Decode(base64Data1).toString();
        }
        List<String> dataString = new List<String>();
        dataString.addAll(dataChunk.split('\r'));
        system.debug('base64Data1 '+base64Data1.length());
        if(base64Data1.length() < 600000){
            callBatch = true;
        }else{
            concate = dataString[dataString.size()-1];
        	dataString.remove(dataString.size()-1);
        }
        for(String str : dataString){
            if(skuWithCombinations.get(str.split('~')[1]) == NULL){
                skuWithCombinations.put(str.split('~')[1],new List<String>{str});   
                skuDescOrder.put(i,str.split('~')[1]);
                i++;
            }else{
                skuWithCombinations.get(str.split('~')[1]).add(str);
            }
         }
        
        if(! skuWithCombinations.isEmpty()){
            if(! callBatch){
                integer skuSize = skuDescOrder.keySet().size();
           	    List<String> skuToConcatenate = skuWithCombinations.get(skuDescOrder.get(skuSize));
             	concate = String.join(skuToConcatenate,'\r')+'\r'+concate;
            	skuWithCombinations.remove(skuDescOrder.get(skuSize));
                IDS_ProcessSkuData.IDS_Process(skuWithCombinations,callBatch);
            }else{
                integer j;
                j = skuWithCombinations.keyset().size();
                j++;
                string dataCh;
                IDS_ProcessSkuData.IDS_Process(skuWithCombinations,callBatch);
            }
        }
        return concate;
    }
}
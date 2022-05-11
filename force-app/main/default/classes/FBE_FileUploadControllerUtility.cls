/**************
*@ Class Name                                                    : FBE_FileUploadControllerUtility
*@ Description                                                   : This class is written for splitting csv file into lines and gathering produts to inactive.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-31-2020 [Lavakumar Tonupunuri]
*@ Modification Log                                              : 
***************/ 
public class FBE_FileUploadControllerUtility{
    public static void processLoad(string csvFileBody,ID parentId){
        List<string> dataLines = new List<string>();
        system.debug('csvFileBody '+csvFileBody.length());
        //system.debug('csvAsString '+EncodingUtil.base64Decode(csvFileBody).toString().length());
        //dataLines.addAll(EncodingUtil.base64Decode(csvFileBody).toString().split('\r'));
        integer length = EncodingUtil.base64Decode(csvFileBody).toString().length();
        //integer 
        integer indexStart = 0;
        integer indexPosition = 250000;
        if(Test.isRunningTest()){
            indexPosition = 100000;
        }
        integer k = length/indexPosition ; 
        
        system.debug('kkkkkkkkkkk '+k);
        string lastIndexedCsv='';
        if(k == 0){
            dataLines.addAll((EncodingUtil.base64Decode(csvFileBody).toString()).split('\r'));
            system.debug('dataLines'+dataLines);
            if(dataLines.size() > 0){
               dataLines.remove(0);
            }
            system.debug('dataLines'+dataLines);
        }else{
        integer i;
        integer j = indexPosition;
        integer l = 0;
        for(i=indexStart;i<length;i=j){
            l++;
            if(length == j){
                break;
            }
            j = length>i+indexPosition ? i+indexPosition : i+(length-i);
            if(k+1 == l){
                dataLines.addAll((lastIndexedCsv+EncodingUtil.base64Decode(csvFileBody).toString().substring(i,j)).split('\r'));
				system.debug('1 '+dataLines[0]);
				system.debug('1 '+dataLines[dataLines.size() - 1]);
            }else if(l > 1){
                dataLines.addAll((lastIndexedCsv+EncodingUtil.base64Decode(csvFileBody).toString().substring(i,j)).split('\r'));
                lastIndexedCsv = dataLines[dataLines.size()-1];    
                dataLines.remove(dataLines.size()-1);
                	
                	//dataLines.remove(dataLines.size()-1);
					system.debug('1 '+dataLines[0]);
					system.debug('1 '+dataLines[dataLines.size() - 1]);
            }else{
                dataLines.addAll((EncodingUtil.base64Decode(csvFileBody).toString().substring(i,j)).split('\r'));
                dataLines.remove(0);
                lastIndexedCsv = dataLines[dataLines.size()-1];
                dataLines.remove(dataLines.size()-1);
				system.debug('1 '+dataLines[0]);
				system.debug('1 '+dataLines[dataLines.size() - 1]);
            }
        }
        }        
        system.debug('dataLines '+dataLines.size());
        if(dataLines.size() > 0){
            
            List<product2> existingProductsToInactive = new List<product2>();
            Map<String,ID> productLobWithId = new Map<String,ID>();
            // quirying upto 50000 records.
            for(product2 prod : [select id,Product_Brand_LOB_Combination__c,isActive from product2 ]){
                if(prod.isActive == true){
                 	prod.isActive = false;
                    existingProductsToInactive.add(prod);
                }
                productLobWithId.put(prod.Product_Brand_LOB_Combination__c.toUpperCase(),prod.id);
                
                
            }
            //system.debug('existingProductsToInactive'+existingProductsToInactive[0]);
			if(existingProductsToInactive.size() > 0){
                system.debug('If block');
				Id jobId = Database.executeBatch(new FBE_InactiveExistingProducts(existingProductsToInactive,dataLines,parentId,productLobWithId), 1000);
            }else{
                system.debug('If else block');
                Id jobId = Database.executeBatch(new FBE_ProductsProcess(dataLines,parentId,productLobWithId), 1000);
            }
         }
    }
}
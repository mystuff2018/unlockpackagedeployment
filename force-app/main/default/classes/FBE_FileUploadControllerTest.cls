@isTest
public class FBE_FileUploadControllerTest {
    @isTest
    public static void  FBE_FileUploadControllerMethod1(){
        string str ='1-CVJHXT~VSPHERE~VMware~Dell DFN Siebel~~~~~~~28-JAN-20~'
					+'1-CVJHXY~VREALIZE BUSINESS~VMware~Dell DFN Siebel~~~~~~~30-JAN-20~'
					+'1-CVJHY3~VREALIZE AUTOMATION~VMware~Dell DFN Siebel~~~~~~~30-JAN-20~';
        string fieldId = '';
        blob b = blob.valueOf(str);
       // string base64 = EncodingUtil.urlEncode(str, 'UTF-8');
       string base64 = b.toString();
        List < Pricebook2 > priceBookList = new List < Pricebook2 > ();
        	
        Pricebook2 PBRecord2 = new Pricebook2();
            PBRecord2.Name = 'EMC PriceBook';
            PBRecord2.IsActive = True;
            priceBookList.add(PBRecord2);
        
        Pricebook2 PBRecord3 = new Pricebook2();
            PBRecord3.Name = 'Standard Price Book';
            PBRecord3.IsActive = True;
            priceBookList.add(PBRecord3);
        Insert priceBookList;
        id fileid = FBE_FileUploadController.saveChunk(NULL,NULL,base64,null,fieldId);
        
    }
    @isTest
    public static void  FBE_FileUploadControllerMethod2(){
        string str ='1-CVJHXT~VSPHERE~VMware~Dell DFN Siebel~~~~~~~28-JAN-20~'
					+'1-CVJHXY~VREALIZE BUSINESS~VMware~Dell DFN Siebel~~~~~~~30-JAN-20~'
					+'1-CVJHY3~VREALIZE AUTOMATION~VMware~Dell DFN Siebel~~~~~~~30-JAN-20~';
        string fieldId = '';
        blob b = blob.valueOf(str);
       // string base64 = EncodingUtil.urlEncode(str, 'UTF-8');
       string base64 = b.toString();
        List<Product2> prodList = FBE_UtilityFactory_Test.createProducts(1);
        prodList[0].Product_Brand_LOB_Combination__c = 'abc';
        Insert prodList;
        List < Pricebook2 > priceBookList = new List < Pricebook2 > ();
        Pricebook2 PBRecord = new Pricebook2();
            PBRecord.Name = 'Dell PriceBook';
            PBRecord.IsActive = True;
            priceBookList.add(PBRecord);
        	
        Pricebook2 PBRecord2 = new Pricebook2();
            PBRecord2.Name = 'EMC PriceBook';
            PBRecord2.IsActive = True;
            priceBookList.add(PBRecord2);
        
        Pricebook2 PBRecord3 = new Pricebook2();
            PBRecord3.Name = 'Standard Price Book';
            PBRecord3.IsActive = True;
            priceBookList.add(PBRecord3);
        Insert priceBookList;
        id fileid = FBE_FileUploadController.saveChunk(NULL,NULL,base64,null,fieldId);
        FBE_FileUploadController.appendToFile(fileid,base64);
        
    }
    
}
/****************************************************************************************************
 * Author         : Dell Team - CPQ [Ravi Sirigiri - STORY 11263048]
 * Description    : Federal Partner Self Service Quote :  View Quote related list. 
 * Date Created   : 03-Nov-2021
 * Version        : 1.0
 * Modification Log           Developer          Last Modified Date           Description
 * 1.0                        Ravi Sirigiri      03-Nov-2021
 * 		                      Ravi Sirigiri      12-Dec-2021				  StoryNo:11263071
 * 							  Myla Sireesha      12-Dec-2021                  StoryNo:11648153
 ****************************************************************************************************/

public with sharing class FBE_CPQ_OptyRelatedListController {
    
    Public static final string FBE_FPRM_Reseller_Profile = 'FBE FPRM Partner Reseller';
    Public static final string FBE_FPRM_Distributor_Profile = 'FBE FPRM Partner Distributor';   
    
    /*
    *  Modified the code for Story numbers 11263071 and 11648153
    */           
    @AuraEnabled(cacheable=true)
    Public static list<wrapdata> getQuoteData(String opptyId){
        Boolean isHideOpty = false;
        
        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
		
		list<wrapdata> wrapDataList = new list<wrapdata>();
		
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId()]?.Name;
        List<Opportunity> optyList = new List<Opportunity>();
        if(profileName.equalsIgnoreCase(FBE_FPRM_Distributor_Profile) || profileName.equalsIgnoreCase(FBE_FPRM_Reseller_Profile)){
           
		   optyList = [SELECT Id, FBE_FPRM_Fulfilment_Path__c, FBE_Distributor__c FROM Opportunity
                                         	WHERE Id =: String.escapeSingleQuotes(opptyId) LIMIT 1];
            
			isHideOpty = (profileName.equalsIgnoreCase(FBE_FPRM_Reseller_Profile) && !optyList.isEmpty() && optyList[0]?.FBE_FPRM_Fulfilment_Path__c == 'Distribution') ? true : false; 
											
        }
		
		String query = 'SELECT Id, Name, QuoteNumber, FBE_CPQ_Solution_ID__c, FBE_CPQ_Quote_Total__c, ExpirationDate FROM Quote';	
        String OppId = ' \'' + String.escapeSingleQuotes(opptyId) + '\'';
		if(!isHideOpty && profileName.equalsIgnoreCase(FBE_FPRM_Distributor_Profile) && !optyList.isEmpty()){
             String distributerId = optyList[0]?.FBE_Distributor__c;
                distributerId = String.isNotBlank(distributerId) ? ' \'' + String.escapeSingleQuotes(distributerId) + '\'' : distributerId;
                   query+= ' WHERE OpportunityId ='+OppId;
				   query+= ' AND FBE_CPQ_Associated_Distributor__c ='+distributerId;
                   query+= ' ORDER BY LastModifiedDate DESC';
				   
			quoteMap = getQuoteInfo(query);
			
		}else if(!isHideOpty) {
			 query+= ' WHERE OpportunityId ='+OppId;
             query+= ' ORDER BY LastModifiedDate DESC';
			 System.debug('query=='+query);
			quoteMap = getQuoteInfo(query);
			
		}else{
			
			    wrapdata wrap = new wrapdata();
                wrap.quoteRec = new Quote();
                wrap.files = new list<WrapFileTpe>();
                wrap.isbuttonDissable =  true;
                wrap.isShowComponent = false;
                wrapDataList.add(wrap);
            
				return wrapDataList;
		}
		
		if(!quoteMap.isEmpty()){
			wrapDataList = getFiles(quoteMap);
		}
       
        
        return wrapDataList;
        
    }
	
	@AuraEnabled(cacheable=true)
    Public static wrapdata getQuoteFilesData(Id quoteId){
		Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        quoteMap.put(quoteId, new Quote(Id=quoteId));
		list<wrapdata> wrapList = getFiles(quoteMap);
		wrapdata wrapdataRec = wrapList.isEmpty() ? new wrapdata() : wrapList[0];
		
		return wrapdataRec;
	}
    
	Public static Map<Id, Quote> getQuoteInfo(String query){
		Map<Id, Quote> QuoteMap = new Map<Id, Quote> ();
		for(Quote q : database.query(query)){			
			QuoteMap.put(q.id, q);			
		}		
		return QuoteMap;
	}
	
	
	public static List<wrapdata> getFiles(Map<Id, Quote> quoteMap){
		
		list<wrapdata> wrapdatalist = new List<wrapdata>();
		Map<Id, ContentDocumentLink> cdMap = new Map<Id, ContentDocumentLink>();
		Map<Id, List<WrapFileTpe>> cvMap = new  Map<Id,List<WrapFileTpe>>(); 
		
		 for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId 
                                           FROM ContentDocumentLink WHERE 
                                           LinkedEntityId IN : quoteMap.keySet()]){
                                               cdMap.put(cdl.ContentDocumentId, cdl);
                                               
                                           }  
										   
										   
		if(!cdMap.isEmpty()){
            for(ContentVersion cv : [SELECT Id, filetype, ContentDocumentId from ContentVersion 
                                     WHERE ContentDocumentId IN : cdMap.keyset()]){                                  
                                         List<WrapFileTpe> fileList = new List<WrapFileTpe>();
                                         WrapFileTpe file = new WrapFileTpe();
                                         if(cvMap.containskey(cdMap.get(cv.ContentDocumentId)?.LinkedEntityId)){
                                             file.fType =  getFileType(cv.filetype);
                                             file.docId = cv.ContentDocumentId;
                                             cvMap.get(cdMap.get(cv.ContentDocumentId)?.LinkedEntityId).add(file);
                                         }
                                         else{
                                             file.fType = getFileType(cv.filetype);
                                             file.docId = cv.ContentDocumentId;
                                             fileList.add(file); 
                                             cvMap.put(cdMap.get(cv.ContentDocumentId)?.LinkedEntityId, new List<WrapFileTpe>{file});
                                         }               
                                         
                                     }  
            
        }

		if(!quoteMap.isEmpty()){
            for(Quote quoteRec : quoteMap.values()){
                
                wrapdata wrap = new wrapdata();
                wrap.quoteRec = quoteRec;
                wrap.files = cvMap.containskey(quoteRec.Id) ?  cvMap.get(quoteRec.Id) : new list<WrapFileTpe>();
                wrap.isbuttonDissable = wrap.files.isEmpty() ? true : false;
                wrap.isShowComponent = true;
                wrapDataList.add(wrap);
            }
        }  
        
        return wrapDataList;
										   
		
	}
    
   
    public static string getFileType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'xml'
            {
                return 'XML';
            }
            when 'excel_x'
            {
                return 'EXCEL';
            }
            when 'excel'{
               return 'EXCEL'; 
            }
            when 'html'
            {
                return 'HTML';
            }
            when 'pdf'
            {
                return 'PDF';
            }            
            when else {
                return fileType.toUpperCase();
            }
        }
    }
    
    
    public class WrapFileTpe{
        @AuraEnabled public string fType{get;set;}
        @AuraEnabled public string docId{get;set;}
    }
    
     
    public class wrapdata {
        @AuraEnabled
        public Quote quoteRec{get; set;}
        @AuraEnabled
        public Boolean isbuttonDissable {get; set;}
        @AuraEnabled
        public list<WrapFileTpe> files{get;set;}
        @AuraEnabled
        public Boolean isShowComponent{get; set;}
        
    }    
    
}
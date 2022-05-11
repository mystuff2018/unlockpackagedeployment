/*
*@ Trigger Name                                                  : FBE_CPQ_QuoteAttachmentSharing 
*@ Description                                                   : This trigger & handler is used to share the quote attachemnts with partner user####11432375
*@ CreatedBy                                                     : Varsha Singh            
*@Test Class                                                     :FBE_CPQ_QuoteAttachmentSharing_Test
*@Modified By                                                    : Varsha Singh
* 1.0    04- Mar - 2022
*/

public with sharing class FBE_CPQ_QuoteAttachmentSharingHelper {
    
    public static void quoteFileSharing(List<ContentDocumentLink> cdlList){

        Boolean LoggedInUser = [Select Id,FBE_Integration_User__c From User Where Id = :UserInfo.getUserId()][0].FBE_Integration_User__c;
          

        /* Query the schema of Quote */
        String lhwQuotePrefix = Schema.getGlobalDescribe().get('Quote').getDescribe().getKeyPrefix();

        List<ContentDocumentLink> listToUpdate = new List<ContentDocumentLink>();
        if(cdlList.size()>0){
            for (ContentDocumentLink cdl : cdlList) {
                if (String.valueOf(cdl.LinkedEntityId).startsWithIgnoreCase(lhwQuotePrefix) && cdl.LinkedEntityId!=null   && LoggedInUser==true) {
                    cdl.Visibility = 'AllUsers';
                    listToUpdate.add(cdl); /* final list updated*/
                }
            }  
        }
        
    }
}
/*
*@ Class Name                                                    : FBE_DealRegRemove 
*@ Description                                                   : This method will delete the access privilege to the record when user is removed from the Deal Registration Team
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 18-01-2019 [Pratibha]
*@ Modification Log                                              : 05-19-2020 [Abhishek Kawle] : Added Apex Sharing Reason for Deal Sharing query as part of Defect #8642038                    
*/
public without sharing class FBE_DealRegRemove {
   public static void DeleteDealTeam(List<FBE_Deal_Registration_Team__c> oldList){
   //system.debug('recordPId#####'+recordPId.size()); 
 //system.debug('recordPId#####'+recordPId); 
 
     System.debug('oldList: '+oldList);
       List<id> dealids= new List<id>();
       List<id> userids= new List<id>();
	for(FBE_Deal_Registration_Team__c dtm : oldList){
		if(dtm.Created_From_Batch__c == false)
		{
			
            dealids.add(dtm.Deal_Registration__c);
            userids.add(dtm.User__c);
		}
	}
       String dealSharingReason = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c;
       List<Deal_Registration__Share> drs = [SELECT id,UserOrGroupId,parentid FROM Deal_Registration__Share WHERE RowCause =:dealSharingReason and parentid in: dealids and UserOrGroupId in:userids];
        
       
       try{
            if(drs!=null && drs.size()>0){
                Database.Delete(drs, false);
            }
       }
        catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        } 
      
    }
}
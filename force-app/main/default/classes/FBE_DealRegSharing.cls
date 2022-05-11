public without sharing class FBE_DealRegSharing {
  //  @InvocableMethod
  /*  public static void manualShareRead(List<Id> recordId){
        try{  
            FBE_Deal_Registration_Team__c   dealRegTeam = [Select Id,Access_level__c,Deal_Registration__c,User__c From FBE_Deal_Registration_Team__c Where Id =:recordId];
            // Create new sharing object for the custom object Job.
            Deal_Registration__Share dealShr  = new Deal_Registration__Share();
            // Set the ID of record being shared.
            dealShr.ParentId = dealRegTeam.Deal_Registration__c;
            // Set the ID of user or group being granted access.
            dealShr.UserOrGroupId = dealRegTeam.User__c;
            // Set the access level.
            if(dealRegTeam.Access_level__c == 'Read'){
                dealShr.AccessLevel = dealRegTeam.Access_level__c;
            }else{
                dealShr.AccessLevel = 'Edit'; 
            }    
            // Insert the sharing record and capture the save result. 
            // The false parameter allows for partial processing if multiple records passed 
            // into the operation.
            Database.SaveResult sr = Database.insert(dealShr,false);
            
            // Process the save results.
            if(sr.isSuccess()){
                // Indicates success
                system.debug('Success Msg'+recordId);
            }
            else {
                // Get first save result error.
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to trival access level.Access level must be more permissive than the object's default.
                // These sharing records are not required and thus an insert exception is acceptable. 
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                   err.getMessage().contains('AccessLevel')){
                       // Indicates success.
                       system.debug('Success Msg'+recordId);
                   }
                else{
                    // Indicates failure.
                    // return err.getMessage();
                    system.debug('Error Msg'+err.getMessage());
                }
            }
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }finally{
            //optional
        } 
    }*/
    @InvocableMethod
    public static void manualShareRead(list<FBE_Deal_Registration_Team__c> dealTeamList){
       List<Deal_Registration__Share> dealShrList = new List<Deal_Registration__Share>();        
        for(Integer k=0, l= dealTeamList.Size(); k < l; k++){
        Deal_Registration__Share dealShr  = new Deal_Registration__Share();
        // Set the ID of record being shared.
            dealShr.ParentId = dealTeamList[k].Deal_Registration__c;
            // Set the ID of user or group being granted access.
            dealShr.UserOrGroupId = dealTeamList[k].User__c;
            // Set the access level.
            if(dealTeamList[k].Access_level__c == 'Read'){
                dealShr.AccessLevel = dealTeamList[k].Access_level__c;
            }else{
                dealShr.AccessLevel = 'Edit'; 
            }
        dealShrList.Add(dealShr); 
        }
        //system.debug('dealShrList'+dealShrList.size());
        try{
            insert dealShrList;            
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }        
    }      
}
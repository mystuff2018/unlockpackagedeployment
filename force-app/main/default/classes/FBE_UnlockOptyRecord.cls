/**************
 *@ Class Name        : FBE_UnlockOptyRecord
 *@ Description       : This class is written to unlock an Opportunity Record whenever it's stage is not Cancelled / Closed / Won.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 03-01-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to unlock an Opportunity Record.
 ***************/
public without sharing class FBE_UnlockOptyRecord {
    @InvocableMethod
    public static void unlockOpty(List<Opportunity> oppList){
        try{
            Approval.UnlockResult[] lrList = Approval.unlock(oppList,false);
            
            for(Approval.UnlockResult lr : lrList) {
            if (lr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully unlocked Opty with ID: ' + lr.getId());
            }
            /*else {
                // Operation failed, so get all errors                
                for(Database.Error err : lr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opty fields that affected this error: ' + err.getFields());
                }
            } */
            }
        }
        
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }
}
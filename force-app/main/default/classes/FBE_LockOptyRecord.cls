/**************
 *@ Class Name        : FBE_LockOptyRecord
 *@ Description       : This class is written to Lock an Opportunity Record whenever it's stage is Cancelled / Closed / Won.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 03-01-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to lock an Opportunity Record.
 ***************/
public with sharing class FBE_LockOptyRecord {
    @InvocableMethod
    public static void lockOpty(List<Opportunity> oppList){
        try{
            Approval.LockResult[] lrList = Approval.lock(oppList,false);
            
            for(Approval.LockResult lr : lrList) {
            if (lr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully locked Opty with ID: ' + lr.getId());
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
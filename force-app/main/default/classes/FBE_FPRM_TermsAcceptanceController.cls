/* Created By : Saikumar
 * Created Date : 3/2/2021, Created as part of Feature# 9912060
 * Purpose : it is a component controller for 'FBE_FPRM_TermsAcceptance' VF page to show T&C acceptance page and capture the last accepted date. 
 */

public with sharing class FBE_FPRM_TermsAcceptanceController {
    public boolean displayTerms {get;set;}
    public FBE_FPRM_TermsAcceptanceController(){      
        displayTerms = false;
    }
    public pagereference onAgree(){
        System.debug('inside onAgree');
        try{
            UPDATE new User(id = Userinfo.getUserId() , FBE_FPRM_Terms_Conditions_Last_Accepted__c = System.now());
        }Catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
            System.debug('Exception in onAgree()'+e);
        }
        return Auth.SessionManagement.finishLoginFlow();
    }
    
    public PageReference displayTermsPageAndConditions(){
        System.debug('inside displayTermsPageAndConditions');
        Integer noOfDays;
        User currentUser = [SELECT FBE_FPRM_Terms_Conditions_Last_Accepted__c FROM User WHERE id =: Userinfo.getUserId()];
        DateTime dT = currentUser.FBE_FPRM_Terms_Conditions_Last_Accepted__c;
        
        String td = System.label.FBE_FPRM_Terms_Date;
        Datetime dtt = DateTime.valueOfGmt(td);
        System.debug('dT ' + dT);
        System.debug('dtt: '+dtt);
        
        if(dT != null){
            Date actptDate = date.newinstance(dT.year(), dT.month(), dT.day());
            noOfDays = actptDate.daysBetween(system.today());
            System.debug('noOfDays btw today & last acptance : '+noOfDays);
        }
        if(currentUser.FBE_FPRM_Terms_Conditions_Last_Accepted__c == null || noOfDays > 365 || dtt > currentUser.FBE_FPRM_Terms_Conditions_Last_Accepted__c){
            displayTerms = true;
        }else{
            displayTerms = false;
            return Auth.SessionManagement.finishLoginFlow();
        }
        return null;
    }
    public PageReference doLogout(){
        System.debug('logging out..');
        return null;
    }
}
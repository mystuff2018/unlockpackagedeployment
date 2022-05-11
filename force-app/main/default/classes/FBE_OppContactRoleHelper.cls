/********************************
*@ Class Name         : FBE_OppContactRoleHelper
*@ Description        : An 'on view' trigger for standard Oppo page layout that compares the current OCR to some prior value of the OCR.
                        Apex controller has a constructor and one method with a future annotation. 
                        The future annotation ensures there's no lack time when the page is loaded due to the "hidden" Apex processing you'll be doing.
*@ CreatedBy          : Deloitte Consulting
*@ CreatedOn          : 26-04-2017 [Namita Verma]
*@ Modification Log   : 07/15/2020 - [Deloitte: Abhishek Kawle] : Modified to include Customer Contact record type on Contact Query.
																  IDS Feature #7868086
*********************************/
public with sharing class FBE_OppContactRoleHelper {
    public Opportunity opp;
    public FBE_OppContactRoleHelper(ApexPages.StandardController stdController) {
        opp = (Opportunity) stdController.getRecord();
    }
    public void rollupOppContacts() {
        FBE_OppContactRoleHelper.rollupOppContactsFuture(opp.Id);
    }
    @future public static void rollupOppContactsFuture(Id oppId) {
        Contact[] contactList = [SELECT Id, Name FROM Contact
            WHERE Id IN(SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId =: oppId)
                                 AND RecordType.DeveloperName = 'FBE_Customer_Contact'
        ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: oppId];
        update opp;
    }
}
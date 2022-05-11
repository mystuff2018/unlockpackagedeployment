public with sharing class AccountingAcknowledgmentHandler extends TriggerHandler {

    public override void afterInsert() {
        updateAccountingAcknowledgmentBasedInNewMessages();
    }

    public override void beforeInsert() {
        getProjectId();
    }

    //update the Accounting Acknowledgment project field based in new novora updates
    private void updateAccountingAcknowledgmentBasedInNewMessages() {
        List<Accounting_Acknowledge__c> projAccounting = new List<Accounting_Acknowledge__c>();
        List<String> projIds = new List<String>();
        Map<String, pse__Proj__c> projSource = new Map<String, pse__Proj__c>();
        List<pse__Proj__c> projectFinalUpdate = new List<pse__Proj__c>();
        List<ExceptionLogger__c> exceptionsToLog = new List<ExceptionLogger__c>();
        List<FeedItem> projChatterErrorMassages = new List<FeedItem>();
        
          for (Accounting_Acknowledge__c accountingToAdd : (List<Accounting_Acknowledge__c>) Trigger.new) {
            if (accountingToAdd.Object__c == 'PROJECTS' && accountingToAdd.Project_ID__c != null && !projIds.contains(accountingToAdd.Project_ID__c)){
                projAccounting.add(accountingToAdd);
                projIds.add(accountingToAdd.Project_ID__c);
                System.debug('====' +accountingToAdd.Project_ID__c);
            } 
        }

        
        List<pse__Proj__c> projectsData = [
                SELECT Id, pse__Project_ID__c, Accounting_acknowledgement_status__c, RecordType.Name
                FROM pse__Proj__c
                WHERE pse__Project_ID__c IN :projIds
        ];

        for (pse__Proj__c proj : projectsData) {
            projSource.put(proj.pse__Project_ID__c, proj);
        }

        for (Accounting_Acknowledge__c pAccounting : projAccounting) {

            if (pAccounting.Status__c == null || pAccounting.Project_ID__c == null) {
                if (pAccounting.Project_ID__c == null) {
                    exceptionsToLog.add(exceptionHandler('The message dont contains project Id', null));
                }
                continue;
            }
            pse__Proj__c projUpdate = projSource.get(pAccounting.Project_ID__c);
            projUpdate.Accounting_acknowledgement_status__c = pAccounting.Status__c;
            if (pAccounting.Status__c.equalsIgnoreCase('Processed')) {
                if (projUpdate.RecordType.Name != 'Allocation' && projUpdate.RecordType.Name != 'Global') {
                    projUpdate.pse__Closed_for_Time_Entry__c = false;
                }

            } else if (pAccounting.Status__c.containsIgnoreCase('error')) {
                FeedItem post = new FeedItem();
                post.ParentId = projUpdate.Id;
                post.Body = 'Project Accounting Tool reported error: ' + pAccounting.Message__c ;
                projChatterErrorMassages.add(post);
                if (projUpdate.RecordType.Name != 'Allocation' && projUpdate.RecordType.Name != 'Global') {
                    projUpdate.pse__Closed_for_Time_Entry__c = true;
                }
            } else if (!pAccounting.Status__c.equalsIgnoreCase('Processed')) {
                if (projUpdate.RecordType.Name != 'Allocation' && projUpdate.RecordType.Name != 'Global') {
                    projUpdate.pse__Closed_for_Time_Entry__c = true;
                }
            }
            projectFinalUpdate.add(projUpdate);
        }
        Database.SaveResult[] savedResults = Database.update(projectFinalUpdate, false);
        for (Database.SaveResult r : savedResults) {
            if (!r.isSuccess()) {
                for (Database.Error e : r.getErrors()) {
                    System.debug('Error in the project accounting acknowledge update' + e.getMessage());
                    exceptionsToLog.add(exceptionHandler(e.getMessage(), e.getFields()));
                }
            }
        }
        Database.insert(exceptionsToLog, false);
        Database.insert(projChatterErrorMassages, false);
    }

    private void getProjectId() {
        Map<String, pse__Proj__c> projMap = new Map<String, pse__Proj__c>();
        List<String> projectsFriendlyIds = new List<String>();

        for (Accounting_Acknowledge__c accounting : (List<Accounting_Acknowledge__c>) Trigger.new) {
            projectsFriendlyIds.add(accounting.Project_ID__c);
        }

        List<pse__Proj__c> projs = [SELECT Id,pse__Project_ID__c FROM pse__Proj__c WHERE pse__Project_ID__c IN :projectsFriendlyIds];

        for (pse__Proj__c proj : projs) {
            projMap.put(proj.pse__Project_ID__c, proj);
        }

        for (Accounting_Acknowledge__c accounting : (List<Accounting_Acknowledge__c>) Trigger.new) {
            accounting.Project__c = projMap.get(accounting.Project_ID__c).Id;
        }

    }

    @TestVisible
    private static ExceptionLogger__c exceptionHandler(String message, List<String> fields) {
        String fullMessage = fields != null ? 'Accounting Acknowledgment error when trying to insert: ' + message + ' Field: ' + fields : 'Accounting Acknowledgment error when trying to insert: ' + message;
        ExceptionLogger__c excp = new ExceptionLogger__c();
        excp.Apex_Class__c = 'AccountingAcknowledgmentHandler';
        excp.Description__c = fullMessage;
        excp.Error_Code__c = message;
        return excp;
    }

}
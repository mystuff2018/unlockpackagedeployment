public with sharing class ProjectBuidLocalChannelHandler {

    public static void setBuidAndLocalChannel(List<pse__Proj__c> projects) {
        List<Id> accountIds = new List<Id>();
        List<Id> billingAccountIds = new List<Id>();
        List<pse__Proj__c> projsToUpdate = new List<pse__Proj__c>();


        for (pse__Proj__c proj : projects) {
            if (!proj.Created_Automatically__c) {
                if (proj.Billing_Account__c != null) {
                    billingAccountIds.add(proj.Billing_Account__c);
                    projsToUpdate.add(proj);
                    continue;
                }
                if (proj.pse__account__c != null) {
                    accountIds.add(proj.pse__account__c);
                    projsToUpdate.add(proj);
                }
            }
        }
        if (accountIds.size() > 0 || billingAccountIds.size() > 0) {
            Map<Id, Account> accounts = new Map<Id, Account>([SELECT id,buid__c,CCN__c from Account where Id IN :accountIds OR Id IN :billingAccountIds]);
            for (pse__Proj__c project : projsToUpdate) {
                if (project.Billing_Account__c != null) {
                    project.buid__c = accounts.get(project.Billing_Account__c).buid__c;
                    project.Local_Channel__c = accounts.get(project.Billing_Account__c).CCN__c;
                    continue;
                }
                if (project.pse__account__c != null) {
                    project.buid__c = accounts.get(project.pse__account__c).buid__c;
                    project.Local_Channel__c = accounts.get(project.pse__account__c).CCN__c;
                }
            }
        }
    }
    
    
    /****** The below method is no longer required as this logic works different in DFN 
            as part of Story# 11019946 this method is commented by Sivakumari Ediga on 01/25/2022  */
    
   /* public static void setBuidAndLocalChannelWhenUpdateBillingAccount(Map<Id, pse__proj__c> oldTrigger, List<pse__proj__c> newTrigger) {
        try{
        List<Id> accountIds = new List<Id>();
        for (pse__proj__c project : newTrigger) {
            if (project.Billing_Account__c != oldTrigger.get(project.Id).Billing_Account__c) {
                accountIds.add(project.Billing_Account__c);
                System.debug('Account Id ' +accountIds);
            }
        }
        if (accountIds.size() > 0) {
            Map<Id, Account> accounts = new Map<Id, Account>([SELECT id, buid__c, CCN__c from account WHERE id IN :accountIds]);
            for (pse__proj__c project : newTrigger) {
                if (project.Billing_Account__c != oldTrigger.get(project.Id).Billing_Account__c) {
                    if (project.Billing_Account__c != null) {
                        project.buid__c = accounts.get(project.Billing_Account__c).buid__c;
                        system.debug('BUID' +project.buid__c);
                        project.local_channel__c = accounts.get(project.Billing_Account__c).CCN__c;
                        system.debug('Local Channel' +project.local_channel__c);
                    }
                }
            }
        }
    }catch(Exception e){
        System.debug('Error ####' +e.getMessage() + 'Line No ' +e.getLineNumber());
    }
    
    }*/
    public static void setBuidAndLocalChannelInProjectWhenOrderAssociated(OrderAssociationDataContext context) {
        System.debug('@@59 #####  Inside Method');
        Map<Id, pse__Proj__c> idProjMap = new Map<Id, pse__Proj__c>();
        for (Id projectId : context.projectWithAllOrderItems.keySet()) {
            if (context.projectMap.containskey(projectId)) {
                System.debug('Project Id ' +projectId);
                pse__Proj__c proj = context.projectMap.get(projectId);
                if (proj.Association_Flag__c == false && proj.pse__Project_Phase__c == 'Setup') {
                      System.debug('Flag ' +proj.Association_Flag__c);
                      System.debug('Phase ' +proj.pse__Project_Phase__c);
                    Order order = context.orderMap.get(context.projectWithAllOrderItems.get(proj.Id)[0].orderId);

                    proj.BUID__c = order.BUID__c;
                      System.debug('BUID ' +order.BUID__c);
                    proj.Local_Channel__c = order.Local_Channel__c;
                      System.debug('LC ' +order.Local_Channel__c);
                    proj.Association_Flag__c = true;
                    idProjMap.put(proj.Id, proj);
                }
            }
        }
        context.projectMap.putAll(idProjMap);
    }
}
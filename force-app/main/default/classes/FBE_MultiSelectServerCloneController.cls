public without sharing class FBE_MultiSelectServerCloneController {

    @AuraEnabled
    public static List<String> getAllAvailValues(String taskId){  
        List<Task> TaskRec = [select WhatId, FBE_Task_Products__c from Task where ID =: taskId];
        List<String> taskProducts = new List<String>();
        String Prd;
        for(Task t: TaskRec)
        {
           // taskProducts.add(t.FBE_Task_Products__c);
            Prd = t.FBE_Task_Products__c;
            if(Prd != null)
                taskProducts = Prd.split(';');
        }
       
        Set<String> setLIName = new Set<String>();
        List<OpportunityLineitem> OptyLineItem = [select Product2.Name from OpportunityLineItem where OpportunityId =: TaskRec[0].WhatId];
        List<String> ProdList = new List<String>(); 
        List<String> updatedProdList = new List<String>();
        for (OpportunityLineitem Op: OptyLineItem) 
        { 
            if(setLIName.add(Op.Product2.Name))
            {
                ProdList.add(Op.Product2.Name);
            } 
        }
        if(TaskRec[0].FBE_Task_Products__c == null)
        { 
            Prodlist = Prodlist;
        }
        else if(TaskRec[0].FBE_Task_Products__c != null)
        {
            Set<String> s1 = new Set<String>(Prodlist);
            Set<String> s2 = new Set<String>(taskProducts);
            s1.removeAll(s2);
            updatedProdList.addAll(s1);
            ProdList = updatedProdList;
        } 
        return ProdList;
    } 
 

    @AuraEnabled
    public static List<String> getAllSelectValues(String taskId){  
        List<Task> TaskRec = [select WhatId, FBE_Task_Products__c from Task where ID =: taskId];
        List<String> taskProducts = new List<String>();
        String Prd;
        for(Task t: TaskRec)
        {
            Prd = t.FBE_Task_Products__c;
            if(Prd != null)
                taskProducts = Prd.split(';');
        }
        return taskProducts;
    }     
 
    @AuraEnabled
    public static void updateTaskRec(String[] selectedVal, String taskId)
        {
            system.debug('xxxxxx'+ selectedVal);    
            Task TaskRec = [select Id,FBE_Task_Products__c, WhatId from Task where ID =: taskId];
            if(selectedVal.size() > 0)
            {
                String Products = selectedVal[0];
                for(Integer i = 1; i < selectedVal.size(); i++)
                {
                    Products = Products + ';'+ selectedVal[i];
                }
                 TaskRec.FBE_Task_Products__c = Products;
            }
            else
            {
                TaskRec.FBE_Task_Products__c = '';
            }
            update TaskRec;
        }
    }
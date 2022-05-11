/**
* @File Name          : DAL_ProjectTaskTest.cls
* @Description        : Test class for DAL_ProjectTask.
* @Author             : Leonardo Santos | 2/21/2020
**/

@isTest
public with sharing class DAL_ProjectTaskTest {
    
    @isTest
    static void shouldReturnProjectTasks(){
        
        // Create sku numbers and effort mappings
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<String> skuNumbersToMap1 = new List<String>{'111-1111'};
                List<String> skuNumbersToMap2 = new List<String>{'CUSTOM SKU'};
                    Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
            
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            test.startTest();
            orderItem.Quantity = 2;
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '444-4444';
            oi.Quantity = 1;
            oi.UnitPrice = 2;
            oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
            oi.Tie_Number__c = '1';
            oi.OrderId = order1.Id;
            oi.PriceBookEntryId = orderItem.PriceBookEntryId;
            oi.SKU_Cost__c = 2;
            oi.Unit_Selling_Price_USD__c = 85000;
            oi.SKU_Cost_USD__c = 85000;
            insert oi;
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            pse__Project_Task__c topTask = new pse__Project_Task__c();
            topTask.Name = 'Plan';
            topTask.pse__project__c = project1.Id;
            insert topTask;
            
            pse__Project_Task__c childTask = new pse__Project_Task__c();
            childTask.Name = 'Planning';
            childTask.pse__project__c = project1.Id;
            childTask.pse__Parent_Task__c = topTask.Id;
            childTask.pse__Estimated_Hours__c = 80;
            insert childTask;
             Test.stopTest();
            
            Map<Id, List<pse__Project_Task__c>> projectTasks = DAL_ProjectTask.getProjectTasks(new Set<Id>{project1.Id});
           
            
            System.assertEquals(2, projectTasks.get(project1.Id).size(), 'The project should have two tasks');
        }
    }
    
    @isTest
    static void shouldReturnoProjectTaskSkills(){
        
        // Create sku numbers and effort mappings
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<String> skuNumbersToMap1 = new List<String>{'111-1111'};
                List<String> skuNumbersToMap2 = new List<String>{'CUSTOM SKU'};
                    Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            phaseByTask.put('Planning', 'Plan');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
            
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];         
            Test.startTest();
            orderItem.Quantity = 2;
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '444-4444';
            oi.Quantity = 1;
            oi.UnitPrice = 2;
            oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
            oi.Tie_Number__c = '1';
            oi.OrderId = order1.Id;
            oi.PriceBookEntryId = orderItem.PriceBookEntryId;
            oi.SKU_Cost__c = 2;
            oi.Unit_Selling_Price_USD__c = 85000;
            oi.SKU_Cost_USD__c = 85000;
            insert oi;
            
            SKU_Number__c skuNumber = [
                SELECT SKU_to_Effort_Mapping__c
                FROM SKU_Number__c
                WHERE SKU_Number__c = '111-1111'
            ];
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            pse__Project_Task__c topTask = new pse__Project_Task__c();
            topTask.Name = 'Plan';
            topTask.pse__project__c = project1.Id;
            insert topTask;
            
            pse__Project_Task__c childTask = new pse__Project_Task__c();
            childTask.Name = 'Planning';
            childTask.pse__project__c = project1.Id;
            childTask.pse__Parent_Task__c = topTask.Id;
            childTask.pse__Estimated_Hours__c = 80;
            insert childTask;
            
            SKU_Effort_Map_Entry__c entry = [
                SELECT Id
                FROM SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map__c = :skuNumber.SKU_to_Effort_Mapping__c
                AND Name__c = 'Planning'
                LIMIT 1
            ];
            
            Skill_SKU_Effort_Map_Entry__c existingSkuSkill = [
                SELECT Id, Skill_Certification__c
                FROM Skill_SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map_Entry__c = :entry.Id
                LIMIT 1
            ];
            
            Project_Task_Skill__c projectTaskSkill = new Project_Task_Skill__c();
            projectTaskSkill.Project_Task__c = childTask.Id;
            projectTaskSkill.Skill_Certification__c = existingSkuSkill.Skill_Certification__c;
            projectTaskSkill.Minimum_Rate__c = '1';
            insert projectTaskSkill;
            Test.stopTest();
            Map<String, Project_Task_Skill__c> projectTaskSkills = DAL_ProjectTask.getProjectTaskSkill(new Set<Id>{project1.Id});
            
            
            System.assertEquals(1, projectTaskSkills.size(), 'Should exists project task skill for planning task');
        }
    }
    
    @IsTest
    static void testGetMapBySetId() 
    {
        // Create the data
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            pse__Proj__c project = OPRTestFactory.createProject();
            
            pse__Project_Task__c projectTask = new pse__Project_Task__c();
            projectTask.pse__Project__c = project.Id;
            projectTask.Name = 'Initiate';
            insert projectTask;
            
            Set<Id> setProjectTaskId = new Set<Id>();
            setProjectTaskId.add(projectTask.Id);
            
            // Action
            Test.startTest();
            Map<Id, pse__Project_Task__c> mapProjectTask = DAL_ProjectTask.getMapProjectTaskBySetId(setProjectTaskId);
            Test.stopTest();
            
            // Assertion
            System.assertEquals(1, mapProjectTask.size());
        }
    }
}
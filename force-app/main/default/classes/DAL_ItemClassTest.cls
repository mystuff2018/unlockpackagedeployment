/**
 * @File Name          : DAL_ItemClassTest.cls
 * @Description        : Test class of DAL_ItemClass
 * @Author             : Leonardo Santos | 10/3/2020
**/
@isTest
public class DAL_ItemClassTest {
    
    @isTest
    static void shouldGetItemClassByPractice(){
        
        pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
    
        pse__Practice__c practice1 = new pse__Practice__c(
        Name = 'Custom Practice Test',
        Order_Association_Approval_Phase__c = 'Execute',
        Standard_Project_Template__c = projectTemplate.Id
        );
        insert practice1;

        pse__Practice__c practice2 = new pse__Practice__c(
        Name = 'Custom Practice Test',
        Order_Association_Approval_Phase__c = 'Execute',
            Standard_Project_Template__c = projectTemplate.Id
        );
        insert practice2;

        Item_Class__c itemClass1 = new Item_Class__c(
            Item_Class_Description__c = 'SVC EDT INSTLN',
            Practice__c = practice1.Id,
            Key_Practice__c = true
        );
        insert itemClass1;

        Item_Class__c itemClass2 = new Item_Class__c(
            Item_Class_Description__c = 'SVC INSTLN TEST 2',
            Practice__c = practice1.Id,
            Key_Practice__c = true
        );
        insert itemClass2;
        
        Item_Class__c itemClass3 = new Item_Class__c(
            Item_Class_Description__c = 'SVC CUSTOM',
            Practice__c = practice2.Id,
            Key_Practice__c = false
        );
        insert itemClass3;

        Set<Id> practiceList = new Set<Id>{practice1.Id, practice2.Id};

    
        Test.startTest();
        Map<Id,List<Item_Class__c>> result = DAL_ItemClass.getItemClassByPractice(practiceList);
        Test.stopTest();
    
        System.assertEquals(true, result.containsKey(practice1.Id), 'DAL return should contains a key practice.');
        System.assertEquals(false, result.containsKey(practice2.Id), 'DAL return should not contains not key practice.');
    
    }
    
    @isTest
    static void shouldGetPracticeByDescription(){
    	pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
        
        pse__Practice__c practice1 = new pse__Practice__c(
        Name = 'Custom Practice Test',
        Order_Association_Approval_Phase__c = 'Execute',
         Standard_Project_Template__c = projectTemplate.Id   
        );
        insert practice1;

        pse__Practice__c practice2 = new pse__Practice__c(
        Name = 'Custom Practice Test',
        Order_Association_Approval_Phase__c = 'Execute',
            Standard_Project_Template__c = projectTemplate.Id
        );
        insert practice2;

        Item_Class__c itemClass1 = new Item_Class__c(
            Item_Class_Description__c = 'SVC EDT INSTLN',
            Practice__c = practice1.Id,
            Key_Practice__c = true
        );
        insert itemClass1;

        Item_Class__c itemClass2 = new Item_Class__c(
            Item_Class_Description__c = 'SVC INSTLN TEST 2',
            Practice__c = practice1.Id,
            Key_Practice__c = true
        );
        insert itemClass2;
        
        Item_Class__c itemClass3 = new Item_Class__c(
            Item_Class_Description__c = 'SVC CUSTOM',
            Practice__c = practice2.Id,
            Key_Practice__c = false
        );
        insert itemClass3;

        Set<String> descriptionList = new Set<String>{itemClass1.Item_Class_Description__c, itemClass2.Item_Class_Description__c, itemClass3.Item_Class_Description__c};
    
        Test.startTest();
        Map<String, pse__Practice__c> result = DAL_ItemClass.getPracticeByDescription(descriptionList);
        Test.stopTest();
    
        System.assertEquals(itemClass1.Practice__c, result.get(itemClass1.Item_Class_Description__c).Id, 'DAL return should contains the description.');
        System.assertEquals(itemClass2.Practice__c, result.get(itemClass2.Item_Class_Description__c).Id, 'DAL return should contains the description.');
        System.assertEquals(false, result.containsKey(itemClass3.Item_Class_Description__c), 'DAL return should not contains the description from item class with key practice false.');
    
    }

    @isTest
    static void shouldGetItemClassDescription()
    {
        pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
        
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Custom Practice Test';
        practice.Order_Association_Approval_Phase__c = 'Execute';
        practice.Standard_Project_Template__c = projectTemplate.Id;
        insert practice;

        Item_Class__c itemClass = new Item_Class__c();
        itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
        itemClass.Practice__c = practice.Id;
        itemClass.Key_Practice__c = true;
        insert itemClass;

        Test.startTest();
        List<String> listItemClassDescription = DAL_ItemClass.getListItemClassDescription();
        Test.stopTest();

        System.assertEquals(1, listItemClassDescription.size());
    }
}
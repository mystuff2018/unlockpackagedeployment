@isTest
public class OrderDisassociationResourceSkillReqTest {
    
    @testSetup
	static void setup(){
		SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
				Active__c = true,
				Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
				X30_Day_Support__c = true
		);
		insert skuEffortMap;

		SKU_Number__c skuNumber1 = new SKU_Number__c();
		skuNumber1.SKU_Number__c = '777-1000';
		skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
		insert skuNumber1;

		pse__Proj__c globalProject = new pse__Proj__c();
		Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
		globalProject.Name = 'Global project';
		globalProject.RecordTypeId = recordTypeId;
		globalProject.pse__Is_Template__c = true;
		insert globalProject;

		pse__Project_Task__c phase = new pse__Project_Task__c(Name = 'Test', pse__Project__c = globalProject.Id);

		insert phase;
		
		SKU_Effort_Map_Entry__c entry = new SKU_Effort_Map_Entry__c();
		entry.SKU_Effort_Map__c = skuEffortMap.Id;
		entry.project__c = globalProject.Id;
		entry.Phase__c = phase.Id;
		entry.Estimated_Hours__c = 16;
		insert entry;

		pse__Skill__c skill = new pse__Skill__c();
		skill.Name = 'Project Management';
		skill.pse__External_Id__c = '123';
		insert skill;

		Skill_SKU_Effort_Map_Entry__c skillSku = new Skill_SKU_Effort_Map_Entry__c();
		skillSku.SKU_Effort_Map_Entry__c = entry.Id;
		skillSku.Skill_Certification__c = skill.Id;
		insert skillSku;
        
		pse__Proj__c project = OPRTestFactory.createSimpleProject();
		Order order1 = OPRTestFactory.createSimpleOrder();
		Order order2 = OPRTestFactory.createSimpleOrder();
    }
    
    @isTest
    static void shouldRecalculateResourceSkillRequest(){

		List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
		List<Order_Association__e> eventList = new List<Order_Association__e>();
        
        for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project.Id,
				Order_Item_Id__c = item.Id
			);

			eventList.add(event);
        }
        
        
		OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
		context.save();

        Test.startTest();
        OrderDisassociationDataContext disassociationContext = new OrderDisassociationDataContext((new Map<Id, Order>(orders)).keySet());
        OrderDisassociationResourceSkillRequest.updateResourceSkillRequest(disassociationContext);
		Test.stopTest();

    }

}
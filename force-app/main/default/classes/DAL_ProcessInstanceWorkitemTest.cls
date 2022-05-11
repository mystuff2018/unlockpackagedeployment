@isTest
public class DAL_ProcessInstanceWorkitemTest {
    
    @IsTest static void approvalProcessByOrderItemToProjectApproval() {
    
        // ARRANGE
        OrderItemToProjectApproval__c orita = MDF_OrderItemToProjectApprovalFactory.start()
												.approver(UserInfo.getUserId())
                                                .create();
                                                
        createApprovalProcess(orita);
    
        // ACT
        Test.startTest();

        Map<Id, Id> oritaToApprovalProcess = DAL_ProcessInstanceWorkitem.approvalProcessByOrderItemToProjectApproval(new Set<Id> {orita.Id});
    
        Test.stopTest();
    
        // ASSERT
        System.assert(oritaToApprovalProcess.size() > 0);
        System.assert(oritaToApprovalProcess.containsKey(orita.Id));
    }

    private static void createApprovalProcess(OrderItemToProjectApproval__c orita) {
		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
 
		Approval.ProcessSubmitRequest orderItemToApprovalProcess = new Approval.ProcessSubmitRequest();
		orderItemToApprovalProcess.setComments('Test Approval Process Created');
		orderItemToApprovalProcess.setNextApproverIds(new Id[] {UserInfo.getUserId()});
		orderItemToApprovalProcess.setObjectId(orita.Id);
		// Submit the record to specific process
		orderItemToApprovalProcess.setProcessDefinitionNameOrId('Order_Item_Association_Approval_Process');
		requests.add(orderItemToApprovalProcess);

        Approval.ProcessResult[] processResults = Approval.process(requests, true);
	}
}
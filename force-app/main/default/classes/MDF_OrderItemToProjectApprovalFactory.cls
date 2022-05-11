@isTest
public class MDF_OrderItemToProjectApprovalFactory {
    private OrderItemToProjectApproval__c current;

    public MDF_OrderItemToProjectApprovalFactory(OrderItemToProjectApproval__c current) {
        this.current = current;
    }

    // Entry point builder method to start composing object attributes
    public static MDF_OrderItemToProjectApprovalFactory start() {
        return new MDF_OrderItemToProjectApprovalFactory(
            new OrderItemToProjectApproval__c(Approval_Status__c='Pending')
        );
    }

    // Composable Functions
    public MDF_OrderItemToProjectApprovalFactory approver(Id userId) {
        current.Approver__c = userId;
        return this;
    }

    public OrderItemToProjectApproval__c create() {
        insert current;
        return current;
    }
}
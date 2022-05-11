@isTest
public class MDF_OrderItemFactory {
    private OrderItem current;

    public MDF_OrderItemFactory(OrderItem current) {
        this.current = current;
    }

    // Entry point builder method to start composing object attributes
    public static MDF_OrderItemFactory start(Order order) {

        Product2 product = new Product2(Name='Product Test');
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;

        return new MDF_OrderItemFactory(
            new OrderItem(
                PriceBookEntryId = pricebookEntry.Id,
                OrderId = order.Id,
                Quantity = 1,
                UnitPrice = 1)
        );
    }

    // Composable Functions
    public MDF_OrderItemFactory orderItemToProjectApproval(OrderItemToProjectApproval__c orderItemToProjectApproval) {
        current.OrderItemToProjectApproval__c = orderItemToProjectApproval.Id;
        return this;
    }
    

    public OrderItem create() {
        insert current;
        return current;
    }
}
@isTest
public class MDF_OrderFactory {
  private Order current;

  public MDF_OrderFactory(Order current) {
    this.current = current;
  }

  // Entry point builder method to start composing object attributes
  public static MDF_OrderFactory start(Account account) {
    return new MDF_OrderFactory(
        new Order(
            AccountId = account.id,
            Pricebook2Id = Test.getStandardPricebookId(),
            EffectiveDate = Date.today(),
            Status = 'BK',
            BUID__C = '11',
            OrderNumber__c = String.valueof((Math.random() * 1000000000))
        )
    );
  }

  // Composable Functions
  public MDF_OrderFactory overrideBUID(String buid) {
    current.BUID__c = buid;
    return this;
  }

  public Order create() {
    insert current;
    return current;
  }

  public MDF_OrderFactory poNumber(String value) {
    current.PoNumber = value;
    return this;
  }

  public MDF_OrderFactory dealID(String value) {
    current.Deal_ID__c = value;
    return this;
  }

  public MDF_OrderFactory relatedProject(pse__Proj__c project) {
    current.Project__c = project.Id;
    return this;
  }

  public MDF_OrderFactory FFFeed(Boolean value) {
    current.FF_Feed__c = value;
    return this;
  }
  
  public MDF_OrderFactory practice(String value) {
    current.Practice__c = value;
    return this;
  }
}
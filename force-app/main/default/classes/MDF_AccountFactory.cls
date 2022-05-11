@isTest
public class MDF_AccountFactory {
  private Account current;

  public MDF_AccountFactory(Account current) {
    this.current = current;
  }

  // Entry point builder method to start composing object attributes
  public static MDF_AccountFactory start() {
    return new MDF_AccountFactory(
        new Account(Name = 'Dell EMC')
    );
  }

  // Composable Functions
  public MDF_AccountFactory siteAccessRequired(String value) {
    current.Site_Access_Required__c = value;

    return this;
  }

  public Account create() {
    insert current;
    return current;
  }
}
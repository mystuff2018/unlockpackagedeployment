///**
// * Created by Bruno_Frosi on 1/20/2020.
// */
//
public with sharing class DAL_Account {
    public static Map<Id, Account> getAccountsByIds(Set<Id> accountIds)
    {
        if(accountIds == null)
            return null;

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name, AccountNumber FROM Account WHERE Id = :accountIds]);
        if(accounts.size() > 0)
            return accounts;
        return null;
    }
}
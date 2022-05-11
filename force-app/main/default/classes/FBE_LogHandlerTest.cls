/**************
 *@ Class Name        : FBE_LogHandlerTest
 *@ Description       : STORY 8358218 - FBE_LogHandler for FBE_LogHandlerTest code coverage
 *@ CreatedBy         : DellTeam
 *@ CreatedOn         : 05-12-2020
 *@ Modification Log  : [Sireesha Myla] 
 ***************/
@isTest
public class FBE_LogHandlerTest
{
    public static RecordType rt = [select Id,Name from RecordType where SObjectType in ('FBE_Configurator__c') AND Name in ('Error logs')];
   
    static testMethod void logTest()
    {
           List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);
           List<Deal_Registration__c> dealList = FBE_UtilityFactory_Test.createDeal(1);
           INSERT dealList;
           List<FBE_Deal_Registration_Team__c> dealTMList = new List<FBE_Deal_Registration_Team__c>();
           FBE_Deal_Registration_Team__c dealTeam = new FBE_Deal_Registration_Team__c();
           dealTeam.Deal_Registration__c = dealList[0].Id;
           dealTeam.User__c = lUserTeam[1].Id;
           dealTeam.Role__c = 'SE';
           dealTeam.Access_level__c = 'Read/Write';
           dealTeam.FBE_Auto_Created__c = 'Y';
           dealTMList.add(dealTeam);
           
           FBE_Deal_Registration_Team__c dealTeam1 = new FBE_Deal_Registration_Team__c();
           dealTeam1.Deal_Registration__c = dealList[0].Id;
           dealTeam1.User__c = lUserTeam[1].Id;
           dealTeam1.Role__c = 'SE';
           dealTeam1.Access_level__c = 'Read/Write';
           dealTeam1.FBE_Auto_Created__c = 'N';
           dealTMList.add(dealTeam1);
        
            INSERT dealTMList;

         
          Test.startTest();
           try
           {
               
                Database.SaveResult[] srList = Database.insert(dealTMList, false);
                FBE_LogHandler.databaseSaveLogInformation(srList[0], dealTMList[0].Name);
                Database.DeleteResult[] drList = Database.delete(dealTMList, false);
            	FBE_LogHandler.databaseDeleteLogInformation(drList[0], dealTMList[0].Name);
           }Catch(Exception e)
           {
               FBE_LogHandler.LogException(e, dealTMList[0].Name);
           }
          
          Test.stopTest();
    }

}
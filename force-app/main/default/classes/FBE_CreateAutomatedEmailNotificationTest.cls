@isTest(seeAllData = false)
    public class FBE_CreateAutomatedEmailNotificationTest {
        static TestMethod void createAutomatedEmailNotificationTest(){
           //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
           User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
            List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 3, 'ab',null);
            
            system.runAs(lUser){
                Test.startTest();
                List<Account> acc = FBE_UtilityFactory_Test.createAccount(1,null);
                insert acc;
                List<opportunity> opp = FBE_UtilityFactory_Test.createOpportunity(1,acc[0].id,null,null,null,null,null);

                opp[0].ownerid = lUserTeam[0].id;
                
                insert opp;
                system.assertNotEquals(null, opp[0].ownerid, 'No Opportunity records found');
                try{
                    FBE_CreateAutomatedEmailNotification fbe = new FBE_CreateAutomatedEmailNotification ();
                    Database.executeBatch(fbe,1);
                    FBE_CreateAutomatedEmailNotificationSch reminder = new FBE_CreateAutomatedEmailNotificationSch();
                    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
                    String sch = '20 30 8 10 2 ?';
                    String jobID = System.schedule('Remind Opp', sch, reminder);
                }
                catch(Exception e){
                    system.debug(e.getMessage());
                }  
                Test.stopTest();
            }
        }

    }
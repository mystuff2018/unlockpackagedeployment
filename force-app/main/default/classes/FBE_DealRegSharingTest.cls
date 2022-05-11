@isTest
private class FBE_DealRegSharingTest {
    // Test for the manualShareRead method
    static testMethod void testManualShareRead(){
        // Select users for the test.
        /*List<User> users = [SELECT Id FROM User WHERE IsActive = true and Id <> '005t0000000met5' LIMIT 3];
        Id User1Id = users[0].Id;
        Id User2Id = users[1].Id;
        Id User3Id = users[2].Id; */
        
        List<User> users = FBE_UtilityFactory_Test.createUser('System Administrator', 3, 'abc',null);
        Id User1Id = users[0].Id;
        Id User2Id = users[1].Id;
        Id User3Id = users[2].Id; 
        // Create new Deal.
        /*Deal_Registration__c d = new Deal_Registration__c();
        d.Name = 'Test Deal';
        d.OwnerId = user1Id;
        d.FBE_Deal_Product_Classification__c = 'Dell Products';
        d.FBE_Customer__c = '65000909';
        d.FBE_Deal_Reg_Partner_Direct__c = '65000909';
        insert d;    */
        
        List<Deal_Registration__c> d = FBE_UtilityFactory_Test.createDeal(1);
        insert d;
        
        // Create new Deal_Team.
        FBE_Deal_Registration_Team__c dt = new FBE_Deal_Registration_Team__c();  
        dt.Deal_Registration__c =  d[0].Id;
        dt.User__c =  user2Id;
        dt.Access_level__c = 'Read'; 
        insert dt; 
        // Create new Deal_Team.
        FBE_Deal_Registration_Team__c dt2 = new FBE_Deal_Registration_Team__c();  
        dt2.Deal_Registration__c =  d[0].Id;
        dt2.User__c =  user3Id;
        dt2.Access_level__c = 'Read/Write'; 
        insert dt2;    
        
        List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
        List<FBE_Deal_Registration_Team__c> dealTeamList2 = new List<FBE_Deal_Registration_Team__c>(); 
        dealTeamList.add(dt);     
        dealTeamList2.add(dt2); 
        
        // Insert manual share for user who is not record owner.
        // System.assertEquals(FBE_DealRegSharing.manualShareRead(idList), true);
        // Updated logic to pass Deal Team list
        //FBE_DealRegSharing.manualShareRead(dealTeamList);
        //FBE_DealRegSharing.manualShareRead(dealTeamList2);
        FBE_DealHelper dealHelper = new FBE_DealHelper();
        dealHelper.createDealTeamMemberShare(dealTeamList2);
        
        // Query deal sharing records.
        List<Deal_Registration__Share> dShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                RowCause FROM Deal_Registration__Share WHERE ParentId = :d[0].Id AND UserOrGroupId= :user2Id];
        
        // Test for only one manual share on deal.
        System.assertEquals(dShrs.size(), 1, 'Expected count of records should be 1');
        
        // Query deal sharing records.
        List<Deal_Registration__Share> dShrs1 = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                 RowCause FROM Deal_Registration__Share WHERE ParentId = :d[0].Id AND UserOrGroupId= :user3Id];
        
        // Test for only one manual share on deal.
        System.assertEquals(dShrs1.size(), 1, 'Expected count of records should be 1');       
        
        // Test attributes of manual share.
        System.assertEquals(dShrs[0].AccessLevel, 'Read','Accesslevel read');
        System.assertEquals(dShrs[0].RowCause,'Deal_Team_Sharing__c','Rowcause not manual');
        System.assertEquals(dShrs[0].UserOrGroupId, user2Id, 'UserGroup');
        
        // Test attributes of manual share.
        System.assertEquals(dShrs1[0].AccessLevel, 'Edit','Accesslevel read');
        System.assertEquals(dShrs1[0].RowCause, 'Deal_Team_Sharing__c','Rowcause not manual');
        System.assertEquals(dShrs1[0].UserOrGroupId, user3Id,'Usergroup');       
        
        //testing FBE_DealRegRemove class
        delete dt;
        
        // Test invalid deal Id.
        delete d;   
        
        // Insert manual share for deleted deal id. 
        // System.assertEquals(FBE_DealRegSharing.manualShareRead(d.Id, user2Id), false);
        //FBE_DealRegSharing.manualShareRead(dealTeamList);
    }  
}
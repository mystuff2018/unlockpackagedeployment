/**
 * Created by Filipe Hoffmeister on 5/15/2020.
 */

@IsTest
public class RollupEngagementStageTest {
    @testSetup
     static void setup(){
         pse__Proj__c engagement = OPRTestFactory.createSimpleProject();
         pse__Proj__c projectFirst = OPRTestFactory.createSimpleProject();
         pse__Proj__c projectSecond = OPRTestFactory.createSimpleProject();

         List<pse__Proj__c> projects = new List<pse__Proj__c>();
         Id installationBadgeRecordType = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Parent Project').getRecordTypeId();
         engagement.RecordTypeId = installationBadgeRecordType;
         projectFirst.pse__Parent_Project__c = engagement.Id;
         projectSecond.pse__Parent_Project__c = engagement.Id;
         projects.add(engagement);
         projects.add(projectFirst);
         projects.add(projectSecond);
         update projects;
     }

     @isTest              
      static void rollupEngagementToInProgress() {
          Test.startTest();
          pse__Proj__c projectFirst = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null limit 1];
          projectFirst.pse__Stage__c = 'In Progress';
          update projectFirst;
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projectFirst.pse__Parent_Project__c];
          Test.stopTest();
        
        // System.assertEquals('In Progress', engagement.pse__Stage__c, 'Engagement should be In Progress');
     }

      @isTest              
      static void dontRollupEngagementToOnHold() {
          Test.startTest();
          pse__Proj__c projectFirst = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null limit 1];
          projectFirst.pse__Stage__c = 'On Hold';
          projectFirst.On_Hold_Reason__c = 'Other Issues';
          update projectFirst;
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projectFirst.pse__Parent_Project__c];
          Test.stopTest();
        
          //System.assertEquals('Draft', engagement.pse__Stage__c, 'Engagement should be Draft');
      }

      @isTest              
      static void rollupEngagementToOnHold() {
          Test.startTest();
          List<pse__Proj__c> projects = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null];
          for (pse__Proj__c proj : projects) {
              proj.pse__Stage__c = 'On Hold';
              proj.On_Hold_Reason__c = 'Other Issues';
          }
          update projects;
          system.debug(projects + ' :projects:');
        
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projects[0].pse__Parent_Project__c];
          Test.stopTest();
        
          system.debug(engagement + ' :engagement:');
        
          //System.assertEquals('On Hold', engagement.pse__Stage__c, 'Engagement should be On Hold');
      }

      @isTest              
      static void dontRollupEngagementToCancelled() {
          Test.startTest();
          pse__Proj__c projectFirst = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null limit 1];
          projectFirst.pse__Stage__c = 'Cancelled';
          projectFirst.pse__Is_Active__c=false;
          update projectFirst;
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projectFirst.pse__Parent_Project__c];
          Test.stopTest();
        
          //System.assertEquals('Draft', engagement.pse__Stage__c, 'Engagement should be Draft');
      }

      @isTest              
      static void rollupEngagementToCancelled() {
          Test.startTest();
          List<pse__Proj__c> projects = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null];
          for (pse__Proj__c proj : projects) {
              proj.pse__Stage__c = 'Cancelled';
              proj.pse__Is_Active__c=false;
          }
          update projects;
          system.debug(projects + ' :projects:');
        
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projects[0].pse__Parent_Project__c];
          Test.stopTest();
        
          system.debug(engagement + ' :engagement:');
        
          //System.assertEquals('Cancelled', engagement.pse__Stage__c, 'Engagement should be Cancelled');
      }

     /* @isTest              
      static void dontRollupEngagementToClosure() {
          Test.startTest();
          pse__Proj__c projectFirst = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null limit 1];
          projectFirst.pse__Stage__c = 'Closure';
          projectFirst.pse__Project_Phase__c = 'Close';
          projectFirst.Delivery_and_Implementation__c =  true;
          projectFirst.Closure_Reason__c = 'Services Delivered';
          projectFirst.Initiate_Customer_Contact__c = true;
          projectFirst.pse__Is_Active__c=false;
          projectFirst.Local_Channel__c = '1212';
          projectFirst.BUID__c = '1212';
          insert projectFirst;
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projectFirst.pse__Parent_Project__c];
          Test.stopTest();
        
          System.assertEquals('Draft', engagement.pse__Stage__c, 'Engagement should be Draft');
      }

      @isTest              
      static void rollupEngagementToClosure() {
          Test.startTest();
          List<pse__Proj__c> projects = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null];
          for (pse__Proj__c proj : projects) {
              proj.pse__Stage__c = 'Closure';
              proj.pse__Project_Phase__c = 'Close';
              proj.Delivery_and_Implementation__c =  true;
              proj.Closure_Reason__c = 'Services Delivered';
              proj.Initiate_Customer_Contact__c = true;
              proj.pse__Is_Active__c=false;
              proj.Local_Channel__c = '1212';
              proj.BUID__c = '1212';

          }
          update projects;
          system.debug(projects + ' :projects:');
        
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projects[0].pse__Parent_Project__c];
          Test.stopTest();
        
          system.debug(engagement + ' :engagement:');
        
          System.assertEquals('Closure', engagement.pse__Stage__c, 'Engagement should be Closure');
      }

      @isTest              
      static void rollupEngagementToClosureWithOneCancelled() {
          Test.startTest();
          List<pse__Proj__c> projects = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null];
      
          projects[0].pse__Stage__c = 'Cancelled';
          projects[0].pse__Is_Active__c=false;
          projects[0].Local_Channel__c = '1212';
          projects[0].BUID__c = '1212';

          update projects[0];

          projects[1].pse__Stage__c = 'Closure';
          projects[1].pse__Project_Phase__c = 'Close';
          projects[1].Delivery_and_Implementation__c =  true;
          projects[1].Closure_Reason__c = 'Services Delivered';
          projects[1].Initiate_Customer_Contact__c = true;
          projects[1].pse__Is_Active__c=false;
          projects[1].Local_Channel__c = '1212';
          projects[1].BUID__c = '1212';


          update projects[1];
          system.debug(projects + ' :projects:');
        
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projects[0].pse__Parent_Project__c];
          Test.stopTest();
        
          system.debug(engagement + ' :engagement:');
        
          System.assertEquals('Closure', engagement.pse__Stage__c, 'Engagement should be Closure');
      }
    
      @isTest              
      static void rollupEngagementToClosureWithOneClosureAndWithOneCancelled() {
          Test.startTest();
          List<pse__Proj__c> projects = [Select Id, pse__Parent_Project__c, pse__Stage__c from pse__Proj__c where pse__Parent_Project__c != null];
        
          projects[0].pse__Stage__c = 'Closure';
          projects[0].pse__Project_Phase__c = 'Close';
          projects[0].Delivery_and_Implementation__c =  true;
          projects[0].Closure_Reason__c = 'Services Delivered';
          projects[0].Initiate_Customer_Contact__c = true;
          projects[0].pse__Is_Active__c=false;
          projects[0].Local_Channel__c = '1212';
          projects[0].BUID__c = '1212';

        
          update projects[0];
        
          projects[1].pse__Stage__c = 'Cancelled';
          projects[1].pse__Is_Active__c=false;
          projects[1].Local_Channel__c = '1212';
          projects[1].BUID__c = '1212';
	      update projects[1];
        
         system.debug(projects + ' :projects:');
        
          pse__Proj__c engagement = [Select Id, pse__Stage__c from pse__Proj__c where Id = :projects[0].pse__Parent_Project__c];
          Test.stopTest();
        
          system.debug(engagement + ' :engagement:');
        
          System.assertEquals('Closure', engagement.pse__Stage__c, 'Engagement should be Closure');
      }*/
}
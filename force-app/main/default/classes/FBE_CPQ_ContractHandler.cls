/******************************
* Created by               : Sireesha Myla[ DellTeam CPQ] - 07 March 2022
* Description              : STORY 12079756 , STORY 12079767 - This Apex class used in LWC - 
*                          : Class and functionality applicable only for FPRM users
*                          : Test Class Name - FBE_CPQ_OptyRelatedListController_Test   - 82%
* Modification  Log        : Developer                 Date                  Story/Defect          
* 1.0 					   : Sireesha Myla           18-Mar-2022           STORY 12079756, 12079767 
*******************************/

public with sharing class FBE_CPQ_ContractHandler
 {

    Public static final string FBE_FPRM_Reseller_Profile = System.Label.FBE_FPRM_ResellerProfile;
    Public static final string FBE_FPRM_Distributor_Profile = System.Label.FBE_FPRM_DistributorProfile; 
    Public static final string FBE_FPRM_DMP_Profile = System.Label.FBE_FPRM_DMPProfile;
    
    
    /* Methoed returns the List of active Contracts to the Partners based on Partner profiles (Distributor, Reseller, DMP)
     This Method invokes upon click of 'Apply Contract' button on Opportunity */
    @AuraEnabled(cacheable=true)
        public static List<Contract> getContracts(Id optyId)
        {
            Boolean distributorFlag = false;
            Boolean directResellerFlag = false;
            Boolean distributionResellerFlag = false;
            Boolean dmpFLag = false;

            String distributorId ;
            String ResellerId ;
            String activeStatus = 'Active';
            String distributor = 'Distributor';

            List<Contract>contractList = new List<Contract>();
            List<Opportunity> optyList = new List<Opportunity>();

            String profileName = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId()]?.Name;// Get Logged in user Profile Name

            if(profileName.equalsIgnoreCase(FBE_FPRM_Distributor_Profile) || profileName.equalsIgnoreCase(FBE_FPRM_Reseller_Profile) || profileName.equalsIgnoreCase(FBE_FPRM_DMP_Profile) )
            {
           
                optyList = [SELECT Id, FBE_FPRM_Fulfilment_Path__c,AccountId, FBE_VAR_Seller__c, FBE_Distributor__c FROM Opportunity
                                                WHERE Id =: String.escapeSingleQuotes(optyId) LIMIT 1];
                
                //Verify Logged in user is Partner Distributor and Distributor account on opportnity
                distributorFlag =  (profileName.equalsIgnoreCase(FBE_FPRM_Distributor_Profile) && !optyList.isEmpty() && optyList[0]?.FBE_Distributor__c!=null ) ? true : false; 

                //Verify Logged in user is DMP and Distributor account on opportnity
                dmpFLag = (profileName.equalsIgnoreCase(FBE_FPRM_DMP_Profile) && !optyList.isEmpty() && optyList[0]?.FBE_Distributor__c!=null ) ? true : false;

                //Verify Logged in user is Partner Reseller with Fulfillment Path as Direct and Reseller account on opportnity
                directResellerFlag = (profileName.equalsIgnoreCase(FBE_FPRM_Reseller_Profile) && !optyList.isEmpty() && optyList[0]?.FBE_VAR_Seller__c!=null && optyList[0]?.FBE_FPRM_Fulfilment_Path__c =='Direct Fulfillment' ) ? true : false;    
                resellerId = optyList[0]?.FBE_VAR_Seller__c;
                resellerId = String.isNotBlank(resellerId) ? ' \'' + String.escapeSingleQuotes(resellerId) + '\'' : resellerId;

                //Verify Logged in user is Partner Reseller with Fulfillment Path as Distribution and Distributor account on opportnity
                distributionResellerFlag = (profileName.equalsIgnoreCase(FBE_FPRM_Reseller_Profile) && !optyList.isEmpty() && optyList[0]?.FBE_Distributor__c!=null && optyList[0]?.FBE_FPRM_Fulfilment_Path__c =='Distribution' ) ? true : false;
                distributorId = optyList[0]?.FBE_Distributor__c;
                distributorId = String.isNotBlank(distributorId) ? ' \'' + String.escapeSingleQuotes(distributorId) + '\'' : distributorId;
            }
            String query = 'SELECT Id, Name from Contract WHERE Status =\''+String.escapeSingleQuotes(activeStatus)+'\'';
            String distributorAccountQuery = ' AND AccountId ='+distributorId;

            // Run the SOQL if Partner Distributor profile
            if(distributorFlag && !directResellerFlag && !distributionResellerFlag)
            {
                System.debug('Dist:'+distributorFlag);
                query+= distributorAccountQuery;
            }
            else if(directResellerFlag && !distributionResellerFlag)// Query if Partner Reseller (Fulfillment Path : Direct) profile
            {
                System.debug('Reseller Direct:'+directResellerFlag);
                query+= ' AND AccountId ='+resellerId;
            }
            else if((distributionResellerFlag && !dmpFLag || dmpFLag && !distributionResellerFlag) && !distributorFlag) //Query if Partner Reseller (Fulfillment Path : Distribution) or DMP profile
            {
                System.debug(distributionResellerFlag+'Reseller & DMP:'+dmpFLag);
                query+= distributorAccountQuery;
                query+= ' AND FBE_CPQ_Contract_Type__c =\''+String.escapeSingleQuotes(distributor)+'\'';
                query+= ' AND Name LIKE \'%' + String.escapeSingleQuotes(distributor) + '%\' ';  
            }
            query+= ' Order By FBE_CPQ_Contract_Type__c,Name';
            if(distributorFlag || directResellerFlag || distributionResellerFlag || dmpFLag){
                contractList = database.query(query);
            }
            		
			System.debug(' LIST::'+contractList);
            return contractList;
           
        }
        @AuraEnabled
        public static Id saveOpportunity(Id optyId, Id conId)
        {
            String msg = '';
            Opportunity opp = new Opportunity(Id = optyId);
            try{
                opp.ContractId =  conId;
                update opp;
                
            }
            catch(DmlException e)
           {
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                //we can get from DmlException
                
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++)
                {
                    //Get Validation Rule & Lookup filter error messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                
                
                throw new AuraHandledException(msg);
          }
          return opp.id;
        }

}
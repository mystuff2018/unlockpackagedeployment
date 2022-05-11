/**************
 *@ Class Name        : FBE_OptyFiscalParameters
 *@ Description       : This class is written to set Fiscal parameters such as Fiscal Year, Fiscal Quarter, Fiscal Week, Fiscal Period on Opportunity when opportunity is created
                        or Book Date is updated. Method queries Period object using Opportunity Book Date to retrieve Year, Quarter, Week and Period fiscal values. These are 
                        updated on Opportunity record.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 01-22-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to set Opty Fiscal Parameters
 ***************/
public without sharing class FBE_OptyFiscalParameters {
    @InvocableMethod
    public static void setFiscalParameters(List<Opportunity> oppList){
        try{
            //System.debug('Executed');
            Id oppId;
            Date oppBookDate;
            //List<Period> fiscalPeriod = new List<Period>();
            List<Opportunity> oppListUpdate = new List<Opportunity>();
            String fiscalYear, fiscalQuarter, fiscalWeek, fiscalPeriod;
            Integer stringLength;
            
            for(Opportunity opp : oppList){
                oppId = opp.Id;
                oppBookDate = opp.CloseDate;
            }
            
            for(Period per : [SELECT Type, FullyQualifiedLabel FROM Period Where startDate <=: oppBookDate AND EndDate >=: oppBookDate]){
                if(per.Type == 'Year'){
                    fiscalYear = per.FullyQualifiedLabel.substring(3);
                    //System.debug('fiscalYear: '+fiscalYear);
                }
                if(per.Type == 'Quarter'){
                    stringLength = per.FullyQualifiedLabel.length();
                    fiscalQuarter = per.FullyQualifiedLabel.substring(0,stringLength-10);
                    stringLength = null;
                    //System.debug('fiscalQuarter: '+fiscalQuarter);
                }
                if(per.Type == 'Week'){
                    stringLength = per.FullyQualifiedLabel.length();
                    fiscalWeek = per.FullyQualifiedLabel.substring(0,stringLength-10);
                    stringLength = null;
                    //System.debug('fiscalWeek: '+fiscalWeek);
                }
                if(per.Type == 'Month'){
                    stringLength = per.FullyQualifiedLabel.length();
                    fiscalPeriod = per.FullyQualifiedLabel.substring(0,stringLength-10);
                    stringLength = null;
                    //System.debug('fiscalPeriod: '+fiscalPeriod);
                }
            }
            
            Opportunity opp = new Opportunity(Id = oppId,
                                             FBE_Fiscal_Year__c = fiscalYear,
                                             FBE_Fiscal_Quarter__c = fiscalQuarter,
                                             FBE_Fiscal_Week__c = fiscalWeek,
                                             FBE_Fiscal_Period__c = fiscalPeriod);
            oppListUpdate.add(opp);
            update(oppListUpdate);
            //System.debug('Opp to be updated ' + oppListUpdate); 
        }
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }
}
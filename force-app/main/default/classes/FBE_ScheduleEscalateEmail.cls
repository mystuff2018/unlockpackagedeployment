/**************
*@ Class Name                                                    : FBE_ScheduleEscalateEmail
*@ Description                                                   : This class is written for scheduling batch apex class-> FBE_slaBatch.
are referred here. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/   
public without sharing class FBE_ScheduleEscalateEmail implements schedulable{
    public void execute(SchedulableContext ctx) {
        FBE_slaBatch Esc = new FBE_slaBatch();
		Database.executeBatch(Esc, 200);
    }
}

/*
 Cron Expression to be run in anonymous window
===============================================
FBE_ScheduleEscalateEmail Esc = new FBE_ScheduleEscalateEmail();
string cronExp1 = '0 0 * * * ?';
string cronExp2 = '0 30 * * * ?';
string JobId1 = system.schedule('Schedule job every 1 hr', cronExp1, Esc);
string JobId2 = system.schedule('Schedule job every 30 mins', cronExp2, Esc);

 */
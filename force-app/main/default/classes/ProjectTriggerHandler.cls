/***************************************************************************************
* Created By - Umang Gupta ( Appirio JDC)
* Created On - June 03, 2020
* Related Task - S-655341
* Purpose - trigger for object pse__Proj__c 
****************************************************************************************/
public class ProjectTriggerHandler{
    public static boolean pmNotificationTaskCreated = false;
    public static void populateNextBillingDate(list<pse__Proj__c> newLst,Map<id,pse__Proj__c> oldMap){
        DateTime batchRunTime;
        Date firstQuaterDate = Date.newInstance(Date.today().year(), 3, 31);
        Date fourthQuaterDate = Date.newInstance(Date.today().year(), 3, 31);
        Date thirdQuaterDate = Date.newInstance(Date.today().year(), 3, 31);
        Date secoundQuaterDate = Date.newInstance(Date.today().year(), 3, 31);
        // check if next billing date configartion is setp up in system then use it
        Billing_Request_T_M_Configration__c biilingRequest = Billing_Request_T_M_Configration__c.getInstance();
        if(biilingRequest != Null){
            if(biilingRequest.First_Quarter__c != null){
                firstQuaterDate = biilingRequest.First_Quarter__c;
            }else{
                firstQuaterDate = Date.newInstance(Date.today().year(), 3, 31);
            }
            if(biilingRequest.Secound_Quarter_Date__c != null){
                secoundQuaterDate = biilingRequest.Secound_Quarter_Date__c;
            }else{
                secoundQuaterDate = Date.newInstance(Date.today().year(), 6, 30);
            }
            if(biilingRequest.Third_Quarter_Date__c != null){
                thirdQuaterDate = biilingRequest.Third_Quarter_Date__c;
            }else{
                thirdQuaterDate = Date.newInstance(Date.today().year(), 9, 30);
            }
            if(biilingRequest.fourth_Quarter_Date__c != null){
                fourthQuaterDate = biilingRequest.fourth_Quarter_Date__c;
            }else{
                fourthQuaterDate = Date.newInstance(Date.today().year(), 12, 31);
            }
        }
        
        if(biilingRequest.Batch_Running_Hours__c != Null && biilingRequest.Batch_Running_Minutes__c !=Null){
            Integer hourVal = (Integer)biilingRequest.Batch_Running_Hours__c;
            Integer minVal = (Integer)biilingRequest.Batch_Running_Minutes__c ;
            batchRunTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(),hourVal,minVal,0);
        }else{
            batchRunTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(),23,30,0);
        }
        for(pse__Proj__c proj :newLst){
            if(oldMap.get(proj.Id).pse__Project_Phase__c == 'Setup' && proj.pse__Project_Phase__c != oldMap.get(proj.Id).pse__Project_Phase__c && proj.pse__Project_Phase__c != oldMap.get(proj.Id).pse__Project_Phase__c && (proj.pse__Billing_Type__c == 'Time and Materials'
               || proj.Deal_Type__c == 'Custom')){
                if(proj.Billing_Cadence__c != null && proj.Billing_Period__c != null){
                    // set next billing date according to Billing Cadence and Billing Period
                    if(proj.Billing_Cadence__c == 'Weekly'){
                        String dayOfWeek = Datetime.now().format('EEEE');
                        switch on proj.Billing_Period__c{
                            when 'Monday'{
                                // if project updated on monday and update before batch run
                                if(dayOfWeek == 'Monday' && Datetime.now() < batchRunTime){
                                    // set next billing date with today date
                                    proj.Next_Billing_Date__c = Date.today();
                                }else{
                                    //set next billing date with next monday date
                                    proj.Next_Billing_Date__c = getNextWeekDayDate('Monday');
                                }
                            }
                            when 'Tuesday'{
                                // if project updated on Tuesday and update before batch run
                                if(dayOfWeek == 'Tuesday' && Datetime.now() < batchRunTime){
                                    // set next billing date with today date
                                    proj.Next_Billing_Date__c = Date.today();
                                }else{
                                    //set next billing date with next Tuesday date
                                    proj.Next_Billing_Date__c = getNextWeekDayDate('Tuesday');
                                }
                            }
                            when 'Wednesday'{
                                // if project updated on Wednesday and update before batch run
                                if(dayOfWeek == 'Wednesday' && Datetime.now() < batchRunTime){
                                    // set next billing date with today date
                                    proj.Next_Billing_Date__c = Date.today();
                                }else{
                                    //set next billing date with next Wednesday date
                                    proj.Next_Billing_Date__c = getNextWeekDayDate('Wednesday');
                                }
                            }
                            when 'Thursday'{
                                // if project updated on Thrusday and update before batch run
                                if(dayOfWeek == 'Thursday' && Datetime.now() < batchRunTime){
                                    // set next billing date with today date
                                    proj.Next_Billing_Date__c = Date.today();
                                }else{
                                    //set next billing date with next Thrusday date
                                    proj.Next_Billing_Date__c = getNextWeekDayDate('Thursday');
                                }
                            }
                            when 'Friday'{
                                // if project updated on Friday and update before batch run
                                if(dayOfWeek == 'Friday' && Datetime.now() < batchRunTime){
                                    // set next billing date with today date
                                    proj.Next_Billing_Date__c = Date.today();
                                }else{
                                    //set next billing date with next Friday date
                                    proj.Next_Billing_Date__c = getNextWeekDayDate('Friday');
                                }
                            }
                        }
                    }else if(proj.Billing_Cadence__c == 'Monthly'){
                        integer periodDay = integer.valueOf(proj.Billing_Period__c);
                        if(Date.today().day() <= periodDay){
                            //set next billing date with today date
                            if(Date.today().day() == periodDay && DateTime.now() < batchRunTime){
                                proj.Next_Billing_Date__c = Date.today();
                            }else{
                                proj.Next_Billing_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), periodDay);
                            }
                        }else{
                            //set next billing date with next month date
                            proj.Next_Billing_Date__c = Date.newInstance(Date.today().year(), Date.today().month()+1, periodDay);
                        }
                    }else if(proj.Billing_Cadence__c == 'Quarterly'){
                        switch on proj.Billing_Period__c{
                            when '1' {
                                // first quarter
                                if(DateTime.now() < batchRunTime){
                                    proj.Next_Billing_Date__c = firstQuaterDate;
                                }else{
                                    // set net quarter date
                                    proj.Next_Billing_Date__c = secoundQuaterDate;
                                }
                            }
                            when '2' {
                                // second quarter
                                if(DateTime.now() < batchRunTime){
                                    proj.Next_Billing_Date__c = secoundQuaterDate;
                                }else{
                                    // set netx quarter date
                                    proj.Next_Billing_Date__c = thirdQuaterDate;
                                }
                            }
                            when '3' {
                                // third quarter
                                if(DateTime.now() < batchRunTime){
                                    proj.Next_Billing_Date__c = thirdQuaterDate;
                                }else{
                                    // set netx quarter date
                                    proj.Next_Billing_Date__c = fourthQuaterDate;
                                }
                            }
                            when '4' {
                                // fourth quarter
                                if(DateTime.now() < batchRunTime){
                                    proj.Next_Billing_Date__c = fourthQuaterDate;
                                }else{
                                    // set netx quarter date
                                    // firstQuaterDate = firstQuaterDate.addYears(1);
                                    proj.Next_Billing_Date__c = firstQuaterDate.addYears(1);
                                }
                            }
                        }
                    }
                }else{
                    // set next month 15
                    Date nextMonth15 = date.newInstance(Date.today().year(), Date.today().month(), 15);
                    if(Date.today().day() > 15 || ( Date.today().day() == 15 && DateTime.now() >= batchRunTime)){
                        // set next month 15
                        integer year = Date.today().year();
                    	integer month = Date.today().month();
                        if(month == 12){
                       		month = 1; 
                       		year += 1;
                        }else{
                           month += 1; 
                        }
                        nextMonth15 = date.newInstance(year, month, 15);
                    }
                    
                    proj.Next_Billing_Date__c = nextMonth15;
                }
            }
        }
        
    }
    public static Date getNextWeekDayDate(string nextWeekDay){
        DateTime dt = DateTime.Now();
        for(integer i =1;i<= 7; i++){
            dt = dt.addDays(1);
            if(dt.format('EEEE') == nextWeekDay){
                break;
            }
        }
        return dt.date();
    }
 /***************************************************************************************
* Created By - vinod kumar ( Appirio JDC)
* Created On - jan 12, 2021
* Related Task - I-415767
* Purpose -  If next billing date populate then create PM notification for PM
****************************************************************************************/
    public static void createPmNotificationTask(list<pse__Proj__c> newList,Map<id,pse__Proj__c> oldMap){
        list<pse__Proj__c> selectedProject = new list<pse__Proj__c>();
        for(pse__Proj__c proj : newList){
            if(proj.Next_Billing_Date__c != null && oldMap.get(proj.Id).pse__Project_Phase__c == 'Setup' && proj.pse__Project_Phase__c != oldMap.get(proj.Id).pse__Project_Phase__c && (proj.pse__Billing_Type__c == 'Time and Materials'
               || proj.Deal_Type__c == 'Custom')){
                selectedProject.add(proj);
            }
        }
        if(!selectedProject.isEmpty()){
            CreatePmNotificationTaskQueueable createJob = new CreatePmNotificationTaskQueueable(selectedProject);
            // enqueue the job for processing
            pmNotificationTaskCreated = true;
            ID jobID = System.enqueueJob(createJob);
            
        }
        
    } 
}
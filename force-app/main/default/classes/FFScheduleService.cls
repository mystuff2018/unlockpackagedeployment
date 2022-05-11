// /**
// * @author Thomas Davis <thdavis@financialforce.com>
// * @date 2020-05-12
// * @description Service class whose run() method is called in FFServiceAppointmentTriggerHandler.cls to calculate
// * ServiceAppointment Assignment Scheduled Hours.
// * TFS Stories 8040168, 8329857, 8329865.
// */
 public class FFScheduleService
 {
    // /*******************************************************************************************************
    // * @description Calculates Scheduled Hours of Service Appointment Assignments.
    // * @param projectIds Set of pse__Proj__c Ids.
    // * @example
    // * FFScheduleService.run(FFScheduleService.getServiceAppointmentProjectIds(Trigger.new));
    // */
    // public static void run(Set<Id> projectIds)
    // {
        // if(projectIds !=null && projectIds.size() > 0){
			// List<pse__Schedule_Exception__c> scheduleExceptionUpsertList = new List<pse__Schedule_Exception__c>();
			// Map<Id, List<ServiceAppointment>> scheduleIdToServiceAppointmentsMap = getServiceAppointmentsByScheduleId(getServiceAppointments(projectIds));
			// Map<Id, List<pse__Schedule_Exception__c>> scheduleIdToScheduleExceptionsMap = getScheduleExceptionsByScheduleId(scheduleIdToServiceAppointmentsMap.keySet());
			// Map<Id, pse__Schedule__c> scheduleMap = getScheduleMap(scheduleIdToServiceAppointmentsMap.keySet());
			// System.debug('scheduleIdToServiceAppointmentsMap'+scheduleIdToServiceAppointmentsMap);
			// System.debug('scheduleIdToScheduleExceptionsMap'+scheduleIdToScheduleExceptionsMap);
			// System.debug('scheduleMap'+scheduleMap);
			
			// for (Id scheduleId : scheduleIdToServiceAppointmentsMap.keySet())
			// {
				// pse__Schedule__c schedule = scheduleMap.get(scheduleId);
				// List<Date> dates = new List<Date>();
				// Integer daysBetween = schedule.pse__Start_Date__c.daysBetween(schedule.pse__End_Date__c);
				// Map<Date, pse__Schedule_Exception__c> dateToScheduleExceptionMap = new Map<Date, pse__Schedule_Exception__c>();
				// Boolean scheduleStartDateSet = false;
				// System.debug('daysBetween'+daysBetween);
				// for (Integer i = 0; i <= daysBetween; i++)
				// {
					// dates.add(schedule.pse__Start_Date__c + i);
				// }

				// if (scheduleIdToScheduleExceptionsMap != null && !scheduleIdToScheduleExceptionsMap.isEmpty())
				// {
					// if (scheduleIdToScheduleExceptionsMap.containsKey(scheduleId))
					// {
						// for (pse__Schedule_Exception__c scheduleException : scheduleIdToScheduleExceptionsMap.get(scheduleId))
						// {
							// dateToScheduleExceptionMap.put(scheduleException.pse__Date__c, scheduleException);
						// }
					// }
				// }
				// System.debug('dates=='+dates);
				// for (Date d : dates)
				// {
					// Decimal hoursPerDay = 0;
					// System.debug('Value for loop'+scheduleIdToServiceAppointmentsMap.get(scheduleId));
					// for (ServiceAppointment sa : scheduleIdToServiceAppointmentsMap.get(scheduleId))
					// {
					   // if(sa.SchedEndTime != null && sa.SchedStartTime !=null) {
						// System.debug('sa===='+scheduleMap); 
						// system.debug('sa.SchedEndTime.date()'+sa.SchedEndTime.date());
						// SYstem.debug('sa.SchedStartTime.date()'+sa.SchedStartTime.date());
						// if (d <= sa.SchedEndTime.date() && d >= sa.SchedStartTime.date())
						// {
							// hoursPerDay += calculateHoursPerDay(sa.Duration, sa.SchedStartTime, sa.SchedEndTime);
							// System.debug('hoursPerDay'+hoursPerDay);
						// }
					// }
					// }

					// if (dateToScheduleExceptionMap.keySet().contains(d))
					// {
						// pse__Schedule_Exception__c scheduleException = dateToScheduleExceptionMap.get(d);
						// scheduleException.pse__Exception_Hours__c = hoursPerDay;
						// setHoursFieldsToNull(scheduleException);
						// scheduleExceptionUpsertList.add(scheduleException);
					// }
					// else
					// {
						// scheduleExceptionUpsertList.add(createScheduleException(false, scheduleId, d, d, hoursPerDay));
					// }

					// if (hoursPerDay != 0)
					// {
						// if (!scheduleStartDateSet)
						// {
							// scheduleMap.get(scheduleId).pse__Start_Date__c = d;
							// scheduleStartDateSet = true;
						// }

						// scheduleMap.get(scheduleId).pse__End_Date__c = d;
					// }
				// }
			// }

			// if (!scheduleExceptionUpsertList.isEmpty())
			// {
				// try
				// {
					// upsert scheduleExceptionUpsertList;
					// update scheduleMap.values();
				// }
				// catch (Exception e)
				// {
					// insert new ExceptionLogger__c(Apex_Class__c = 'FFScheduleService', Method_Name__c = 'run()', Description__c = e.getMessage() + '\n' + e.getStackTraceString() + '\n' + e.getCause() + '\n' + e.getLineNumber());
				// }
			// }
		// }
		
    // }

    // /*******************************************************************************************************
    // * @description Collects pse__Proj__c Ids from the Project__c field of a List of ServiceAppointment records.
    // * @param serviceAppointments List of ServiceAppointment SObjects.
    // * @return A Set of pse__Proj__c Ids.
    // * @example
    // * FFScheduleService.getServiceAppointmentProjectIds(Trigger.new);
    // */
    // public static Set<Id> getServiceAppointmentProjectIds(List<ServiceAppointment> serviceAppointments, Map<Id, ServiceAppointment> oldServiceAppointment)
    // {
        // Set<Id> returnSet = new Set<Id>();
		// System.debug('serviceAppointments'+serviceAppointments); System.debug('returnSet'+returnSet);
        // for (ServiceAppointment sa : serviceAppointments)
        // {
			// ServiceAppointment objSA= oldServiceAppointment.get(sa.Id); 
            
            // if (sa.Project__c != null && !returnSet.contains(sa.Project__c) && sa.Assignment__c != objSA.Assignment__c)
            // {
                // System.debug('Inside if'+returnSet.contains(sa.Project__c));
                // returnSet.add(sa.Project__c);
            // }
        // }
		// System.debug('returnSet'+returnSet);
        // return returnSet;
    // }

    // /*******************************************************************************************************
    // * @description Calculates hours per day.
    // * @param duration A decimal representing the time it takes to complete a task.
    // * @param startDateTime The start date and time of a task.
    // * @param endDateTime The end date and time of a task.
    // * @return The calculated hours per day in Decimal format.
    // * @example
    // * calculateHoursPerDay(40, System.now(), System.now() + 7);
    // */
    // private static Decimal calculateHoursPerDay(
            // Decimal duration,
            // Datetime startDateTime,
            // Datetime endDateTime
    // )
    // {
        // return (duration / startDateTime.date().daysBetween(endDateTime.date() + 1));
    // }

    // /*******************************************************************************************************
    // * @description Creates and/or inserts pse__Schedule_Exception__c SObjects.
    // * @param doInsert Determines if the pse__Schedule_Exception__c SObject should be inserted.
    // * @param scheduleId An Id of a pse__Schedule__c record.
    // * @param startDate A Date that will set the pse__Date__c field of the newly created pse__Schedule_Exception__c.
    // * @param endDate A Date that will set the pse__End_Date__c field of the newly created pse__Schedule_Exception__c.
    // * @param hoursPerDay A Decimal that will set the pse__Exception_Hours__c field of the newly created
    // * pse__Schedule_Exception__c.
    // * @return The newly created pse__Schedule_Exception__c SObject.
    // * @example
    // * createScheduleException(true, schedule.Id, System.today(), System.today() + 7, 8);
    // */
    // private static pse__Schedule_Exception__c createScheduleException(
            // Boolean doInsert,
            // Id scheduleId,
            // Date startDate,
            // Date endDate,
            // Decimal hoursPerDay
    // )
    // {
        // pse__Schedule_Exception__c scheduleException = new pse__Schedule_Exception__c(
                // pse__Schedule__c = scheduleId,
                // pse__Date__c = startDate,
                // pse__End_Date__c = endDate,
                // pse__Exception_Hours__c = hoursPerDay
        // );

        // if (doInsert)
        // {
            // insert scheduleException;
        // }

        // return scheduleException;
    // }

    // /*******************************************************************************************************
    // * @description Groups pse__Schedule_Exception__c records by their parent pse__Schedule__c Id.
    // * @param scheduleIds Set of pse__Schedule__c Ids.
    // * @return Map with pse__Schedule__c Id as key, and a List of children pse__Schedule_Exception__c records as its
    // * value.
    // * @example
    // * getScheduleExceptionsByScheduleId(scheduleIdToServiceAppointmentsMap.keySet());
    // */
    // private static Map<Id, List<pse__Schedule_Exception__c>> getScheduleExceptionsByScheduleId(Set<Id> scheduleIds)
    // {
        // Map<Id, List<pse__Schedule_Exception__c>> returnMap = new Map<Id, List<pse__Schedule_Exception__c>>();

        // List<pse__Schedule_Exception__c> scheduleExceptions =
        // [
                // SELECT pse__Schedule__c, pse__Date__c, pse__End_Date__c, pse__Exception_Hours__c
                // FROM pse__Schedule_Exception__c
                // WHERE pse__Schedule__c IN :scheduleIds
                // ORDER BY pse__Date__c
        // ];

        // for (pse__Schedule_Exception__c scheduleException : scheduleExceptions)
        // {
            // if (!returnMap.containsKey(scheduleException.pse__Schedule__c))
            // {
                // returnMap.put(scheduleException.pse__Schedule__c, new List<pse__Schedule_Exception__c>());
            // }

            // returnMap.get(scheduleException.pse__Schedule__c).add(scheduleException);
        // }

        // return returnMap;
    // }

    // /*******************************************************************************************************
    // * @description Converts a Set of pse__Schedule__c Ids to a Map.
    // * @param scheduleIds Set of pse__Schedule__c Ids.
    // * @return A Map with pse__Schedule__c Id as key, and its associated SObject as its value.
    // * @example
    // * getScheduleMap(scheduleIdToServiceAppointmentsMap.keySet());
    // */
    // private static Map<Id, pse__Schedule__c> getScheduleMap(Set<Id> scheduleIds)
    // {
        // return new Map<Id, pse__Schedule__c>([
                // SELECT pse__Start_Date__c, pse__End_Date__c
                // FROM pse__Schedule__c
                // WHERE Id IN :scheduleIds
        // ]);
    // }

    // /*******************************************************************************************************
    // * @description Collects ServiceAppointment records that are needed for Assignment Scheduled Hours
    // * calculation.
    // * @param projectIds Set of pse__Proj__c Ids.
    // * @return A List of ServiceAppointment record that meet query criteria.
    // * @example
    // * getServiceAppointments(projectIds);
    // */
    // private static List<ServiceAppointment> getServiceAppointments(Set<Id> projectIds)
    // {
        // return
        // [
                // SELECT Assignment__r.pse__Schedule__c, Assignment__r.pse__Schedule__r.pse__Start_Date__c,
                        // Assignment__r.pse__Schedule__r.pse__End_Date__c, SchedStartTime, SchedEndTime, Duration
                // FROM ServiceAppointment
                // WHERE Project__c IN :projectIds
                // AND Assignment__r.pse__Schedule__c != NULL
                // AND Status != 'Cancelled'
                // AND Assignee__c != NULL
        // ];
    // }

    // /*******************************************************************************************************
    // * @description Groups ServiceAppointment records by their associated pse__Schedule__c Id.
    // * @param serviceAppointments List of ServiceAppointment SObjects.
    // * @return Map with pse__Schedule__c Id as key, and a List of associated ServiceAppointment records as its
    // * value.
    // * @example
    // * getServiceAppointmentsByScheduleId(getServiceAppointments(projectIds));
    // */
    // private static Map<Id, List<ServiceAppointment>> getServiceAppointmentsByScheduleId(List<ServiceAppointment> serviceAppointments)
    // {
        // Map<Id, List<ServiceAppointment>> returnMap = new Map<Id, List<ServiceAppointment>>();

        // for (ServiceAppointment serviceAppointment : serviceAppointments)
        // {
            // if (!returnMap.containsKey(serviceAppointment.Assignment__r.pse__Schedule__c))
            // {
                // returnMap.put(serviceAppointment.Assignment__r.pse__Schedule__c, new List<ServiceAppointment>());
            // }

            // returnMap.get(serviceAppointment.Assignment__r.pse__Schedule__c).add(serviceAppointment);
        // }

        // return returnMap;
    // }

    // /*******************************************************************************************************
    // * @description Sets the hours fields of a pse__Schedule_Exception__c to null.
    // * @param scheduleException A pse__Schedule_Exception__c SObject.
    // * @example
    // * setHoursFieldsToNull(scheduleException);
    // */
    // private static void setHoursFieldsToNull(pse__Schedule_Exception__c scheduleException)
    // {
        // Set<String> hoursFieldAPINames = new Set<String>
        // {
                // 'pse__Monday_Hours__c',
                // 'pse__Tuesday_Hours__c',
                // 'pse__Wednesday_Hours__c',
                // 'pse__Thursday_Hours__c',
                // 'pse__Friday_Hours__c',
                // 'pse__Saturday_Hours__c',
                // 'pse__Sunday_Hours__c'
        // };

        // for (String hoursFieldAPIName : hoursFieldAPINames)
        // {
            // scheduleException.put(hoursFieldAPIName, null);
        // }
    // }
 }
public class CandidateProjectsToAssociationController 
{
    @AuraEnabled
    public static List<SuggestedProjectAssociation> getProjectSuggestions(Id orderId) 
    {
        List<SuggestedProjectAssociation> listRecommended = RecommendedProject.getSetRecommendedEngagementIdByOrderId(orderId);
        system.debug('listRecommended '+listRecommended);
        return listRecommended;
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() 
    {
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Order'];
        
        // Perform isAccessible() check here
        return listviews;
    }

    @AuraEnabled
    public static List<String> disassociationOrder(Id orderId){
        system.debug('disassociationOrder '+orderId);
        List<String> result = new List<String>();
        Set<Id> setOrderId = new set<Id>();
        setOrderId.add(orderId);
        try{
            OrderDisassociationHandler handler = new OrderDisassociationHandler(setOrderId);
            handler.run();
            if(handler.context.orderIdToPreventReason.containsKey(orderId)){
                result.addAll(handler.context.orderIdToPreventReason.get(orderId));
            }
            for(ExceptionLogger__c ex : handler.context.exceptionLoggers){
                result.add(ex.Description__c);
            }
            System.debug('result: ' +result);

        } catch(Exception except){
            system.debug('except: ' + except.getCause());
            system.debug('except: ' + except.getLineNumber());
            system.debug('except: ' + except.getMessage());
            system.debug('except: ' + except.getStackTraceString());
            system.debug('except: ' + except.getTypeName());
            result.add(except.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static List<String> createProject(Id orderId){
        List<String> result = new List<String>();
      
        Set<Id> setOrderId = new set<Id>();
        setOrderId.add(orderId);
        try{
            OrderCreatedDataContext context = new OrderCreatedDataContext(setOrderId);
            EngagementCreation.createEngagementBySetOrderId(context);
            context.saveOrderAssociation();
            context.sendToOrderItemGroupingEvent();
          
            for(ExceptionLogger__c ex : context.exceptionLoggers){
                System.debug('except: ' +ex.Description__c);
            }
            if (context.exceptionLoggers != null && context.exceptionLoggers.size() > 0) {
                result.add('Failed! Project could not be created. Please contact salesforce administrator.');
            }

        } catch(Exception except){
            system.debug('except: ' + except.getCause());
            system.debug('except: ' + except.getLineNumber());
            system.debug('except: ' + except.getMessage());
            system.debug('except: ' + except.getStackTraceString());
            system.debug('except: ' + except.getTypeName());
            result.add('Failed! Project could not be created. Please contact salesforce administrator.');
        }
        
        return result;
    }
}
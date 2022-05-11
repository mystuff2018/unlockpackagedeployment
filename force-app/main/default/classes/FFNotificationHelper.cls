public class FFNotificationHelper {
    
    public static void buildFFNotification(String title, String body, Id targetId, Set<String> recipientIds) {
        
        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'FFNotificationHelper']?.Id;
        
        if(typeId != null){
            try {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody(body);
                notification.setTitle(title);
                notification.setSenderId(Userinfo.getUserId());
                notification.setNotificationTypeId(typeId);
                notification.setTargetId(targetId);
                notification.send(recipientIds);
                
            }catch (Exception e) {
                insert SaveResultExceptionLogger.createExceptionLogger(e, FFNotificationHelper.Class.getName(), 'Send notification failure');
            }            
        }        
    }
    
    //This map cover the object Id and the text that will be posted in the chatter
  /*  public static void postChatter(Map<Id, String> mapPost){        
        List<FeedItem> ltFeedItem = new List<FeedItem>();
        
        try {
            
            for (Id objectId : mapPost.keySet()) {            
                FeedItem post = new FeedItem();
                post.ParentId = objectId;
                post.Body = mapPost.get(objectId);
                
                ltFeedItem.add(post);
            }        
            
            insert ltFeedItem;
            
        }catch (Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, FFNotificationHelper.Class.getName(), 'Post Chatter failure');
        }    
    }*/
}
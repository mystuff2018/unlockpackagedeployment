public without sharing class FBE_RoleUtility {
  @AuraEnabled (cacheable = true) 
  public static List<User> getRoleSubordinateUsers(Id userId) {
    
    // get requested user's role
    Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;//System.debug('roleId'+roleId);
    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});//System.debug('allSubRoleIds'+allSubRoleIds);
    // get all of the ids for the users in those roles
    List<User> users = new List<User>([Select Id, Name,UserRole.Name,LastLoginDate,Email From User where 
      UserRoleId IN :allSubRoleIds]);//System.debug(users);
    // return the ids as a set so you can do what you want with them
    return users;
    
  }
    
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    //System.debug('roleIds'+roleIds);
    Set<ID> currentRoleIds = new Set<ID>();
    
    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId 
      IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);
    
    // go fetch some more rolls!
    if(currentRoleIds.size() > 0)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

    return currentRoleIds;
    
  }

}
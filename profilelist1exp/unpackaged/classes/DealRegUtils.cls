public class DealRegUtils {
    //returning is it a gc country
    public static boolean isGCCountry(){
        if( GCUserProfiles__c.getAll().keyset().contains(UserInfo.getProfileId()) ){
            return true;
        }else{
            return false;
        }       
    } 
    
    public static boolean isOwnerIdhasGcProfile(id ownerid){
     user userId = [Select Id, ProfileId from User where Id = :ownerid];
        if( GCUserProfiles__c.getAll().keyset().contains(userId.ProfileId) ){
            return true;
        }else{
            return false;
        }       
    }
    
    public static Map<Id, boolean> isOwnerHasGCProfile(Set<Id> ownerIds){ 
        List<User> userList = new List<User>();
        Map<Id, Boolean> ownerMap = new Map<Id, Boolean>();
        If(ownerIds.size() > 0){
            userList = [Select Id, ProfileId from User where Id IN: ownerIds];
        }
        
        If(userList.size() > 0){
            for(User userObj: userList){
                If( GCUserProfiles__c.getAll().keyset().contains(userObj.ProfileId) ){
                   ownerMap.put(userObj.Id, true);
                }else{
                    ownerMap.put(userObj.Id, false);
                }
            } 
        }
        return ownerMap;
    }
    
 public static boolean isGCDeal(String country){
        boolean isGCdeal = false;
        map<String,CountryNotApplicableToNonGC__c> GCcountries = CountryNotApplicableToNonGC__c.getAll();
        Set<String> GCcountriesSet = new Set<String>();
     if(GCcountries.size() > 0 && country != null ){
        for(String s: GCcountries.keySet()){
                GCcountriesSet.add(s.toUpperCase());
        }     
        
        
     if(GCcountriesSet.contains(country.toUpperCase())){
        isGCdeal = true;
     }
     else{
        isGCdeal = false; 
     }
   }
    return isGCdeal;
  }
}
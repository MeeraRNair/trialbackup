public class SelectViewController{

     public PageReference decision(){
         Id id;
         Integer lastIndex = 0;
         String userProfileNameStr;
         
         id = ApexPages.currentPage().getParameters().get('id');
         String profile=UserInfo.getProfileId();
         Profile profileRec = [SELECT Id,Name FROM profile WHERE id =: profile limit 1]; 
         //Remove versioning Rxx.xx
         Pattern p = Pattern.compile('^R[0-9]+\\.[0-9]+\\s');
         Matcher m = p.matcher(profileRec.Name);
         
         if(m.lookingAt()==true){
             userProfileNameStr = profileRec.Name.Substring(m.end()); 
         }
         else{
             userProfileNameStr = profileRec.Name;
         }         
         if(userProfileNameStr.endsWith('- Non SSO')){
             lastIndex = userProfileNameStr.lastIndexOf('- Non SSO');
             userProfileNameStr = userProfileNameStr.substring(0,lastIndex);
         }
         userProfileNameStr = userProfileNameStr.trim();
         string labelProfileNameList = Label.Bolt_Admin_Analyst_IT_Profiles;
         List<String>profileList = labelProfileNameList.split(';');
         system.debug('profileList '+profileList );
         String abc;
         for(String profileStr: profileList){
         system.debug('profileStr'+profileStr+profileStr.length());
             if(profileStr.length()>0){
                 profileStr = profileStr.trim();
                 if(profileStr.equalsIgnoreCase(userProfileNameStr)){
                     return(new PageReference('/apex/AnalystTopics?id='+id+'&user=analyst'));
                 }      
             }      
         }
         return(new PageReference('/apex/AETopics?id='+id+'&user=AE'));   
     }
}
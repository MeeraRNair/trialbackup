/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#  UserStory#                  Description
-------     ------      ----            --------    ---  ----------                  -----------
1.0         Jananii     23-JULY-2015                      Story 171045:Site Look     Created for removing IFrame from FAP Page.
                                                          and Feel iFrame: New Header  

*/

public class FAP_HeaderComponentController {

public String thisCountry { get; set; }
Header__mdt homepageURL=new Header__mdt();

public String  countryHomePageURL{

    get {
      if (countryHomePageURL!= null) {
         return countryHomePageURL;
      }
      
      else{
       try{
           homepageURL=[SELECT Home_Page_URL__c FROM Header__mdt WHERE DeveloperName=:thisCountry.toLowerCase()];
       }
       catch (QueryException e) {
           homepageURL= new Header__mdt(); 
           System.debug(e.getMessage());
       }
     
     
      if(homepageURL==null){
      countryHomePageURL=null;
      }
      
      else{
      countryHomePageURL= homepageURL.Home_Page_URL__c ;
      }
      
      return countryHomePageURL;
    } 
    }
    
    set;
    }    
}
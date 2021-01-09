/*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
*  1.0     CR 16007    FY19-DCS-0802   07-June-2018      Michael       Decommisioned netexam and Provisioned_in_Netexam_on__c as Part of Story# 4988554 
*/

public class PartnerUtils {

        public static Boolean bypassOnTest = false;
        
        private static String[] SUPPORTED_LANGUAGE_CODES = new String[]{
                'zh-cn'         //Chinese (Simplified)
                ,'zh-tw'        //Chinese (Traditional)
                ,'nl-nl'        //Dutch
                ,'en-us'        //English
                ,'fi'           //Finnish
                ,'fr'           //French
                ,'de'           //German
                ,'it'           //Italian
                ,'ja'           //Japanese
                ,'ko'           //Korean
                ,'pl'           //Polish
                ,'pt-br'        //Portuguese (Brazilian)
                ,'ru'           //Russian
                ,'es'           //Spanish
                ,'sv'           //Swedish
                ,'th'           //Thai
                ,'cs'           //Czech
                ,'da'           //Danish
                ,'hu'           //Hungarian
                ,'in'           //Indonesian
                ,'tr'           //Turkish
        };
        
        private static Map<string,string> LANGUAGE_CONVERSION_CODES_MAP = new Map<string,string>{
          'zh'  => 'zh-cn' ,
          'nl'  => 'nl-nl' ,
          'en'  => 'en-us' ,          
          'pt'  => 'pt-br'              
        };
                      
        private static final String HTTP_LANGUAGE_CODE_PARAMETER_KEY = 'l';
        
        private static string convertLanguageCode(string languageCode){
          if(LANGUAGE_CONVERSION_CODES_MAP.containsKey(languageCode)){
            return LANGUAGE_CONVERSION_CODES_MAP.get(languageCode);
          }else{
            return languageCode;
          }
        }

        public static String getPreferredLanguageCode(){
                //====================================================
                //(1) CHECK HTTP "LANGUAGE" PARAMETER
                //====================================================
                final Set<String> LANGUAGE_CODE_SET = getSuppLangCodeSet();
                System.debug('LANGUAGE_CODE_SET = ' + toString(LANGUAGE_CODE_SET));
                final String LANGUAGE_HTTP_PARAMETER = 
                        convertLanguageCode(StringUtils.lowerCase(
                                StringUtils.replaceChars( 
                                        ApexPages.currentPage().getParameters().get(HTTP_LANGUAGE_CODE_PARAMETER_KEY), '_', '-'
                                )
                        ));
                System.debug('LANGUAGE_HTTP_PARAMETER = ' + LANGUAGE_HTTP_PARAMETER);
                if(StringUtils.isNotBlank(LANGUAGE_HTTP_PARAMETER)
                        && LANGUAGE_CODE_SET.contains(LANGUAGE_HTTP_PARAMETER)){
                        System.debug('Return Option (1) LANGUAGE HTTP PARAMETER: ' + LANGUAGE_HTTP_PARAMETER);
                        return LANGUAGE_HTTP_PARAMETER;
                }
                
                //====================================================
                //(2) CHECK BROWSER SETTINGS
                //====================================================
          
                final String LANGUAGES_FROM_BROWSER_AS_STRING = ApexPages.currentPage().getHeaders().get('Accept-Language');
                System.debug('LANGUAGES_FROM_BROWSER_AS_STRING = ' + LANGUAGES_FROM_BROWSER_AS_STRING);
                final List<String> LANGUAGES_FROM_BROWSER_AS_LIST = splitAndFilterAcceptLanguageHeader(LANGUAGES_FROM_BROWSER_AS_STRING);
                System.debug('LANGUAGES_FROM_BROWSER_AS_STRING = ' + toString(LANGUAGES_FROM_BROWSER_AS_LIST));
                if(LANGUAGES_FROM_BROWSER_AS_LIST != null && LANGUAGES_FROM_BROWSER_AS_LIST.size() > 0){
                        for(String languageFromBrowser : LANGUAGES_FROM_BROWSER_AS_LIST){
                                if(LANGUAGE_CODE_SET.contains(languageFromBrowser)){
                                        System.debug('Return Option (2) BROWSER SETTINGS: ' + languageFromBrowser);
                                        return languageFromBrowser;
                                }
                        }               
                }
    
                //====================================================
                //(3) USER SETTINGS
                //====================================================
                return UserInfo.getLanguage();
        }
        //This method is defined in order to use this class as controller class for Talk To Dell auxilary pages.
        public String getLanguageCode(){
            return getPreferredLanguageCode();
        }
        
        @future
        public static void createInactivateUserPartnerRequest(Set<Id> ids){
                System.debug('createInactivateUserPartnerRequest(' 
                        + SetUtils.toString(ids) + '): invoked');
                if(ids == null || ids.size() <= 0){
                        return; 
                }
                final Id REMOVE_USER_RECORD_TYPE = IdLookupUtils.getRecordTypeId(
                        PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER, 'Partner_Request__c', true);
                System.assert(REMOVE_USER_RECORD_TYPE != null, 'Record type \'' 
                        + PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER + '\' not found.');
                        
                List<User> users = new List<User>([
                        select id, ContactId, Contact.AccountId, Contact.Account.Account_Country_Code__c 
                        from User 
                        where id in :ids 
                        and IsActive = false]); //checking IsActive because the User might already be IsActive again
                if(users == null || users.size() <= 0){
                        return; 
                }
                Map<String,String> country2QueueId = getPartnerSupportQueues(users);
                List<Partner_Request__c> requestList = new List<Partner_Request__c>();
                Partner_Request__c request = null;
                String queueId = null;
                for(User user : users){
                        request = new Partner_Request__c();
                        request.Account__c = user.Contact.AccountId;
                        request.Contact__c = user.ContactId;
                        request.RecordTypeId = REMOVE_USER_RECORD_TYPE;
                        queueId = country2QueueId.get(user.Contact.Account.Account_Country_Code__c);
                        if(StringUtils.isNotBlank(queueId)){
                                request.OwnerId = queueId; 
                        }
                        
                        //Raymond 20100302 - Default status to complete, CR2420
                        request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
                        requestList.add(request);
                }
                insert requestList;
                System.debug('createInactivateUserPartnerRequest(' 
                        + SetUtils.toString(ids) + '): done');
        }
        
        private static Map<String,String> getPartnerSupportQueues(List<User> users){
                Set<String> countryCodes = new Set<String>();
                for(User user : users){
                        countryCodes.add(user.Contact.Account.Account_Country_Code__c);
                }
                Map<String,String> country2QueueId = new Map<String,String>();
        List<Country__c> countryList = [
                select Code__c, Partner_Support_Queue_ID__c 
                from Country__c 
                where Code__c in :countryCodes];
        if(countryList != null && !countryList.isEmpty()){
                for(Country__c country : countryList){
                        country2QueueId.put(country.Code__c, country.Partner_Support_Queue_ID__c);
                }
        }
        return country2QueueId;
        }
        
        private static List<String> splitAndFilterAcceptLanguageHeader(String header){
                List<String> returnList = new List<String>();
                String[] tokens = StringUtils.split(header,',');
                if(tokens != null){
                        for(String token : tokens){
                                if(token != null ){
                                        if(token.contains(';')){
                                                token = token.substring(0,token.indexOf(';',0));
                                        }
                                        returnList.add(token);
                                        if(StringUtils.length(token) > 2){
                                                returnList.add(StringUtils.substring(token,0,2));
                                        }
                                }
                        }       
                }
                return returnList;
        }

        private static Set<String> getSuppLangCodeSet(){
                Set<String> langCodes = new Set<String>();
                for(String langCode : SUPPORTED_LANGUAGE_CODES){
                        if(langCode != null){ 
                                langCodes.add(StringUtils.lowerCase(langCode));
                        }
                }
                return langCodes;
        }

        private static String toString(Set<String> theSet){
                String returnValue = '';
                Boolean isFirst = true;
                for(String aString : theSet){
                        if(isFirst){
                                isFirst = false;        
                        } else {
                                returnValue += ',';
                        }
                        returnValue += '\'' + aString + '\'';
                }
                return '{' + returnValue + '}';
        }
        
    private static String toString(Object[] objectArray){
        String returnValue = '{';
        for(Integer i = 0; i < objectArray.size(); i++){
                if(i!=0){ returnValue += ','; }
                returnValue += '\'' + objectArray[i] + '\'';
        }
        returnValue += '}';
        return returnValue; 
    }
    
    //raymond  20091217
    @future
    public static void updateInactivatedUserContactInfo(List<String> conIdList) {
      
      /*
      List<Contact> contactList = [SELECT Id, Provisioned_in_Netexam_on__c,
                        Is_Transactional_Store__c,
                      Is_Rebate_User__c,
                      Need_Campaign_Builder_Access__c,
                      Premier_Partner__c,
                      Has_Warranty_parts_Info__c
                   FROM Contact
                   WHERE Id IN :conIdList];
      */
      
      List<Contact> contactList = new List<Contact>();
      
      for(String conId : conIdList) {
        
        contactList.add(new Contact(Id=conId, 
                    Transactional_Store__c = false,
                    Is_Rebate_User__c = false,
                    Campaign_Builder__c = false,
                    Premier_Partner__c = false,
                    Warranty_parts_Info__c = false));  
      }      
      
      
      if(contactList.size() > 0) {        
        update contactList;       
      }
      
    }

}
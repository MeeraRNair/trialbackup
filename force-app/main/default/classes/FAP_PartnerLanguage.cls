public virtual class FAP_PartnerLanguage implements FAP_PartnerCountryLangInt{
      
            private String defaultLangKey = ''; 
            private Map<String, String> usrLanguageMap = new Map<String, String>();                 
            
            
            public FAP_PartnerLanguage(){
                initLanguageMap();
            }
            
            //CR 6077 
            public FAP_PartnerLanguage(Boolean isUserObject){
                initUserLanguageMap();
            }
            
            //CR 6077
            public void initUserLanguageMap(){
                usrLanguageMap.clear();
                usrLanguageMap.put('zh_cn','Chinese (Simplified)');
                usrLanguageMap.put('zh_tw','Chinese (Traditional)');
                usrLanguageMap.put('zh_hk','Chinese (Traditional)');
                usrLanguageMap.put('nl_nl','Dutch');
                
                usrLanguageMap.put('en_us','English');
                usrLanguageMap.put('fi','Finnish');
                usrLanguageMap.put('fr','French');
                                
                usrLanguageMap.put('de','German');
                usrLanguageMap.put('it','Italian');
                usrLanguageMap.put('ja','Japanese');
                
                usrLanguageMap.put('ko','Korean');
                usrLanguageMap.put('pl','Polish');
                usrLanguageMap.put('pt_br','Portuguese (Brazilian)');
                
                usrLanguageMap.put('ru','Russian');
                usrLanguageMap.put('es','Spanish');
                usrLanguageMap.put('sv','Swedish');
                
                usrLanguageMap.put('th','Thai');
                usrLanguageMap.put('cs','Czech');
                usrLanguageMap.put('da','Danish');
                
                usrLanguageMap.put('hu','Hungarian');
                usrLanguageMap.put('in','Indonesian');
                usrLanguageMap.put('tr','Turkish');
                usrLanguageMap.put('en','English');
            }
            
            public void initLanguageMap(){
                usrLanguageMap.put('zh-cn','Chinese (Simplified)');
                usrLanguageMap.put('zh-tw','Chinese (Traditional)');
                usrLanguageMap.put('nl-nl','Dutch');
                
                usrLanguageMap.put('en-us','English');
                usrLanguageMap.put('fi','Finnish');
                usrLanguageMap.put('fr','French');
                
                usrLanguageMap.put('de','German');
                usrLanguageMap.put('it','Italian');
                usrLanguageMap.put('ja','Japanese');
                
                usrLanguageMap.put('ko','Korean');
                usrLanguageMap.put('pl','Polish');
                usrLanguageMap.put('pt-br','Portuguese (Brazilian)');
                
                usrLanguageMap.put('ru','Russian');
                usrLanguageMap.put('es','Spanish');
                usrLanguageMap.put('sv','Swedish');
                
                usrLanguageMap.put('th','Thai');
                usrLanguageMap.put('cs','Czech');
                usrLanguageMap.put('da','Danish');
                
                usrLanguageMap.put('hu','Hungarian');
                usrLanguageMap.put('in','Indonesian');
                usrLanguageMap.put('tr','Turkish');
                usrLanguageMap.put('en','English');
            
            }
            
            public Map<String,String> returnUsrMap(){
                return usrLanguageMap;
            }
                                
            public virtual String returnDefaultKey(){
                return defaultLangKey;
            }                               
            
            //method to get value by passing keyValue like en-us        
            public virtual String returnMatchValue(String tempKey){ 
                System.debug('tempKey in returnLanguageValue>>>>' + tempKey);                       
                if(checkingExistence(tempKey)){             
                    System.debug('found it.....');  
                    return usrLanguageMap.get(FAP_StringUtils.lowerCase(tempKey));                  
                }else{
                    System.debug('not found it, calling default.....');
                    return usrLanguageMap.get(FAP_StringUtils.lowerCase(returnDefaultKey()));   
                }                                           
            }
            
            public virtual Boolean checkingExistence(String tempKey){
                Boolean isExist = false;
                if(FAP_StringUtils.isNotBlank(tempKey)&& usrLanguageMap.containsKey(FAP_StringUtils.lowerCase(tempKey)))
                {
                    isExist=true;
                }
                return isExist;
            }
            
}
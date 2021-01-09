/*
History:
Version   Date          Modified By     Description
--------------------------------------------------------------------------------------
1.0      12-Aug-2013    Meghana         Created for OMGO-Workflow

*/
public with sharing class EventNewButtonOverrideCntlr {
    String EventRTid;
    
    public EventNewButtonOverrideCntlr(ApexPages.standardController controller){
        
    }
    
    Public PageReference redirect(){
        try{
            // Get record type for the Event
            EventRTid = IdlookUpUtils.getRecordTypeId('Call Plan','Event', true);
            EventRTid = EventRTid.substring(0, 15);
            
            //fetch the url 
            PageReference pr = ApexPages.currentPage();
            
            //fetch the Event parameters
            // In case override is not needed - redirect to standard SFDC page with all reuqired parameters
            Map<String, String> urlParams = pr.getParameters();
            String stringToAppend = '';
           // string retUrl = pageUtils.encodeVariable(urlParams.get('retURL'));
           // retUrl= retUrl.deleteWhitespace();
           
            string retUrl = urlParams.get('retURL'); //.deleteWhitespace(); 
            //retUrl= pageUtils.encodeVariable(retUrl );
            
            
            for(String keyStr : urlParams.keySet()){
                System.debug('keyStr : '+ keyStr);
                 if(keyStr != 'core.apexpages.devmode.url' && keyStr != 'sfdc.override' &&
                            keyStr != 'save_new' && keyStr != 'scontrolCaching' && keyStr != 'retURL'){
                                if(stringToAppend != '') {
                                stringToAppend += '&';
                            }   
                            stringToAppend += keyStr + '=' + pageUtils.encodeVariable(urlParams.get(keyStr));                         
                 }
            }
            if(stringToAppend.Contains('RecordType='+EventRTid)){           
                String url = '/apex/CallPlan_NewEvent?RecordType='+EventRTid+'&what_id='+pageUtils.encodeVariable(urlParams.get('what_id'))+'&who_id='+pageUtils.encodeVariable(urlParams.get('who_id'))+'&retUrl='+urlParams.get('retUrl');
                return PageUtils.redirect(url);
            }
            else{
                 return PageUtils.redirect('/00U/e?nooverride=1&'+stringToAppend+'&retURL='+retUrl);            
            }   
        }
        catch(Exception ex){  
            system.debug('###DEBUG### Error -- '+ex.getMessage());
           
          }  
        return null;
    }
}
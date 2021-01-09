/***********************************************************
* Name          : PostAutomationForFullRefreshSandbox 
* Description   : Apex class to carry out the implementation of Full Refresh Sandbox Post Automation tasks
* ---------------------------------------------------------
* Revision      Name           Date              Description   
* 1.0           Jessie Tan     21-Dec-2014       To automate the Post Refresh process for Full Refresh Sandbox
*
************************************************************/
public class PostAutomationForFullRefreshSandbox implements PostRefreshAutomationInterface{
    
    private string prodServerURL;
    private String prodOrgId;
    private String currentOrgId;
    private string currentServerURL;
    private String currentServerContentURL;
    
    //map to keep all the necessary predefined patterns
    //key : 1 (Decimal) = Document 
    //key : 2 (Decimal) = Email Templates
    Map<Decimal, List<List<String>>> replacementItemsMap = new Map<Decimal, List<List<String>>>();
    
    public void doAutomation4Document() {
    
        try{
            
            if(Environment.isProduction() && !Test.IsRunningTest())
                throw new ForbiddenEnvironmentException();
                
            System.debug('#### Replaced Doc SOQL:  ' + Label.ReplaceDocSOQL);
        
            //retrieve all the necessary document that requires replacement
            //loop through all the doc and replace with all necessary items for document
            List<Document> documents = Database.query(Label.ReplaceDocSOQL);
            
            for (Document doc : documents){
            
                try{
                
                    String bodyStr = doc.body.toString();
                   
                    bodyStr = replaceItems(bodyStr, replacementItemsMap.get(1));
                    
                    System.debug(
                        '#### Replaced Items in Document [Id : ' + doc.id + ',' + 
                        'Name :' + doc.name + '].'
                     );    
                    
                    doc.body = Blob.valueOf(bodyStr);
                
                }catch(StringException e){
                
                    throw new InvalidUTF8FormatForDocumentBodyException ('Invalid UTF8 Format for document with Document Id: ' + doc.id); 
                    
                }
                    
            }
              
            update documents;
           
        }catch(Exception e){
            handleError(e); 
            throw e;           
        }
        
    }
    
    public void doAutomation4EmailTemplate() {
    
        try{
        
            if(Environment.isProduction() && !Test.IsRunningTest())
                throw new ForbiddenEnvironmentException();
                
            System.debug('#### Email template SOQL:  ' + Label.EmailTemplateSOQL);
        
            //retrieve all the necessary email templates that requires replacement
            //loop through all the email templates and replace with all necessary items for email templates
            List<EmailTemplate> emailTemplates = Database.query(Label.EmailTemplateSOQL);
            
            for (EmailTemplate template: emailTemplates ){
            
                    
                template.body = replaceItems(template.body, replacementItemsMap.get(2));
                
                template.htmlValue= replaceItems (template.htmlValue, replacementItemsMap.get(2));
                    
                System.debug(
                    '#### Replace Server URL in HTML Value of Email Template [Id : ' + template.id + ',' + 
                    'Name :' + template.name + '].'
                    );
                
            }
            
            update emailTemplates ;
           
        }catch(Exception e){
            handleError(e); 
            throw e;           
        }
        
    }
    
    public void initialize(){
    
        try{
            
            if(Environment.isProduction() && !Test.IsRunningTest())
                throw new ForbiddenEnvironmentException();
                
            retrieveConfigInfo();
            retrievePostRefreshReplacementItems();
        }catch(Exception e){
            handleError(e); 
            throw e;           
        }
        
    }
    
    //replace 1 particular items for current string
    private String replaceEachItem(String targetStr, String matchItem, String finalItem){
    
        if(targetStr==null)
            return null;
                                    
        return targetStr.replace(matchItem, finalItem);
    
    }
    
    //construct the actual replacement items from replacement patterns
    private List<String> constructReplacementItems(String matchPattern, String finalPattern, String id){
    
        String newItem =  String.format(
                                    finalPattern, new String[]{
                                        currentServerURL, 
                                        IdLookupUtils.getShortGUID(currentOrgId), 
                                        IdLookupUtils.getShortGUID(id),
                                         currentServerContentURL
                                     }
                                 );
        String oldItem =  String.format(
                                    matchPattern, new String[]{
                                        prodServerURL, 
                                        IdLookupUtils.getShortGUID(prodOrgId), 
                                        IdLookupUtils.getShortGUID(id)                                       
                                     }
                                 );
        
        return new List<String>{oldItem, newItem};
    
    }
    
    //replace all the items for current string
    private String replaceItems(String targetStr, List<List<String>> items){
    
        for (List<String> item: items){
            
            targetStr = replaceEachItem(targetStr, item.get(0), item.get(1));
            
        }

        return targetStr;
            
    }
    
    //retrieve all the items (that system going to replace) from patterns
    private void retrievePostRefreshReplacementItems(){
    
        List<PostRefreshReplacementPattern__c> patterns = [Select IdList__c, MatchPattern__c, ReplacementPattern__c, Sequence__c, Type__c from PostRefreshReplacementPattern__c order by Sequence__c ];
        
        for (PostRefreshReplacementPattern__c pattern: patterns){
        
            if(!replacementItemsMap.containsKey(pattern.Type__c)){
                
                replacementItemsMap.put(pattern.Type__c, new List<List<String>>());
            }
            
            
            if (pattern.IdList__c==null){
                List<String> newItems = constructReplacementItems (pattern.MatchPattern__c, pattern.ReplacementPattern__c, null);
                
                System.debug(
                    '#### Type [' + pattern.Type__c +  '],' + 
                    'Old Replacement Item [' + newItems.get(0) + '],' + 
                    'New Replacement Item [' + newItems.get(1) + '].'
                    );  
                    
                replacementItemsMap.get(pattern.Type__c).add(newItems);
                continue;
            }
                
            String[] idList = pattern.IdList__c.split(',');
            
            for (String id: idList){
                
                List<String> newItems = constructReplacementItems (pattern.MatchPattern__c, pattern.ReplacementPattern__c, id);
                
                System.debug(
                    '#### Type [' + pattern.Type__c +  '],' + 
                    'Old Replacement Item [' + newItems.get(0) + '],' + 
                    'New Replacement Item [' + newItems.get(1) + '].'
                    );  
        
                replacementItemsMap.get(pattern.Type__c).add(newItems);
                
            }
            
                
        }
    
    }
    
    //retrieve some info: orgId, server url, server content url for both prod and current sandbox
    private void retrieveConfigInfo(){
    
        currentOrgId = UserInfo.getOrganizationId();
        currentServerURL = URL.getSalesforceBaseUrl().toExternalForm();
        currentServerContentURL = getCurrentServerContentURL();
        
        prodOrgId = Label.ProdOrgId;
        prodServerURL = Label.ProdServerURL;
        
        System.debug(
            '#########################################################' + 
            '\n#### Retrieving Info : ' + 
            '\n#### Current Org Id : ' + currentOrgId  + 
            '\n#### Current Server URL : ' + currentServerURL + 
            '\n#### Current Server Content URL : ' + currentServerContentURL  + 
            '\n#### Prod Org Id : ' + prodOrgId + 
            '\n#### Prod Server URL : ' + prodServerURL + 
            '\n#########################################################'
        );
    
    }
    
    //(convention of term in this class : server content url) construct server url in format eg: http://c.cs1.content.force.com
    private String getCurrentServerContentURL(){
        String host = URL.getSalesforceBaseUrl().getHost();
        return 'https://c.' + host.substring(0, host.indexOf('.')) + '.content.force.com';
    }
   
    //replace server url for a string 
    private String replaceServerURL(String targetStr){
        return targetStr.replaceAll(prodServerURL, currentServerURL);
    }
    
    private void handleError(Exception e){                
      
        System.debug('### Error : ' + e);
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Error Message: ' + e.getMessage());
          
    }    
    
    //custom exception defined if the document has invalid UTF format
    public class InvalidUTF8FormatForDocumentBodyException extends Exception {}
         
    //custom exception defined if the environment is production 
    public class ForbiddenEnvironmentException extends Exception {}     
    
}
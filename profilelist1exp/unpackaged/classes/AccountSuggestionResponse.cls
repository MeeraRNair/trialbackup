public class AccountSuggestionResponse{
/*
 * Author   : Niveda
 * Purpose  : This is class to handle responses from AccountSuggestionIntegration class
 *
*/
    public final static String SANDBOX = 'Sandbox';
    public final static string START_TAG= 'dell';
    public final static string START_URL= 'http://schemas.xmlsoap.org/soap/envelope/';
    public final static string ENV_URL =  'http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Request';
    public final static string NAMESPACE_URL ='https://soagw-dmznonprod.ins.dell.com';
    public final static string RESPONSE_NAMESPACE_URL ='http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response';
    
    public string Error;
    public string SuggestionID;
    public string ID;
    public string ErrorDesc;
    public list<accountObject> accList{get; set;}


public class accountObject{
    public string accountId{get; set;}
    public string accountName{get; set;}
    public string accountType{get; set;}
    public string city{get; set;}
    public string country{get; set;}
    public string dmu{get; set;}
    public string oob{get; set;}
    public string postalCode{get; set;}
    public string state{get; set;}

}

 //logic to parse response xml
    public static  AccountSuggestionResponse parseResponseString(String responseString){
        AccountSuggestionResponse result = new AccountSuggestionResponse();
        if(StringUtils.isNotBlank(responseString)){
            DOM.Document doc = new DOM.Document();
            doc.load(responseString); 
            list<dom.XmlNode> Body = doc.getRootElement().getChildElement('Body',START_URL).getChildElements();
            list<dom.XmlNode> AccountResult = new list<dom.XmlNode>();
            list<dom.XmlNode> CommonSearchResponse = new list<dom.XmlNode>();
            list<dom.XmlNode> CommonSearchResponseObj = new list<dom.XmlNode>();
            //Case 1 : to find if there are any random errors/ data integrity errors
            for(Dom.XmlNode child:body){
                if(child.getName() == 'fault'){
                 result= parseResponseString(responseString, result);
                }
                else if(child.getName() == 'UpdateAccountResponse'){
                 accountResult = child.getChildElement('UpdateAccountResult','CIL').getChildElements();   
                }
                else 
                 accountResult = child.getChildElement('CreateAccountResult','CIL').getChildElements();                   
            }
            for(Dom.XmlNode child:accountResult){
            
                if(child.getName() == 'MDMError')
                 result= parseResponseString(responseString, result);

               else if(child.getName() == 'CommonSearchResponse'){
                     CommonSearchResponse = child.getChildElements();
                     CommonSearchResponseObj= child.getChildElement('CommonSearchResponseBObj',RESPONSE_NAMESPACE_URL).getChildElements();
                  
               }   
            }
            //Case 2: Parse Validation errors from affinity. Case 3: No duplicates , get Suggestion Id from affinity
            for(Dom.XmlNode child:CommonSearchResponseObj){
            
               if (StringUtils.equalsIgnoreCase(child.getName(),'Error')){
                       result.Error = child.getText().trim();
                }
                else if (StringUtils.equalsIgnoreCase(child.getName(),'SuggestionId')) { 
                  result.SuggestionId =  child.getText().trim();
                }
                else if(StringUtils.equalsIgnoreCase(child.getName(),'AccountId')){
                 parseDuplicates(CommonSearchResponse, result);
                 
                }
                
            }
            
        }  
        return result ;     
    }
    
    //Case 4 : Get list of duplicates from affinity
    public static void parseDuplicates(list<dom.XmlNode> searchResponse, AccountSuggestionResponse result){
        list<AccountSuggestionResponse.accountObject> reports = new list<AccountSuggestionResponse.accountObject>();
        for (Dom.XMLNode child : searchResponse) {
            if (child.getName() == 'CommonSearchResponseBObj') {
                AccountSuggestionResponse.accountObject accountObject = new AccountSuggestionResponse.accountObject();
                parseReport(child, accountObject);
                reports.add(accountObject);
                if(reports.size() >= 1000) {
                    break;
                }
            }
        }
        result.accList = reports;
    }
    
    //Parse duplicate records from case 4
    public static void parseReport(DOM.XMLNode node, AccountSuggestionResponse.accountObject accountObject) {
        for (Dom.XMLNode child : node.getChildElements()) {
            if (StringUtils.equalsIgnoreCase(child.getName(),'AccountId')){
               accountObject.accountId  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'accountName')){
               accountObject.accountName  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'accountType')){
               accountObject.accountType  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'city')){
               accountObject.city  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'country')){
               accountObject.country  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'dmu')){
               accountObject.dmu  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'oob')){
               accountObject.oob  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'postalCode')){
               accountObject.postalCode  = child.getText().trim();
            }
            else if (StringUtils.equalsIgnoreCase(child.getName(),'state')){
               accountObject.state  = child.getText().trim();
            }
        }
    }
    
    //Parse faultString from Case 1
     public static AccountSuggestionResponse parseResponseString(String responseString, AccountSuggestionResponse result) {

        if(StringUtils.isNotBlank(responseString)){        
            XmlStreamReader responseXMLreader = new XmlStreamReader(responseString);
            String currentElement;
            while(responseXMLreader.hasNext() && responseString != '') {
    
                if (responseXMLreader.getEventType() == XmlTag.START_ELEMENT) {
                    currentElement = responseXMLreader.getLocalName();
                }       
                else if (responseXMLreader.getEventType() == XmlTag.CHARACTERS){
                    
                    //assigns to different class variables
                    if (StringUtils.equalsIgnoreCase(currentElement,'faultstring')){
                        result.Error = responseXMLreader.getText();
                    }
                    else if (StringUtils.equalsIgnoreCase(currentElement,'Message')){
                        result.Error = responseXMLreader.getText();
                    }
                }                       
                responseXMLreader.next();
            }//end of while loop
        }//end of If    

        return result;      
    }//end of method



}
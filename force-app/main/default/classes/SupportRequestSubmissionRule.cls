/*
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      Dec-2012       Satya          Created for CR7667 - Enforce the rule of Support Request Submission Rules
2.0      05-Mar-2013    Jessie         Updated for Defect - Include conversion of unweighted rev - services only before doing checking.
*/
public class SupportRequestSubmissionRule{  

    Map<String, Support_Request_Submission_Rule__c> supportRequestSubmissionRuleMap;
    
    //v2.0 - start
    private Map<string,Double> currencyConvMap;
    //v2.0 - end
    
    public void initialize(){
        supportRequestSubmissionRuleMap = new Map<String, Support_Request_Submission_Rule__c>();    
        List<Support_Request_Submission_Rule__c> supportRequestSubmissionRules = [Select Resource_Type__c, Condition__c, Stage__c, Unweighted_Rev_Services_Only__c, CurrencyIsoCode
                                                    From Support_Request_Submission_Rule__c order by CreatedDate Desc];
       
        System.debug('### supportRequestSubmissionRules : ' + supportRequestSubmissionRules );
        //only first rule of the resource type will be used, which means any extra rule for same resource type will be ignored.
        for(Support_Request_Submission_Rule__c rule: supportRequestSubmissionRules ){  
            if(!supportRequestSubmissionRuleMap.containsKey(rule.Resource_Type__c)){
                supportRequestSubmissionRuleMap.put(rule.Resource_Type__c, rule);            
         }
       }
       
       //v2.0 - start
       currencyConvMap = CurrencyUtils.getCurrencyConversionMap();
       //v2.0 - end
    }
    
    //v2.0 - start
    private Double getConvertedCurrencyInUSD (string isoCode , Double value){
        Double valueInUSD = 0;
        //Map<string,Double> currencyConvMap = getCurrencyConversionMap();
        if(currencyConvMap.containsKey(isoCode)){
            valueInUSD = value/currencyConvMap.get(isoCode);
        }
        
        System.debug('### value in USD : '+ valueInUSD);
        
        return valueInUSD;
    }
    //v2.0 - end 
    
    /* 
    public boolean isValid(String resourceType, Support_Request__c SR){
        
       Support_Request_Submission_Rule__c SRRule = supportRequestSubmissionRuleMap.get(resourceType);
        
       if(SRRule == null){
           System.debug('### Rule ' + resourceType + ' doesnt exist');
           return true;
       }
       
       System.debug('### cond: '+ SRRule.Condition__c + ', SR value: '+ SR.Unweighted_Rev_Services_Only__c + ', SRRule value : '+ SRRule.Unweighted_Rev_Services_Only__c ); 
                  
       if(SRRule.Condition__c == '<' && !(SR.Unweighted_Rev_Services_Only__c < SRRule.Unweighted_Rev_Services_Only__c)){
           System.debug('### SR doesnt meet Rule ' + resourceType + '('+ SRRule.Condition__c + ')');
           return false;
       }
       
       if(SRRule.Condition__c == '>' && !(SR.Unweighted_Rev_Services_Only__c > SRRule.Unweighted_Rev_Services_Only__c)){
           System.debug('### SR doesnt meet Rule ' + resourceType + '(cond: '+ SRRule.Condition__c + ', SR value: '+ SR.Unweighted_Rev_Services_Only__c + ', SRRule value : '+ SRRule.Unweighted_Rev_Services_Only__c + '), result: ' + (SR.Unweighted_Rev_Services_Only__c > SRRule.Unweighted_Rev_Services_Only__c)); 
           return false;
       }
       
       if(SRRule.Condition__c == '<=' && !(SR.Unweighted_Rev_Services_Only__c <= SRRule.Unweighted_Rev_Services_Only__c)){
            System.debug('### SR doesnt meet Rule ' + resourceType + '('+ SRRule.Condition__c + ')'); 
            return false;
       }
       
       if(SRRule.Condition__c == '>=' && !(SR.Unweighted_Rev_Services_Only__c >= SRRule.Unweighted_Rev_Services_Only__c)){
           System.debug('### SR doesnt meet Rule ' + resourceType + '('+ SRRule.Condition__c + ')'); 
            return false;
       }
        
        if(!SRRule.Stage__c.Contains(SR.Stage__c)){
            System.debug('### SR doesnt meet Rule ' + resourceType + '('+ SRRule.Stage__c + ')'); 
            return false;
        }
        
        System.debug('### SR meets Rule ' + resourceType); 
        return true;
        
    }
    */
    
    //v.0 - start
    public boolean isValid(String resourceType, Support_Request__c SR){
        
       Support_Request_Submission_Rule__c SRRule = supportRequestSubmissionRuleMap.get(resourceType);
        
       if(SRRule == null){
           System.debug('### Rule ' + resourceType + ' doesnt exist');
           return true;
       }
       
       System.debug('### SR stage: ' + SR.Stage__c + ', SR unweighted Rev -Serv only: '+ SR.Unweighted_Rev_Services_Only__c + ', SR currency : ' + SR.CurrencyIsoCode + ', cond: '+ SRRule.Condition__c + ', SRRule stage: ' + SRRule.Stage__c +  ', SRRule unweighted Rev - Serv Only: '+ SRRule.Unweighted_Rev_Services_Only__c + ', SR currency : ' + SR.CurrencyIsoCode); 
                  
       if(SRRule.Condition__c == '<' && !(getConvertedCurrencyInUSD (SR.CurrencyIsoCode, SR.Unweighted_Rev_Services_Only__c.doubleValue()) < getConvertedCurrencyInUSD (SRRule.CurrencyIsoCode, SRRule.Unweighted_Rev_Services_Only__c.doubleValue()))){
           System.debug('### SR doesnt meet Rule ' + resourceType);
           return false;
       }
       
       if(SRRule.Condition__c == '>' && !(getConvertedCurrencyInUSD (SR.CurrencyIsoCode, SR.Unweighted_Rev_Services_Only__c.doubleValue()) > getConvertedCurrencyInUSD (SRRule.CurrencyIsoCode, SRRule.Unweighted_Rev_Services_Only__c.doubleValue()))){
           System.debug('### SR doesnt meet Rule ' + resourceType);
           return false;
       }
       
       if(SRRule.Condition__c == '<=' && !(getConvertedCurrencyInUSD (SR.CurrencyIsoCode, SR.Unweighted_Rev_Services_Only__c.doubleValue()) <= getConvertedCurrencyInUSD (SRRule.CurrencyIsoCode, SRRule.Unweighted_Rev_Services_Only__c.doubleValue()))){
           System.debug('### SR doesnt meet Rule ' + resourceType);
           return false;
       }
       
       if(SRRule.Condition__c == '>=' && !(getConvertedCurrencyInUSD (SR.CurrencyIsoCode, SR.Unweighted_Rev_Services_Only__c.doubleValue()) >= getConvertedCurrencyInUSD (SRRule.CurrencyIsoCode, SRRule.Unweighted_Rev_Services_Only__c.doubleValue()))){
           System.debug('### SR doesnt meet Rule ' + resourceType);
           return false;
       }
        
        if(!SRRule.Stage__c.Contains(SR.Stage__c)){
            System.debug('### SR doesnt meet Rule ' + resourceType); 
            return false;
        }
        
        System.debug('### SR meets Rule ' + resourceType); 
        return true;
        
    }
    //v2.0 - end  
   
    public String constructErrorMessage(String resourceType){
        
        Support_Request_Submission_Rule__c SRRule = supportRequestSubmissionRuleMap.get(resourceType);
        
        if(SRRule==null)
           return '';
        List<String> args = new String[]{'0','number','###,###,##0'}; 
        String s = String.format(SRRule.Unweighted_Rev_Services_Only__c.format(), args); 
           
        /*return 'In order for a ' + resourceType  + ' Resource to be assigned your Opportunity has to have: '+'<br/>' +
                'Services Products selected that have an Unweighted Revenue' + SRRule.Condition__c + 
                '$' + SRRule.Unweighted_Rev_Services_Only__c  + ' &'+'<br/>'+' Opportunity Stage of ' + SRRule.Stage__c;*/

        return 'In order for a ' + resourceType  + ' Resource to be assigned your Opportunity has to have: '+'<br/>' +
                'Services Products selected that have an Unweighted Revenue' + SRRule.Condition__c + 
                '$' + s + ' &'+'<br/>'+' Opportunity Stage of ' + SRRule.Stage__c;
    } 


}
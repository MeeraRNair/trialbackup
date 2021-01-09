/*====================================================================================================================+
 |  HISTORY |                                                                 
 |                                                                           
 | DATE         DEVELOPER              Story           DESCRIPTION                               
 | ===========  =========           =========          =========== 
 | 17-Aug-2018  Rajesh Ch             5377640           Initial creation. This class is used to send the Opp details to DFS
 +====================================================================================================================*/

public class DFS_CreateLeadServices {

@InvocableMethod
public static void callDFS(List<ID> listOpps){
List<Opportunity> lstOpps = [SELECT Name,Deal_ID__c,StageName,Probability, Owner.Name,
                                Quest_Software_Contact__r.FirstName,Quest_Software_Contact__r.LastName,
                                Quest_Software_Contact__r.Phone,Quest_Software_Contact__r.MobilePhone,
                                Quest_Software_Contact__r.Email,
                                Account.Name,Account.Account_Country__c,Account.Account_ID__c, Account.Account_Classification__c
                                FROM Opportunity Where DFS_Engaged__c=True AND ID IN : listOpps];
                                
    if(lstOpps.size() > 0)
    {
        envokeDFS(listOpps);
    }
}

//Callout methods to get Access token,access class methods
@future(callout=true)
public static void envokeDFS(List<ID> listOpps){    
                                
    List<Utility_Settings__mdt> lstUtility =[select MasterLabel,DeveloperName,Value__c from Utility_Settings__mdt where MasterLabel='Opp Sync To DFS'];
    
    Map<String,String> mapUtility = new Map<String,String>();
    for (Utility_Settings__mdt utlty : lstUtility) 
    {
        mapUtility.put(utlty.DeveloperName, utlty.value__c);        
    }
        /*string clientID = '3MVG9dPGzpc3kWyfNK32CStXEjVZac3P61hbiW0TLmYRZ3WNJ9b75FdNA24YzmVZCI.iUNNB8gKa0bufQiJv9';
        string secretKey = '4001569762859508195';
        string endPointURL;
        String username = 'boomi_user@dell.com.dfs.fy1905';
        String password = 'Password01!0G7NfmgVkzT34LaEs5WgaPyd';  */
    if( mapUtility.get('toggleCallDFS') == 'On')
    {   
    
        List<Opportunity> lstOpps = [SELECT Name,Deal_ID__c,StageName,Probability, Owner.Name,
                                Quest_Software_Contact__r.FirstName,Quest_Software_Contact__r.LastName,
                                Quest_Software_Contact__r.Phone,Quest_Software_Contact__r.MobilePhone,
                                Quest_Software_Contact__r.Email,
                                Account.Name,Account.Account_Country__c,Account.Account_ID__c, Account.Account_Classification__c
                                FROM Opportunity Where DFS_Engaged__c=True AND ID IN : listOpps];
                                
        string clientID = mapUtility.get('clientID');
        string secretKey = mapUtility.get('secretKey');
        string endPointURL;
        String username = mapUtility.get('userName');
        String password = mapUtility.get('pwd');      
    
            Set<ID> setAccountIDs = new Set<ID>();
            for(Opportunity o : lstOpps)
            {
                setAccountIDs.add(o.AccountID);
            }
            
            List<AccountTeamMember> lstAccountTeamMember = [SELECT TeamMemberRole,User.Email, Title,AccountId FROM AccountTeamMember WHERE AccountId IN : setAccountIDs ORDER BY CreatedDate DESC ];
            
            Map<ID, List<AccountTeamMember>> mapAccountTeamMember = new Map<ID, List<AccountTeamMember>>();
            List<AccountTeamMember> lstAccountTeamMember_map;
            
            for(AccountTeamMember atm :   lstAccountTeamMember)
            {
                if(mapAccountTeamMember.containsKey(atm.AccountID) == false)
                {
                    lstAccountTeamMember_map = new List<AccountTeamMember>();
                    lstAccountTeamMember_map.add(atm);
                    mapAccountTeamMember.put(atm.AccountID, lstAccountTeamMember_map);
                }
                else
                {
                    lstAccountTeamMember_map = mapAccountTeamMember.get(atm.AccountID);
                    lstAccountTeamMember_map.add(atm);
                    mapAccountTeamMember.put(atm.AccountID, lstAccountTeamMember_map);
                }
            }
            
            
            //REST Request String Formation
            String strMainRESTRequest_start = '{"OpportunityList":[';
            String strMainRESTRequest_end = ']}';
            String strMainRESTRequest_body = '';
            String strOppNameId = '';
            
            for( Opportunity op : lstOpps)
            {
                strOppNameId += 'Opp Name: ' + op.Name + ', SFId: ' + op.Id + ', ';
                strMainRESTRequest_body += '{';
                strMainRESTRequest_body += '"AccountTeamMembers" : [';
                
                lstAccountTeamMember_map = mapAccountTeamMember.get(op.AccountID);
                for(AccountTeamMember at : lstAccountTeamMember_map)
                {
                    strMainRESTRequest_body += '{';
                    strMainRESTRequest_body += '"Email": "' + at.User.Email + '",';
                    strMainRESTRequest_body += '"Title": "' + at.Title + '"';
                    strMainRESTRequest_body += '},';            
                }
                strMainRESTRequest_body  = strMainRESTRequest_body.removeEnd(','); 
                strMainRESTRequest_body += '],';       
                
                strMainRESTRequest_body += '"AccountName" : "' + op.Account.Name + '",';
                strMainRESTRequest_body += '"AccountClassification" : "' + op.Account.Account_Classification__c + '",';
                strMainRESTRequest_body += '"Country" : "' + op.Account.Account_Country__c + '",';
                strMainRESTRequest_body += '"AffinityAccountId" : "' + op.Account.Account_ID__c + '",';
                
                strMainRESTRequest_body += '"OpportunityStageName" : "' + op.StageName + '",';
                strMainRESTRequest_body += '"OpportunityProbability" : ' + (op.Probability/100) + ',';
                strMainRESTRequest_body += '"DellDealID" : "' + op.Deal_ID__c + '",';
                strMainRESTRequest_body += '"OwnerUserName" : "' + op.Owner.Name + '",';
                strMainRESTRequest_body += '"ContactFirstName" : "' + op.Quest_Software_Contact__r.FirstName + '",';
                strMainRESTRequest_body += '"ContactLastName" : "' + op.Quest_Software_Contact__r.LastName + '",';
                strMainRESTRequest_body += '"ContactPhone" : "' + op.Quest_Software_Contact__r.Phone + '",';
                strMainRESTRequest_body += '"ContactMobile" : "' + op.Quest_Software_Contact__r.MobilePhone + '",';
                strMainRESTRequest_body += '"ContactEmail" : "' + op.Quest_Software_Contact__r.Email + '"';
                
                strMainRESTRequest_body += '},';
                
            }
            strOppNameId = strOppNameId.removeEnd(', ');
            strMainRESTRequest_body  = strMainRESTRequest_body.removeEnd(',');
            strMainRESTRequest_body  = strMainRESTRequest_start + strMainRESTRequest_body  + strMainRESTRequest_end;
            
            String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+secretKey+'&username='+username+'&password='+password;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setBody(reqbody);
            req.setMethod('POST');
            req.setEndpoint(mapUtility.get('tokenEP'));  //'https://test.salesforce.com/services/oauth2/token'
            HttpResponse httpRes;
            OAuth2 objAuthenticationInfo;
            
            if ( !Test.isRunningTest() )
            {
                httpRes = h.send(req);
                
                //check body Outh2.0 and get the access token
                objAuthenticationInfo = (OAuth2)JSON.deserialize(httpRes.getbody(), OAuth2.class);
            }
            
            
           String strErrorMessage = '';
           Integer iStatusCode;
           Http h2 = new Http();
           HttpRequest req1 = new HttpRequest();
           
           req1.setHeader('Content-Type','application/json');
           req1.setHeader('accept','application/json');
               
            if(objAuthenticationInfo != null && objAuthenticationInfo.access_token!=null)
            {        
               req1.setHeader('Authorization','Bearer ' + objAuthenticationInfo.access_token);
            }
            
            String endPoint = mapUtility.get('DFS_EP'); //'https://dfs--FY1905.cs15.my.salesforce.com/services/apexrest/CreateLead';
            req1.setBody(strMainRESTRequest_body);
            req1.setMethod('POST');
            req1.setEndpoint(endPoint);
            HttpResponse resObj; 
            string[] to;  //rajesh_chennupati@dell.com
               
           try 
            {  
               if ( !Test.isRunningTest() )
               {
                   resObj = h2.send(req1);               
                   system.debug('RESPONSE FROM API: '+resObj.getBody());           
                   iStatusCode=resObj.getStatusCode();                
               }
            }
            catch(Exception expObj) 
            {
                //your exception logic        
                system.debug('DFS_CreateLeadServices-failure @Catch');
                strErrorMessage = 'DFS_CreateLeadServices-failure @Catch';
            }
            
            if( mapUtility.get('toggleSendEmail') == 'On')
            { 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                if(iStatusCode == 200)
                {
                    email.setSubject('Dell Main-DFS Lead Created Successfully');
                    to = mapUtility.get('successEmail').split(',');
                    system.debug('Success; Status Code='  + String.valueOf(iStatusCode ) + '; Status=' + (resObj == null ? '' :  resObj.getStatus())); 
                }
                else //iStatusCode==400 || iStatusCode==401 || iStatusCode==402 || iStatusCode==403 || iStatusCode==404
                {
                     email.setSubject('Dell Main-DFS Lead Creation failed');   
                     to = mapUtility.get('failEmail').split(',');                   
                     system.debug('Failure; Status Code='  + String.valueOf(iStatusCode ) + '; Status=' + (resObj == null ? '' :  resObj.getStatus()));
                     strErrorMessage = 'DFS_CreateLeadServices-Failure; Status Code='  + String.valueOf(iStatusCode ) + '; Status=' + (resObj == null ? '' :  resObj.getStatus());      
                }                
                
                email.setToAddresses(to);                 
                email.setHtmlBody('Hello, <br/><br/>The below are opportunities. <br/>' +
                            '<br/>' + 'Status Code=' + iStatusCode +
                            '<br/>' + strOppNameId);
                try
                {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
                catch(exception e)
                {
                    system.debug('DFS_CreateLeadServices-failure @sending email');
                }
            }
    }    
    
}

public class OAuth2
{
  public String id;
  public String access_token;
} 
}
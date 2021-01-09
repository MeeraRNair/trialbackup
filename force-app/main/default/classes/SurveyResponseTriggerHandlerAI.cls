public class SurveyResponseTriggerHandlerAI
{
    public static void afterInsert(List<MaritzCX__Survey_Response__c> listNew,Map<Id,sObject> mapNew)
    {
        Set<Id> setOfSurveyId = new Set<Id>();
        Map<Id,sObject> mapNewResponse = new Map<Id,sObject>();
        Map<Object,Object> mapOfResponseForCase = new Map<Object,Object>();
        for(sObject obj:mapNew.values())
        {
            MaritzCX__Survey_Response__c res = (MaritzCX__Survey_Response__c)obj;
            mapNewResponse.put(obj.Id,res);
        }
        
        for(MaritzCX__Survey_Response__c res:listNew)
        {
            setOfSurveyId.add(res.MaritzCX__Survey_Id__c);
        }
        
        Map<Object,Object> mapOfNpsMapping = SurveyResponseHandlersUtilityClass.getMapping();
        Map<Object,Object> mapOfMatrix = SurveyResponseHandlersUtilityClass.getMatrix(mapOfNpsMapping);
        Map<Object,Object> mapOfResponses = getResponses(mapNewResponse,mapOfNpsMapping,mapOfMatrix);
        Map<Object,Object> mapOfOwners = SurveyResponseHandlersUtilityClass.getCaseOwners(mapOfNpsMapping,mapOfMatrix,mapNewResponse.values());
        Map<Object,Object> mapOfSourceTarget = (Map<Object,Object>)mapOfNpsMapping.get('Case Creation');
        Map<Object,Object> mapOfMatrixKey = (Map<Object,Object>)mapOfMatrix.get('Case Creation');
        Map<Object,Object> mapOfValidation = (Map<Object,Object>)mapOfNpsMapping.get('Validation');
        System.debug('###Map Responses:'+mapOfResponses);
        for(Object obj:mapOfResponses.keyset())
        {
            if(mapOfSourceTarget.size() > 0)
            {
                Map<String,Object> mapOfResFields = (Map<String,Object>)mapOfResponses.get(obj);
                Set<Object> setOfSource = (Set<Object>)mapOfSourceTarget.keyset();
                List<Object> listOfSource = new List<Object>();
                listOfSource.addAll(setOfSource);
                System.debug('Set:'+listOfSource);
                String strSource = (String)listOfSource.get(0);
                List<String> listSourceSplit = strSource.split(',');
                String strKey = '';
                for(String str:listSourceSplit)
                {
                   String strSourceVal = (String)mapOfValidation.get(str);
                   String strVal = String.valueOf(mapOfResFields.get(strSourceVal));
				   if(isNumeric(strVal))
				   {
					   Decimal dcStr = Decimal.valueOf(strVal);
					   strVal = String.valueOf(dcStr.intValue());
				   }
                   strKey += strVal;
                }
                strKey = strKey.toLowerCase();
				System.debug('Key Str:'+strKey);
                if(mapOfMatrixKey.containsKey(strKey))
                {
                    mapOfResponseForCase.put(obj,mapOfResponses.get(obj));
                }
            }
        }
        if(mapOfResponseForCase.size() > 0)
        {
            createCase(mapOfResponseForCase,mapOfNpsMapping,mapOfMatrix,mapOfOwners);
        }
        
    }
    
    /*Getting responses from MaritzCX Reponse which have been sent from Maritz app.
    Returns Map with Key as survey response id and value as Map with key as field names of Maritz Survey Response object and value as field values.
    */
    public static Map<Object,Object> getResponses(Map<Id,sObject> mapNewResponse,Map<Object,Object> mapOfNpsMapping,Map<Object,Object> mapOfMatrix)
    {
        Map<Object,Object> mapOfResponses = new Map<Object,Object>();
        for(String str:mapNewResponse.keyset())
        {
            MaritzCX__Survey_Response__c res = (MaritzCX__Survey_Response__c)mapNewResponse.get(str);
            Map<String,Object> mapOfSR = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(res));
            mapOfResponses.put(str,mapOfSR);
        } 
        return mapOfResponses;
    }
    
    public static void createCase(Map<Object,Object> mapOfResponseForCase,Map<Object,Object> mapOfNpsMapping,Map<Object,Object> mapOfMatrix,Map<Object,Object> mapOfOwners)
    {
        Map<Object,Object> mapOfFieldMapping = (Map<Object,Object>)mapOfNpsMapping.get('Case Mapping');
        Map<Object,Object> mapOfMatrixKey = (Map<Object,Object>)mapOfMatrix.get('Case Creation'); 
        Map<Object,Object> mapOfOwnerMatrix = (Map<Object,Object>)mapOfMatrix.get('Case Owner');
        Map<Object,Object> mapOfOwnerMapping = (Map<Object,Object>)mapOfNpsMapping.get('Case Owner');
        Map<Object,Object> mapOfOwnerTierMatrix = (Map<Object,Object>)mapOfMatrix.get('Case Owner Tier');
        Map<Object,Object> mapOfOwnerTierMapping = (Map<Object,Object>)mapOfNpsMapping.get('Case Owner Tier');
        Map<Object,Object> mapOfValidation = (Map<Object,Object>)mapOfNpsMapping.get('Validation');
        Map<String,User> mapOfUser = getAccountOwners(mapOfResponseForCase);
        Map<Object,Object> mapOfCaseMapping = new Map<Object,Object>();
        Map<Object,Object> mapOfMappingToCase = new Map<Object,Object>();
        List<sObject> listOfCase = new List<sObject>();
        for(Object obj:mapOfFieldMapping.keyset())
        {
            String strKey = (String)obj;
            String strVal = (String)mapOfFieldMapping.get(obj);
            if(strKey.substringBefore('.').equals('MaritzCX__Survey_Response__c') && strVal.substringBefore('.').equals('Case'))
            {
                mapOfCaseMapping.put(strKey.substringAfter('.'),strVal.substringAfter('.'));
            }
            else if(strKey.substringBefore('.').equals('NPS_Matrix__c') && strVal.substringBefore('.').equals('Case'))
            {
                mapOfMappingToCase.put(strKey.substringAfter('.'),strVal.substringAfter('.'));
            }
        }
        
		Schema.SObjectType st;
		Sobject sObjectCase;
        for(Object obj:mapOfResponseForCase.keyset())
        {
            Map<String,Object> mapOfResponseFields = (Map<String,Object>)mapOfResponseForCase.get(obj);
            Map<String,Object> mapOfMatrixFields;
            User us;
            
            Set<Object> setOfTierSource = (Set<Object>)mapOfOwnerTierMapping.keyset();
            List<Object> listOfTierSource = new List<Object>();
            listOfTierSource.addAll(setOfTierSource);
            System.debug('Set:'+listOfTierSource);
            String strTierSource = (String)listOfTierSource.get(0);
            List<String> listTierSourceSplit = strTierSource.split(',');
            String strKey = '';
            for(String str:listTierSourceSplit)
            {
                    String strTierStr = (String)mapOfValidation.get(str);
                    if(mapOfResponseFields.get(strTierStr) != null)
                    {
                        Object objVal = mapOfResponseFields.get(strTierStr);
                        strKey += objVal;
                    }
                    
            }
            strKey = strKey.toLowerCase();
            if(mapOfOwnerTierMatrix.containsKey(strKey))
            {
                mapOfMatrixFields = (Map<String,Object>)mapOfOwnerTierMatrix.get(strKey);
            }
            else
            {
                Set<Object> setOfSource = (Set<Object>)mapOfOwnerMapping.keyset();
                List<Object> listOfSource = new List<Object>();
                listOfSource.addAll(setOfSource);
                System.debug('Set:'+listOfSource);
                String strSource = (String)listOfSource.get(0);
                List<String> listSourceSplit = strSource.split(',');
                strKey = '';
                for(String str:listSourceSplit)
                {
                        String strSourceStr = (String)mapOfValidation.get(str);
                        if(mapOfResponseFields.get(strSourceStr) != null)
                        {
                            Object objVal = mapOfResponseFields.get(strSourceStr);
                            strKey += objVal;
                        }
                        
                }
                strKey = strKey.toLowerCase();
                mapOfMatrixFields = (Map<String,Object>)mapOfOwnerMatrix.get(strKey);
            }
            if(mapOfMatrixFields != null)
            {
                if(mapOfMatrixFields.get('Account_Team_Role_1__c') != null)
                {
                    System.debug('Inside if 1');
                    Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
                    if(mapObj != null)
                    {
                        us = (User)mapObj.get(mapOfMatrixFields.get('Account_Team_Role_1__c'));
                    }
                }
                System.debug('###User 1:'+us);
                if(mapOfMatrixFields.get('Account_Team_Role_2__c') != null && us == null)
                {
                    System.debug('Inside if 2');
                    Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
                    if(mapObj != null)
                    {
                        us = (User)mapObj.get(mapOfMatrixFields.get('Account_Team_Role_2__c'));
                    }
                }
                System.debug('###User 2:'+us);
                if(mapOfMatrixFields.get('Account_Team_Role_3__c') != null && us == null)
                {
                    System.debug('Inside if 3');
                    Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
                    if(mapObj != null)
                    {
                        us = (User)mapObj.get(mapOfMatrixFields.get('Account_Team_Role_3__c'));
                    }
                }
                System.debug('###User 3:'+us);
                if(mapOfMatrixFields.get('Account_Team_Role_4__c') != null && us == null)
                {
                    System.debug('Inside if 4');
                    Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
                    if(mapObj != null)
                    {
                        us = (User)mapObj.get(mapOfMatrixFields.get('Account_Team_Role_4__c'));
                    }
                }
                System.debug('###User 4:'+us);
                if(mapOfMatrixFields.get('Account_Team_Role_5__c') != null && us == null)
                {
                    System.debug('Inside if 5');
                    Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
                    if(mapObj != null)
                    {
                        us = us = (User)mapObj.get(mapOfMatrixFields.get('Account_Team_Role_5__c'));
                    }
                }
                System.debug('###User 5:'+us);
                if(us == null)
                {
                    us = (User)mapOfUser.get((String)mapOfResponseFields.get('MaritzCX__Account__c'));
                }
                   
				st = Schema.getGlobalDescribe().get('Case'); 
				sObjectCase = st.newSobject();
				for(Object obj1:mapOfCaseMapping.keyset())
				{
					sObjectCase.put((String)mapOfCaseMapping.get(obj1),mapOfResponseFields.get((String)obj1));
				}
				for(Object obj1:mapOfMappingToCase.keyset())
				{
					String str = (String)obj1;
					System.debug('Str:'+str);
					System.debug('Map###:'+mapOfMatrixFields);
					System.debug('Map Owners###:'+mapOfOwners);
					if(str.contains('Additional_Recipient') && mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c')) != null)
					{
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfOwners.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						User userRecipient = (User)mapObj.get(mapOfMatrixFields.get(str));
						if(userRecipient != null)
						{
							sObjectCase.put((String)mapOfMappingToCase.get(obj1),userRecipient.Email);
						}
					}
					else if(!str.contains('Additional_Recipient'))
					{
						sObjectCase.put((String)mapOfMappingToCase.get(obj1),mapOfMatrixFields.get((String)obj1));
					}
				}
				System.debug('User:'+us);
				sObjectCase.put('OwnerId',us.Id);
				sObjectCase.put('Description','NPS Recommend question, scale from 0-10 : 0=Not at all likely to recommend Dell, 10=Extremely likely to recommend Dell; Other Rate Experience questions, scale from 1-10 : 1=Poor, 10=Excellent');
				sObjectCase.put('Subject','Detractor Alert - NPS Survey('+(mapOfResponseFields.get((String)mapOfValidation.get('Segment__c')))+')');
				Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NPS Cases').getRecordTypeId();
				sObjectCase.put('RecordTypeId',devRecordTypeId);
				sObjectCase.put('Priority','Normal');
				listOfCase.add(sObjectCase);
			}
		}
		if(listOfCase.size() > 0)
		{
			insert listOfCase;
		}
		
    }
    
    
    
    public static Map<String,User> getAccountOwners(Map<Object,Object> mapOfResponses)
    {
        List<String> listOfAccountId = new List<String>();
        List<String> listOfOwnerId = new List<String>();
        Map<String,User> mapOfUsersWithAccount = new Map<String,User>(); 
        for(Object obj:mapOfResponses.keyset())
        {
            Map<String,Object> mapOfResponseFields = (Map<String,Object>)mapOfResponses.get(obj);
            listOfAccountId.add((String)mapOfResponseFields.get('MaritzCX__Account__c'));
        }
        List<Account> listOfAccounts = new List<Account>([Select OwnerId from Account where Id IN: listOfAccountId]);
        for(Account acc:listOfAccounts)
        {
            listOfOwnerId.add(acc.OwnerId);
        }
        Map<String,User> mapOfUser = new Map<String,User>([Select Id from User where Id IN: listOfOwnerId]);
        for(Account acc:listOfAccounts)
        {
            mapOfUsersWithAccount.put(acc.Id,mapOfUser.get(acc.OwnerId));
        }
        return mapOfUsersWithAccount;
    }
	
	public static Boolean isNumeric(String str){
        boolean booleanValue;
        try
		{
            Decimal.valueOf(str);
            booleanValue = TRUE; 
        } catch (Exception e) 
		{
            booleanValue = FALSE;
        }
        return booleanValue;
    }
}
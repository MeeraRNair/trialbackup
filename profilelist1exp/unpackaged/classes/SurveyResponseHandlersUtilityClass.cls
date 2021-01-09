public class SurveyResponseHandlersUtilityClass
{
    public static Map<Object,Object> getMapping()
    {
        Map<Object,Object> mapOfNpsMapping = new Map<Object,Object>();
        List<NPS_Mapping__c> listOfMapping = [Select Name,Source__c,Target__c,Type__c From NPS_Mapping__c];
        for(NPS_Mapping__c mapping:listOfMapping)
        {
           if(mapOfNpsMapping.containsKey(mapping.Name))
           {
               Map<Object,Object> mapOfSour = (Map<Object,Object>)mapOfNpsMapping.get(mapping.Name);
               mapOfSour.put(mapping.Source__c,mapping.Target__c);
               mapOfNpsMapping.put(mapping.Name,mapOfSour);
           }
           else 
           {
               Map<Object,Object> mapOfSour = new Map<Object,Object>();
               mapOfSour.put(mapping.Source__c,mapping.Target__c);
               mapOfNpsMapping.put(mapping.Name,mapOfSour);
           }
            
        }
        System.debug('In get Mapping:'+mapOfNpsMapping);
        return mapOfNpsMapping;
    }
    
    public static Map<Object,Object> getMatrix(Map<Object,Object> mapOfNpsMapping)
    {
        List<Schema.DescribeFieldResult> listDescribeSObjectResult = new List<Schema.DescribeFieldResult>();
        SObjectType objType = Schema.getGlobalDescribe().get('NPS_Matrix__c');
        Map<String,Schema.SObjectField> mapOfFields = objType.getDescribe().fields.getMap();
        integer inti = 0;
        String strMatrixQuery = 'Select ';
        for(Schema.SObjectField sField:mapOfFields.values())
        {
            if(inti == mapOfFields.values().size() - 1)
            {
                strMatrixQuery += sField.getDescribe().getName();
            }
            else
            {
                strMatrixQuery += sField.getDescribe().getName()+',';
            }
            inti++;
        }
        strMatrixQuery += ' From NPS_Matrix__c where IsActive__c = true';
        System.debug('Query:'+strMatrixQuery);
        List<NPS_Matrix__c> listOfMatrix = Database.query(String.escapeSingleQuotes(strMatrixQuery));
        System.debug('List:'+listOfMatrix.size());
        Map<Object,Object> mapOfMatrix = new Map<Object,Object>();  
        Map<String,Object> mapOfMatrixRec = new Map<String,Object>();
        for(NPS_Matrix__c matrix:listOfMatrix)
        {
            mapOfMatrixRec = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(matrix));
            Map<String,Object> mapStrObj = new Map<String,Object>();
            mapStrObj.putAll(mapOfMatrixRec);
            mapOfMatrix.put(matrix.Id,mapOfMatrixRec);
        }
        Map<Object,Object> mapFinalMatrix = new Map<Object,Object>();
        for(Object obj:mapOfMatrix.keyset())
        {
            Map<String,Object> mapOfMatrixField = (Map<String,Object>)mapOfMatrix.get(obj);
            if(mapOfNpsMapping.containsKey(mapOfMatrixField.get('Name')))
            {
                Map<Object,Object> mapOfSource = (Map<Object,Object>)mapOfNpsMapping.get(mapOfMatrixField.get('Name'));
                
                for(Object obj1:mapOfSource.keyset())
                {
                    
                    String str = (String)obj1;
                    if(str.contains(','))
                    {
                        List<String> listOfStr = str.split(',');
                        System.debug('List:'+listOfStr);
                        String strKeyStr = '';
                        
                        for(String str1:listOfStr)
                        {
                            if(mapOfMatrixField.get(str1) != null)
                            {
                                strKeyStr += mapOfMatrixField.get(str1);
                            }
                        }
                        strKeyStr = strKeyStr.toLowerCase();
                        System.debug('***strKeyStr'+strKeyStr);
                        if(mapFinalMatrix.containsKey(mapOfMatrixField.get('Name')))
                        {
                            Map<Object,Object> mapOfSourceWithFields = (Map<Object,Object>)mapFinalMatrix.get(mapOfMatrixField.get('Name'));
                            mapOfSourceWithFields.put(strKeyStr,mapOfMatrixField);
                            mapFinalMatrix.put(mapOfMatrixField.get('Name'),mapOfSourceWithFields);
                        }
                        else
                        {
                            Map<Object,Object> mapOfSourceWithFields = new Map<Object,Object>();
                            mapOfSourceWithFields.put(strKeyStr,mapOfMatrixField);
                            mapFinalMatrix.put(mapOfMatrixField.get('Name'),mapOfSourceWithFields);
                        }
                    }
                    
                }
            }
            else
            {
                if(mapFinalMatrix.containsKey(mapOfMatrixField.get('Name')))
                {
                    Map<Object,Object> mapOfSourceTarget = (Map<Object,Object>)mapFinalMatrix.get(mapOfMatrixField.get('Name'));
                    mapOfSourceTarget.putAll((Map<Object,Object>)mapOfNpsMapping.get(mapOfMatrixField.get('Name')));
                    mapFinalMatrix.put(mapOfMatrixField.get('Name'),mapOfSourceTarget);
                }
                else
                {
                    Map<Object,Object> mapOfSourceTarget = new Map<Object,Object>();
                    mapOfSourceTarget.putAll((Map<Object,Object>)mapOfNpsMapping.get(mapOfMatrixField.get('Name')));
                    mapFinalMatrix.put(mapOfMatrixField.get('Name'),mapOfSourceTarget);
                }
            }
        }
        return mapFinalMatrix;
    }
    
    public static Map<Object,Object> getCaseOwners(Map<Object,Object> mapOfNpsMapping,Map<Object,Object> mapOfMatrix,List<Object> listOfResponses)
    {
        Map<Object,Object> mapOfCaseOwnersMapping = (Map<Object,Object>)mapOfNpsMapping.get('Case Owner');
        Map<Object,Object> mapOfCaseOwnerMatrix = (Map<Object,Object>)mapOfMatrix.get('Case Owner');
        Map<Object,Object> mapOfMembers = new Map<Object,Object>();
        List<Id> listOfAccountId = getAccounts(listOfResponses);
        SObjectType objType = Schema.getGlobalDescribe().get('Account_Team_Role__c');
        Map<String,Schema.SObjectField> mapOfFields = objType.getDescribe().fields.getMap();
        Set<String> setOfRoles = new Set<String>();
		Map<Object,Object> mapOfAccountTeamRole = new Map<Object,Object>();
        integer inti = 0;
        String strAccountTeamRoleQuery = 'Select ';
        for(Schema.SObjectField sField:mapOfFields.values())
        {
            if(inti == mapOfFields.values().size() - 1)
            {
                strAccountTeamRoleQuery += sField.getDescribe().getName();
            }
            else
            {
                strAccountTeamRoleQuery += sField.getDescribe().getName()+',';
            }
            inti++;
        }
        strAccountTeamRoleQuery += ' From Account_Team_Role__c';
        System.debug('Query:'+strAccountTeamRoleQuery);
        List<Account_Team_Role__c> listOfAccTeamRole = Database.query(String.escapeSingleQuotes(strAccountTeamRoleQuery));
        for(Account_Team_Role__c roleAccount:listOfAccTeamRole)
        {
            setOfRoles.add(roleAccount.Name);
			Map<String,Object>  mapOfAtmFields = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(roleAccount));
			mapOfAccountTeamRole.put(roleAccount.Id,mapOfAtmFields);
        }
        Map<Object,Object> mapOfRoleWithUser = new Map<Object,Object>();
        List<AccountTeamMember> listOfMembers = [Select UserId,TeamMemberRole,AccountId From AccountTeamMember where TeamMemberRole IN: setOfRoles AND AccountId IN: listOfAccountId Order By CreatedDate ASC];
        for(AccountTeamMember accMember:listOfMembers)
        {
            Map<Object,Object> mapOfAccountWithRole = new Map<Object,Object>();
            if(mapOfRoleWithUser.containsKey(accMember.AccountId))
            {
                Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleWithUser.get(accMember.AccountId);
                if(!mapObj.containsKey(accMember.TeamMemberRole))
                {
                    mapObj.put(accMember.TeamMemberRole,accMember.UserId);
                    mapOfRoleWithUser.put(accMember.AccountId,mapObj);
                }
            }
            else
            {
                Map<Object,Object> mapObj = new Map<Object,Object>();
                mapObj.put(accMember.TeamMemberRole,accMember.UserId);
                mapOfRoleWithUser.put(accMember.AccountId,mapObj);
            }
        }
        Set<Id> setOfUserId = new Set<Id>();
        for(AccountTeamMember atmem:listOfMembers)
        {
            setOfUserId.add(atmem.UserId);
        }
        Map<String,User> mapOfUser = new Map<String,User>([Select Id,ManagerId,Email,RSM__c,ISM__c,Resource_Manager_Role__c From User where Id IN: setOfUserId]);
        Map<Object,Object> mapOfUserFields = new Map<Object,Object>();
		for(String str:mapOfUser.keyset())
		{
			Map<String,Object> mapOfUserFieldValue = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapOfUser.get(str)));
			mapOfUserFields.put(str,mapOfUserFieldValue);
		}
		Set<Id> setOfRsm = new Set<Id>();
		for(User us:mapOfUser.values())
		{
			if(us.RSM__c != null)
			{
				setOfRsm.add(us.RSM__c);
			}
			if(us.ISM__c != null)
			{
				setOfRsm.add(us.ISM__c);
			}
			if(us.ManagerId != null)
			{
				setOfRsm.add(us.ManagerId);
			}
		}
		Map<String,User> mapOfRsmUser = new Map<String,User>([Select Id,Email from User where Id IN: setOfRsm]);
        Map<Object,Object> mapOfAtRoleWithUser = new Map<Object,Object>();
        
		
		for(Account_Team_Role__c atRole:listOfAccTeamRole)
		{
			for(Object obj:mapOfRoleWithUser.keyset())
			{
				Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleWithUser.get(obj);
				Map<Object,Object> mapRoleUser = new Map<Object,Object>();
				if(mapObj.containsKey(atRole.Name))
				{
					Id userId = (Id)mapObj.get(atRole.Name);
					Map<String,Object> mapStrUser = (Map<String,Object>)mapOfUserFields.get(userId);
					String strRole = (String)mapStrUser.get('Resource_Manager_Role__c');
					if(strRole != null && strRole.contains('Manager') && atRole.Manager__c != null)
					{
						mapRoleUser.put(atRole.Id,mapOfUser.get(userId));
					}
					else if((strRole == null || !strRole.contains('Manager')) && atRole.Manager__c != null && mapStrUser.get(atRole.Manager__c) != null)
					{
						mapRoleUser.put(atRole.Id,mapOfRsmUser.get((String)mapStrUser.get(atRole.Manager__c)));
					}
					else if(atRole.Manager__c == null)
					{
						mapRoleUser.put(atRole.Id,mapOfUser.get(userId));
					}
				}
				
				if(mapOfAtRoleWithUser.containsKey(obj))
				{
					Map<Object,Object> mapRoleUserReturn = (Map<Object,Object>)mapOfAtRoleWithUser.get(obj);
					mapRoleUserReturn.putAll(mapRoleUser);
					mapOfAtRoleWithUser.put(obj,mapRoleUserReturn);
				}
				else
				{
					Map<Object,Object> mapRoleUserReturn = new Map<Object,Object>();
					mapRoleUserReturn.putAll(mapRoleUser);
					mapOfAtRoleWithUser.put(obj,mapRoleUserReturn);
				}
			}
		}
        System.debug('In getCaseOwners:'+mapOfAtRoleWithUser);
        return mapOfAtRoleWithUser;
    }
    
    /*
    Method to fetch accounts for survey responses.
    Return Map with key as AccountId and value as Map with Key as Account field names and value as field values.
    */
    public static List<Id> getAccounts(List<Object> listOfResponses)
    {
        List<Id> listOfAccountId = new List<Id>();
        for(Object obj:listOfResponses)
        {
            Map<String,Object> mapOfResponseFields = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            String strAccountId = (String)mapOfResponseFields.get('MaritzCX__Account__c');
            listOfAccountId.add(strAccountId);
        }
        return listOfAccountId;
    }
}
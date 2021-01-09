public class SurveyResponseTriggerHandlerBI
{
    public static void beforeInsert(List<MaritzCX__Survey_Response__c> listNew)
    {
        Map<Object,Object> mapOfNpsMapping = SurveyResponseHandlersUtilityClass.getMapping();
        Map<Object,Object> mapOfMatrix = SurveyResponseHandlersUtilityClass.getMatrix(mapOfNpsMapping);
		Map<Object,Object> mapOfNpsMappingCreation = (Map<Object,Object>)mapOfNpsMapping.get('Case Creation');
		Map<Object,Object> mapOfNpsMatrixCreation = (Map<Object,Object>)mapOfMatrix.get('Case Creation');
        Map<Object,Object> mapOfFieldAdvocate = (Map<Object,Object>)mapOfMatrix.get('Field Advocate');
        Map<Object,Object> mapOfFieldAdvocateMapping = (Map<Object,Object>)mapOfNpsMapping.get('Field Advocate');
        Map<Object,Object> mapOfValidation = (Map<Object,Object>)mapOfNpsMapping.get('Validation');
        Map<Object,Object> mapOfOwnerMapping = (Map<Object,Object>)mapOfNpsMapping.get('Case Owner');
        Map<Object,Object> mapOfOwnerMatrix = (Map<Object,Object>)mapOfMatrix.get('Case Owner');
        Map<Object,Object> mapOfOwnerMappingTier = (Map<Object,Object>)mapOfNpsMapping.get('Case Owner Tier');
        Map<Object,Object> mapOfOwnerMatrixTier = (Map<Object,Object>)mapOfMatrix.get('Case Owner Tier');
        Map<Object,Object> mapOfFieldMapping = (Map<Object,Object>)mapOfNpsMapping.get('Survey Response Mapping');
        Map<Object,Object> mapOfPassiveMatrix = (Map<Object,Object>)mapOfMatrix.get('Passive Promoter');
        Map<Object,Object> mapOfPassiveMapping = (Map<Object,Object>)mapOfNpsMapping.get('Passive Promoter');
        Map<Object,Object> mapOfPassiveTierMatrix = (Map<Object,Object>)mapOfMatrix.get('Passive Promoter Tier');
        Map<Object,Object> mapOfPassiveTierMapping = (Map<Object,Object>)mapOfNpsMapping.get('Passive Promoter Tier');
        Map<Object,Object> mapOfSRMapping = new Map<Object,Object>();
        Map<Object,Object> mapOfRoleUsers = SurveyResponseHandlersUtilityClass.getCaseOwners(mapOfNpsMapping,mapOfMatrix,listNew);
        Map<String,User> mapOfAccountOwners = getAccountOwners(listNew);
        if(mapOfFieldMapping.size() != null)
        {
            for(Object obj:mapOfFieldMapping.keyset())
            {
                String strKey = (String)obj;
                String strVal = (String)mapOfFieldMapping.get(obj);
                System.debug('Str key:'+strKey+'Str vsl:'+strVal);
                if(strKey.substringBefore('.').equals('NPS_Matrix__c') && strVal.substringBefore('.').equals('MaritzCX__Survey_Response__c'))
                {
                    mapOfSRMapping.put(strKey.substringAfter('.'),strVal.substringAfter('.'));
                }
            }
        }
        
        for(MaritzCX__Survey_Response__c msr:listNew)
        {
            Map<String,Object> mapOfResponseFields = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(msr));
            Map<String,Object> mapOfOwnerMatrixFields;
            if(mapOfFieldAdvocateMapping != null)
            {
                Set<Object> setOfAdvocateSource = (Set<Object>)mapOfFieldAdvocateMapping.keyset();
                List<Object> listOfAdvocateSource = new List<Object>();
                listOfAdvocateSource.addAll(setOfAdvocateSource);
                String strSource = (String)listOfAdvocateSource.get(0);
                List<String> listSourceSplit = strSource.split(',');
                String strKey = '';
                for(String str:listSourceSplit)
                {
                    String strSourceStr = (String)mapOfValidation.get(str);
                    Object objVal = mapOfResponseFields.get(strSourceStr);
                    strKey += objVal;
                }
                strKey = strKey.toLowerCase();
                if(mapOfFieldAdvocate.containsKey(strKey))
                {
                    Map<String,Object> mapStringobj = (Map<String,Object>)mapOfFieldAdvocate.get(strKey);
                    msr.put('Advocate__c',mapStringobj.get('Advocate__c'));
                    System.debug('&&&Advocate in start:'+msr.Advocate__c);
                }
            }
			Set<Object> setOfCreationSource = (Set<Object>)mapOfNpsMappingCreation.keyset();
            List<Object> listOfCreationSource = new List<Object>();
            listOfCreationSource.addAll(setOfCreationSource);
            String strCreationSource = (String)listOfCreationSource.get(0);
            List<String> listCreationSourceSplit = strCreationSource.split(',');
            String strCreation = '';
            for(String str:listCreationSourceSplit)
            {
                String strOwnerStr = (String)mapOfValidation.get(str);
                if(mapOfResponseFields.get(strOwnerStr) != null)
                {
                    String strVal = String.valueOf(mapOfResponseFields.get(strOwnerStr));
					if(isNumeric(strVal))
					{
					   Decimal dcStr = Decimal.valueOf(strVal);
					   strVal = String.valueOf(dcStr.intValue());
					}
                    strCreation += strVal;
                }
                strCreation = strCreation.toLowerCase();
            }
			System.debug('Str creation:'+strCreation);
			if(mapOfNpsMatrixCreation.get(strCreation) != null)
			{
				Set<Object> setOfTierSource = (Set<Object>)mapOfOwnerMappingTier.keyset();
				List<Object> listOfTierSource = new List<Object>();
				listOfTierSource.addAll(setOfTierSource);
				String strTierSource = (String)listOfTierSource.get(0);
				List<String> listTierSourceSplit = strTierSource.split(',');
				String strKeyOwner = '';
				for(String str:listTierSourceSplit)
				{
					String strTierStr = (String)mapOfValidation.get(str);
					if(mapOfResponseFields.get(strTierStr) != null)
					{
						Object objVal = mapOfResponseFields.get(strTierStr);
						strKeyOwner += objVal;
					}
					strKeyOwner = strKeyOwner.toLowerCase();
				}
				System.debug('**&&StrKeyOwner:'+StrKeyOwner);
				if(mapOfOwnerMatrixTier.containsKey(strKeyOwner))
				{
					System.debug('**&&Inside if');
					mapOfOwnerMatrixFields = (Map<String,Object>)mapOfOwnerMatrixTier.get(strKeyOwner);
				}
				else
				{
					Set<Object> setOfOwnerSource = (Set<Object>)mapOfOwnerMapping.keyset();
					List<Object> listOfOwnerSource = new List<Object>();
					listOfOwnerSource.addAll(setOfOwnerSource);
					String strOwnerSource = (String)listOfOwnerSource.get(0);
					List<String> listOwnerSourceSplit = strOwnerSource.split(',');
					strKeyOwner = '';
					for(String str:listOwnerSourceSplit)
					{
						String strSourceStr = (String)mapOfValidation.get(str);
						if(mapOfResponseFields.get(strSourceStr) != null)
						{
							Object objVal = mapOfResponseFields.get(strSourceStr);
							strKeyOwner += objVal;
						}
					}
					strKeyOwner = strKeyOwner.toLowerCase();
					mapOfOwnerMatrixFields = (Map<String,Object>)mapOfOwnerMatrix.get(strKeyOwner);
				}
				
				System.debug('***Key Owner:'+strKeyOwner);
				for(Object obj:mapOfSRMapping.keyset())
				{
					String str = (String)obj;
					System.debug('Additional:'+str);
					if(str.contains('Additional_Recipient') && mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c')) != null)
					{   
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						User userRecipient = (User)mapObj.get(mapOfOwnerMatrixFields.get(str));
						if(userRecipient != null)
						{
							msr.put((String)mapOfSRMapping.get(str),userRecipient.Email);
						}
					}
					else if(!str.contains('Additional_Recipient'))
					{
						System.debug('In else:'+mapOfOwnerMatrixFields.get((String)str));
						msr.put((String)mapOfSRMapping.get(str),mapOfOwnerMatrixFields.get((String)str));
					}
				}
				System.debug('After if');
				if(mapOfOwnerMatrixFields.get('CX_Email__c') == true)
				{
					System.debug('After CX_Email__c');
					String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('CX_Email__c'));
					if(!String.isBlank(str) && str.contains(','))
					{
						List<String> listOfStr = str.split(',');
						for(integer inti = 1;inti <= listOfStr.size();inti++)
						{
							String strCx = listOfStr.get(inti-1);
							String strEmail = 'CX_Email_'+inti+'__c';
							msr.put(strEmail,strCx);
						}
					}
					else if(!String.isBlank(str))
					{
						msr.put('CX_Email_1__c',str);
					}
				}
				if(mapOfOwnerMatrixFields.get('OMS_Case_Manager__c') == true)
				{
					System.debug('After OMS_Case_Manager__c');
					String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('OMS_Case_Manager__c'));
					if(!String.isBlank(str) && str.contains(','))
					{
						List<String> listOfStr = str.split(',');
						for(integer inti = 1;inti <= listOfStr.size();inti++)
						{
							String strOm = listOfStr.get(inti-1);
							String strOms = 'OMS_'+inti+'__c';
							msr.put(strOms,strOm);
						}
					}
					else if(!String.isBlank(str))
					{
						msr.put('OMS_1__c',str);
					}
				}
				if(mapOfOwnerMatrixFields.get('GCP_PM__c') == true)
				{
					System.debug('After GCP PM');
					String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('GCP_PM__c'));
					msr.put('GCP_PM__c',str);
				}
				
				User us;
				if(mapOfOwnerMatrixFields.get('Account_Team_Role_1__c') != null)
				{
					System.debug('Inside if 1');
					Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
					if(mapObj != null)
					{
						us = (User)mapObj.get(mapOfOwnerMatrixFields.get('Account_Team_Role_1__c'));
					}
				}
				System.debug('###User 1:'+us);
				if(mapOfOwnerMatrixFields.get('Account_Team_Role_2__c') != null && us == null)
				{
					System.debug('Inside if 2');
					Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
					if(mapObj != null)
					{
						us = (User)mapObj.get(mapOfOwnerMatrixFields.get('Account_Team_Role_2__c'));
					}
				}
				System.debug('###User 2:'+us);
				if(mapOfOwnerMatrixFields.get('Account_Team_Role_3__c') != null && us == null)
				{
					System.debug('Inside if 3');
					Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
					if(mapObj != null)
					{
						us = (User)mapObj.get(mapOfOwnerMatrixFields.get('Account_Team_Role_3__c'));
					}
				}
				System.debug('###User 3:'+us);
				if(mapOfOwnerMatrixFields.get('Account_Team_Role_4__c') != null && us == null)
				{
					System.debug('Inside if 4');
					Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
					if(mapObj != null)
					{
						us = (User)mapObj.get(mapOfOwnerMatrixFields.get('Account_Team_Role_4__c'));
					}
				}
				System.debug('###User 4:'+us);
				if(mapOfOwnerMatrixFields.get('Account_Team_Role_5__c') != null && us == null)
				{
					System.debug('Inside if 5');
					Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
					if(mapObj != null)
					{
						us = (User)mapObj.get(mapOfOwnerMatrixFields.get('Account_Team_Role_5__c'));
					}
				}
				System.debug('###User 5:'+us);
				if(us == null)
				{
					us = (User)mapOfAccountOwners.get((String)mapOfResponseFields.get('MaritzCX__Account__c'));
				}
				msr.put('Owner__c',us.Email);
			}
            else
            {
				System.debug('In else of Passive Promoter');
                Map<String,Object> mapOfPassiveMatrixFields;
                Set<Object> setOfPassiveTierSource = (Set<Object>)mapOfPassiveTierMapping.keyset();
                List<Object> listOfPassiveTierSource = new List<Object>();
                listOfPassiveTierSource.addAll(setOfPassiveTierSource);
                String strPassiveTierSource = (String)listOfPassiveTierSource.get(0);
                List<String> listPassiveTierSplit = strPassiveTierSource.split(',');
                String strKeyPassiveOwner = '';
                for(String str:listPassiveTierSplit)
                {
                    String strPassiveTierStr = (String)mapOfValidation.get(str);
                    if(mapOfResponseFields.get(strPassiveTierStr) != null)
                    {
                        Object objVal = mapOfResponseFields.get(strPassiveTierStr);
                        strKeyPassiveOwner += objVal;
                    }
                    strKeyPassiveOwner = strKeyPassiveOwner.toLowerCase();
                }
                System.debug('**&&strKeyPassiveOwner:'+strKeyPassiveOwner);
                if(mapOfPassiveTierMatrix.containsKey(strKeyPassiveOwner))
                {
                    System.debug('**&&Inside if');
                    mapOfPassiveMatrixFields = (Map<String,Object>)mapOfPassiveTierMatrix.get(strKeyPassiveOwner);
                }
                else
                {
                    Set<Object> setOfPassiveSource = (Set<Object>)mapOfPassiveMapping.keyset();
                    List<Object> listOfPassiveSource = new List<Object>();
                    listOfPassiveSource.addAll(setOfPassiveSource);
                    String strPassiveOwnerSource = (String)listOfPassiveSource.get(0);
                    List<String> listSourceSplit = strPassiveOwnerSource.split(',');
                    strKeyPassiveOwner = '';
                    for(String str:listSourceSplit)
                    {
                        String strPassiveStr = (String)mapOfValidation.get(str);
                        if(mapOfResponseFields.get(strPassiveStr) != null)
                        {
                            Object objVal = mapOfResponseFields.get(strPassiveStr);
                            strKeyPassiveOwner += objVal;
                        }
                    }
                    strKeyPassiveOwner = strKeyPassiveOwner.toLowerCase();
                    mapOfPassiveMatrixFields = (Map<String,Object>)mapOfPassiveMatrix.get(strKeyPassiveOwner);
                }
				System.debug('$$mapOfPassiveMatrixFields:'+mapOfPassiveMatrixFields);
				if(mapOfPassiveMatrixFields != null)
				{
					for(Object obj:mapOfSRMapping.keyset())
					{
						String str = (String)obj;
						if(str.contains('Additional_Recipient') && mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c')) != null)
						{
							Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
							User userRecipient = (User)mapObj.get(mapOfPassiveMatrixFields.get(str));
							if(userRecipient != null)
							{
								msr.put((String)mapOfSRMapping.get(obj),userRecipient.Email);
							}
						}
						else if(!str.contains('Additional_Recipient'))
						{
							msr.put((String)mapOfSRMapping.get(str),mapOfPassiveMatrixFields.get((String)str));
						}
					}
					if(mapOfPassiveMatrixFields.get('CX_Email__c') == true)
					{
						String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('CX_Email__c'));
						if(!String.isBlank(str) && str.contains(','))
						{
							List<String> listString = str.split(',');
							for(integer inti = 1;inti <= listString.size();inti++)
							{
								String strCx = listString.get(inti-1);
								String strEmail = 'CX_Email_'+inti+'__c';
								msr.put(strEmail,strCx.deleteWhitespace());
							}
						}
						else if(!String.isBlank(str))
						{
							msr.put('CX_Email_1__c',str);
						}
					}
					if(mapOfPassiveMatrixFields.get('OMS_Case_Manager__c') == true)
					{
						String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('OMS_Case_Manager__c'));
						if(!String.isBlank(str) && str.contains(','))
						{
							List<String> listString = str.split(',');
							for(integer inti = 1;inti <= listString.size();inti++)
							{
								String strOm = listString.get(inti-1);
								String strOms = 'OMS_'+inti+'__c';
								msr.put(strOms,strOm.deleteWhitespace());
							}
						}
						else if(!String.isBlank(str))
						{
							msr.put('OMS_1__c',str);
						}
					}
					System.debug('$$Before GCP PM');
					if(mapOfPassiveMatrixFields.get('GCP_PM__c') == true)
					{
						System.debug('$$Inside GCP PM');
						String str = (String)mapOfResponseFields.get((String)mapOfValidation.get('GCP_PM__c'));
						msr.put('GCP_PM__c',str);
					}
					
					User us;
					if(mapOfPassiveMatrixFields.get('Account_Team_Role_1__c') != null)
					{
						System.debug('Inside if 1');
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						if(mapObj != null)
						{
							us = (User)mapObj.get(mapOfPassiveMatrixFields.get('Account_Team_Role_1__c'));
						}
					}
					System.debug('###User 1:'+us);
					if(mapOfPassiveMatrixFields.get('Account_Team_Role_2__c') != null && us == null)
					{
						System.debug('Inside if 2');
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						if(mapObj != null)
						{
							us = (User)mapObj.get(mapOfPassiveMatrixFields.get('Account_Team_Role_2__c'));
						}
					}
					System.debug('###User 2:'+us);
					if(mapOfPassiveMatrixFields.get('Account_Team_Role_3__c') != null && us == null)
					{
						System.debug('Inside if 3');
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						if(mapObj != null)
						{
							us = (User)mapObj.get(mapOfPassiveMatrixFields.get('Account_Team_Role_3__c'));
						}
					}
					System.debug('###User 3:'+us);
					if(mapOfPassiveMatrixFields.get('Account_Team_Role_4__c') != null && us == null)
					{
						System.debug('Inside if 4');
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						if(mapObj != null)
						{
							us = (User)mapObj.get(mapOfPassiveMatrixFields.get('Account_Team_Role_4__c'));
						}
					}
					System.debug('###User 4:'+us);
					if(mapOfPassiveMatrixFields.get('Account_Team_Role_5__c') != null && us == null)
					{
						System.debug('Inside if 5');
						Map<Object,Object> mapObj = (Map<Object,Object>)mapOfRoleUsers.get(mapOfResponseFields.get('MaritzCX__Account__c'));
						if(mapObj != null)
						{
							us = (User)mapObj.get(mapOfPassiveMatrixFields.get('Account_Team_Role_5__c'));
						}
					}
					if(us == null)
					{
						us = (User)mapOfAccountOwners.get((String)mapOfResponseFields.get('MaritzCX__Account__c'));
					}
					System.debug('###User 5:'+us);
					msr.put('Owner__c',us.Email);
				}
            }
            
        }
    }
    
    public static Map<String,User> getAccountOwners(List<MaritzCX__Survey_Response__c> listOfResponses)
    {
        List<String> listOfAccountId = new List<String>();
        List<String> listOfOwnerId = new List<String>();
        Map<String,User> mapOfUsersWithAccount = new Map<String,User>(); 
        for(MaritzCX__Survey_Response__c msr:listOfResponses)
        {
            listOfAccountId.add(msr.MaritzCX__Account__c);
        }
        List<Account> listOfAccounts = new List<Account>([Select OwnerId from Account where Id IN: listOfAccountId]);
        for(Account acc:listOfAccounts)
        {
            listOfOwnerId.add(acc.OwnerId);
        }
        Map<String,User> mapOfUser = new Map<String,User>([Select Id,Email from User where Id IN: listOfOwnerId]);
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
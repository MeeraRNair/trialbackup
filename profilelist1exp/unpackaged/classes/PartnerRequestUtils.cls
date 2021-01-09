public with sharing class PartnerRequestUtils {

	private static final Map<String,String> countryHideFlagToPartnerRequestFlag = new Map<String,String>{
		'Task_Agreement_Hard_copy_Received__c'=>'Task_Agreement_Hard_copy_Received__c'
		,'Task_Check_Credit__c'=>'Task_Check_Credit__c'
		,'Task_Check_Denied_Party_List__c'=>'Task_Check_Denied_Party_List__c'
		,'Task_Check_Export_Compliance__c'=>'Task_Check_Export_Compliance__c'
		,'Task_Enable_Order_Management_access__c'=>'Task_Enable_Order_Management_access__c'
		,'Task_Enable_Premier_Pages_access__c'=>'Task_Enable_Premier_Pages_access__c'
		,'Task_Send_Welcome_Packet_to_Partner__c'=>'Task_Send_Welcome_Packet_to_Partner__c'
	};

	public static void updateTaskHideFlags(Partner_Request__c request){
		updateTaskHideFlags(new List<Partner_Request__c>{request});
	}
	
	public static void updateTaskHideFlags(List<Partner_Request__c> requests){
		if(requests != null && requests.size() > 0){
			final Set<String> distinctCountryIds = new Set<String>();
			for(Partner_Request__c request : requests){
				if(request != null && request.country__c != null){
					distinctCountryIds.add('\'' + request.country__c + '\'');
				}
			}
	    	final List<Country__c> countries = Database.query(
    			'select '
    			+ al.StringUtils.joinStrings(countryHideFlagToPartnerRequestFlag.values(),',')
    			+ ' from Country__c where id in (' 
    			+ al.StringUtils.joinStrings(distinctCountryIds,',')
    			+ ')');
			final Map<ID,Country__c> idToCountry = new Map<ID,Country__c>();
    		if(countries != null && countries.size()>0){
    			for(Country__c country : countries){
    				idToCountry.put(country.id,country);
    			}
    		}
			for(Partner_Request__c request : requests){
				if(request != null && request.country__c != null && idToCountry.containsKey(request.country__c)){
					Object value = null;
					for(String countryFlag : countryHideFlagToPartnerRequestFlag.keySet()){
						value = idToCountry.get(request.country__c).get(countryFlag);
						if(value == null){
							continue;
						}
						request.put(countryHideFlagToPartnerRequestFlag.get(countryFlag),value);
					}
				}
			}
		}
	}
	
	/*
	
    public static void sendNotificationEmail(List<ID> ids){
        if(ids == null || ids.size() <= 0){
            throw new al.IllegalArgumentException();
        }
        
        //================================
        //Get Partner Requests
        //================================
        final String soql = 'select id,name,ownerid '
           + ' from partner_request__c ' 
           + ' where id in (\'' 
           + al.StringUtils.joinArray(ids,'\',\'')
           + '\') and owner.type = \'Queue\'';
        System.debug('soql: ' + soql);
        final List<Partner_Request__c> retrieved = Database.query(soql);

        //================================
        //Get Queue Details
        //================================
        final Set<ID> distinctQueueIds = new Set<ID>();
        for(Partner_Request__c request : retrieved){
        	distinctQueueIds.add(request.ownerid);
        }
        final List<GroupMember> members = [
            select UserOrGroupId, GroupId, Group.Email, Group.DoesSendEmailToMembers  
            from GroupMember 
            where groupid in :distinctQueueIds];
            
        final Map<String,Set<String>> groupIdToMembers = new Map<String,Set<String>>();
        final Map<String,Set<String>> userIdToGroupIds = new Map<String,Set<String>>();
        for(GroupMember member : members){
        	if(!groupIdToMembers.containsKey(member.GroupId)){
        		groupIdToMembers.put(member.GroupId,new Set<String>());
        	}
        	if(al.StringUtils.isNotBlank(member.Group.Email)){
                groupIdToMembers.get(member.GroupId).add(member.Group.Email);
        	}
        	if(member.Group.DoesSendEmailToMembers){
	            if(!userIdToGroupIds.containsKey(member.UserOrGroupId)){
	                userIdToGroupIds.put(member.UserOrGroupId,new Set<String>());
	            }
	            userIdToGroupIds.get(member.UserOrGroupId).add(member.GroupId);
        	}
        }
        
        //================================
        //Get User emails
        //================================
        final List<User> users = [select id,email from user where id in :userIdToGroupIds.keySet()];
        for(User aUser : users){
        	if(userIdToGroupIds.containsKey(aUser.id)){
                for(String groupId: userIdToGroupIds.get(aUser.id)){
		            if(al.StringUtils.isNotBlank(aUser.Email)){
		                groupIdToMembers.get(groupId).add(aUser.Email);
		            }
                }
        	}
        }

        //================================
        //Send out emails
        //================================
        for(Partner_Request__c request : retrieved){
            if(groupIdToMembers.containsKey(request.ownerid)){
	            EmailUtils.sendTextEmail(   
	               //recipients
	               toList(groupIdToMembers.get(request.ownerid)),
	               //subject
	               'Partner Request transferred to you.',
	               //body
	               'Partner Request ' + request.name + ' has been assigned to you. '
	               + 'Please click on the link below to view the record.\n\n'
	               + 'https://' + (Environment.isProduction() ? 'login' : 'test') + '.salesforce.com/?startURL=%2F' 
	               + request.id);
            }
        }
        
    }
    
    private static List<String> toList(Set<String> aSet){
    	final List<String> aList = new List<String>();
    	if(aSet != null && aSet.size() > 0){
    		for(String aString : aSet){
    			aList.add(aString);
    		}
    	}
    	return aList;
    }
    */
}
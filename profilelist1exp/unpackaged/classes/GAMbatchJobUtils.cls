/* 

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     10-Jul-2011     Krishna			Created for CR6236 and CR6238. Contains utility methods for error notifications.
*/
public class GAMbatchJobUtils {
	
	public static List<String> emailList = getEmailIdList(); //initializes
	public static Boolean enabledNotification = StringUtils.equalsIgnoreCase(StringUtils.defaultString(Label.GAM_Enable_Exception_emails),'TRUE');
	
	public static String prepareNotificationMessage(List<GroupMember> groupMemberList, Database.SaveResult[] listOfResult, String Operation){
		return prepareNotificationMessageCommon(groupMemberList,listOfResult,null,Operation);	
	}
	public static String prepareNotificationMessage(List<GroupMember> groupMemberList, Database.DeleteResult[] listOfDeleteResult, String Operation){
		//for delete result
		return prepareNotificationMessageCommon(groupMemberList,null,listOfDeleteResult,Operation);
	}		
	
	private static String prepareNotificationMessageCommon(List<GroupMember> groupMemberList, Database.SaveResult[] listOfSaveResult,Database.DeleteResult[] listOfDeleteResult, 
															String Operation){
		    //for insert result
        String errorMessage='';
		integer errorRecordNumb = 0;
		integer totalRecords = 0;
		try{
			if(Operation == 'Insert'){
				for(integer i = 0; i< listOfSaveResult.size();i++){    
		            if(listOfSaveResult[i].isSuccess()!=true){
		            	errorMessage += processOneResultError(groupMemberList[i],listOfSaveResult[i].getErrors());
						errorRecordNumb++;
		            }
				}
				totalRecords = listOfSaveResult.size();
			}
		    else if(Operation == 'Delete'){
		    	for(integer i = 0; i< listOfDeleteResult.size();i++){    
		            if(listOfDeleteResult[i].isSuccess()!=true){
		            	errorMessage += processOneResultError(groupMemberList[i],listOfDeleteResult[i].getErrors());
						errorRecordNumb++;
		            }
				}
				totalRecords = listOfDeleteResult.size();
		    }  
			errorMessage = getMessageHeader(totalRecords,errorRecordNumb, Operation) + errorMessage; 
				
		}catch(Exception e){
			System.debug('##### Exception ' + e.getmessage());
		}		
		
		return errorMessage;	
	}
	
	//Internal methods.
	private static String processOneResultError(GroupMember grpMember,Database.Error [] errors){
		String message = '\n##';
        if(grpMember.id!=null){
			message += 'Id=' + grpMember.id + ';';
		}
        message +='GroupId='+grpMember.GroupId+';UserID='+ grpMember.UserOrGroupId +';Error=';
		
        Boolean first = true;
        for (Database.Error error :errors){
			if(!first)
				message +=',';
			message +='['+error.getStatusCode() + ']' + error.getMessage();
			first = false;
        } 
		message += ';';
		return message;
	}
	
	private static String getMessageHeader(integer total, integer errorRecordNumb, String Operation){
		String header = '';
		if (errorRecordNumb > 0 ){
			header =  'Group Member ' + Operation + ' failed for ' + errorRecordNumb 
							+ ' records out of ' + total +' records. The error Details:\n\n';			
		}
		else{			
			header =  'Group Member ' + Operation + ' was successfully completed for ' + total +' records.\n';		
		}
		return header;
	}
	public static void sendOptionalNotification(String subject, String body){
		//once again checks teh attributes
		try{
			if(enabledNotification && emailList !=null && emailList.size()>0){
				body = '##System time: '+ DateTime.now()+'##\n' +body;
				emailUtils.sendTextEmail(emailList,subject,body);			
			}	
		}catch(Exception e){
			System.debug('##### Exception ' + e.getmessage());
		}
		
	}
	public static List<String> getEmailIdList(){
		List<String> emails = new List<String>();
		String EmailRecipientStr = StringUtils.defaultString(Label.GAM_Exception_email_recipients).replace(' ','');
		if(EmailRecipientStr.contains('@')){
			emails = EmailRecipientStr.split(';', -1);
		}
		return emails;
	}
	}
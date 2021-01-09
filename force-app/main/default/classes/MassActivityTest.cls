@isTest
public class MassActivityTest {

    private static User recordCreator;
    
    static {
        createTestData();
    }
    
    private static void createTestData(){
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
                //Create a user with Standard User profile
        recordCreator = new User(Username = 'TestValidUser1' + '@dell.com',
                            Alias = 'Test', 
                            Email = 'Test212'+'@dell.com', 
                            LastName = 'Test22',
                            Title = 'GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Country = 'US',
                            Badge_Number__c = 'Test'+System.currentTimeMillis());
        insert recordCreator;
        
        Account acc = new Account();
                acc.OwnerId =recordCreator.Id; 
                acc.Name = 'Sak Test01';
        insert acc;   
		List<Task> taskList = new List<Task>();
        System.runAs(recordCreator) {
            Task newTask;
            for (integer i=0 ; i<100 ; i++) {
            	newTask = new task();
                newTask.ownerID=acc.ownerID;
                newTask.subject='Create pricing';
                newTask.Status='Not Started';
                newTask.Type='Internal Email';
                newTask.ActivityDate=system.today();
                taskList.add(newTask);
            }
            TriggerExecutionController.setSkipTaskTriggers(true);
            insert taskList;   
            TriggerExecutionController.setSkipTaskTriggers(false);
                            
        }
    }
    
    static testMethod void init(){
        //createTestData();
        System.runAs(recordCreator) {
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            actUpdate.cancelAndReturn();
            actUpdate.getPageNumLinks1();
            actUpdate.getPageNaviLinks1();
        }
    }
    
    static testMethod void saveandReturnTest(){
        test.startTest(); 
        System.runAs(recordCreator) {
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            List<MassActivityUpdate.ActivityDTO> dtoList = actUpdate.activityList25; 	
            for(MassActivityUpdate.ActivityDTO dtoObj:dtoList){
                dtoObj.isModified = true;
                break;
            }
            actUpdate.saveAndReturn();
        }
        test.stopTest();
    }
    
    static testMethod void validationTest(){
        System.runAs(recordCreator) {
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            List<MassActivityUpdate.ActivityDTO> dtoList = actUpdate.activityList25; 
            for(MassActivityUpdate.ActivityDTO dtoObj:dtoList){
                dtoObj.isModified = true;
                if(dtoObj.isTask){
                    dtoObj.taskRec.Type = null;
                    dtoObj.taskRec.subject = null;
                    dtoObj.taskRec.ActivityDate = null;
                    dtoObj.taskRec.Description = 'Testing from testclass';
                }else{
                    dtoObj.EventRec.Type = null;
                    dtoObj.EventRec.subject = null;
                    dtoObj.EventRec.ActivityDate = null;
                    dtoObj.EventRec.Description = 'Testing from testclass';
                }
                
                break;
            }
            actUpdate.saveAndReturn();
        }
    }
    
    static testMethod void NavigationTest(){
        System.runAs(recordCreator) {
            ApexPages.currentPage().getParameters().put('pageNumber', 'NEXT');
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            actUpdate.SaveAndRefresh();
            actUpdate.getPageNumLinks();
            System.assertEquals(actUpdate.pageNum,2);
            ApexPages.currentPage().getParameters().put('pageNumber', 'FIRST');
            actUpdate.SaveAndRefresh();
            actUpdate.getPageNumLinks();
            ApexPages.currentPage().getParameters().put('pageNumber', 'LAST');
            actUpdate.SaveAndRefresh();
            actUpdate.getPageNumLinks();
            System.assertEquals(actUpdate.pageNum,4);
            ApexPages.currentPage().getParameters().put('pageNumber', 'PREV');
            actUpdate.SaveAndRefresh();
            ApexPages.currentPage().getParameters().put('pageNumber', '3');
            actUpdate.SaveAndRefresh();
            actUpdate.getPageNaviLinks();
        }
    }
    
    static testMethod void paginationTest(){
        System.runAs(recordCreator) {
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            actUpdate.First();
            actUpdate.Last();
            actUpdate.Previous();
            actUpdate.Next();
        }
    }
    
    static testMethod void EventTest(){
        List<Event> eventList = new List<Event>();
        System.runAs(recordCreator) {
            Event newEvent;
            for(integer i=0 ; i<10 ; i++){
                newEvent = new Event();
                newEvent.ownerID=recordCreator.id;
                newEvent.subject='Create pricing';
                newEvent.Type='Internal Email';
                newEvent.DurationInMinutes=43;
                newEvent.ActivityDateTime=system.now()+1;
                eventList.add(newEvent);
            }
            insert eventList;
            
            MassActivityUpdate actUpdate = new MassActivityUpdate();
            List<MassActivityUpdate.ActivityDTO> dtoList = actUpdate.activityList25; 	
            for(MassActivityUpdate.ActivityDTO dtoObj:dtoList){
                dtoObj.isModified = true;
                break;
            }
            actUpdate.saveAndReturn();
        }       
    }
}
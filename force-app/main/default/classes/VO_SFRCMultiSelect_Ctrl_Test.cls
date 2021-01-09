/**
  * Author   : Rajiv  
  * Purpose  : Test class for VO_SFRCMultiSelect_Ctrl
  */
@isTest
private class VO_SFRCMultiSelect_Ctrl_Test {
	/*
	 * Setup data method
	 */
	@TestSetup
    static void setupData() {
        //SolutionFocusReportingCategory__c records
        List<SolutionFocusReportingCategory__c> listSFRCValues = new List<SolutionFocusReportingCategory__c>();
        listSFRCValues.add(new SolutionFocusReportingCategory__c(Solution_Focus_Reporting_Category_Value__c='Test 01', Active__c=true));
        listSFRCValues.add(new SolutionFocusReportingCategory__c(Solution_Focus_Reporting_Category_Value__c='Test 02', Active__c=true));
        listSFRCValues.add(new SolutionFocusReportingCategory__c(Solution_Focus_Reporting_Category_Value__c='Test 03', Active__c=true));
        insert listSFRCValues;
    } 
    
	/*
	 * Test method to verify SFRC behaviour
	 */
	static testMethod void manageSFRCTest() {
        
        
        
		//Insert Location
        VisitOps__Location__c testLocation = new VisitOps__Location__c(Name='TestLocation',VisitOps__Location_Street_Address__c='testAddress', VisitOps__Time_Zone__c = '(GMT+00:00) Greenwich Mean Time (GMT)',VisitOps__hide_location__c = false); 
        insert testLocation;
        
		//Insert Place
		VisitOps__Place__c testPlace = new VisitOps__Place__c(Name='Test', VisitOps__Location__c=testLocation.Id);
		insert testPlace;
		
        //Create a new Agenda Record
        VisitOps__Room__c testRoom = new VisitOps__Room__c(Name='TestRoom',VisitOps__Location__c=testLocation.id, VisitOps__Place__c=testPlace.Id, VisitOps__Room_Capacity__c=20);
        insert testRoom;
		
        //Insert VisitType
        VisitOps__VisitType__c testCustomerVisit1 = new VisitOps__VisitType__c(Name='TestCustomerVisit1', VisitOps__Category__c='CV1'); 
        insert testCustomerVisit1;
        
        //Create Status - New
        VisitOps__Status__c testNewStatus = new VisitOps__Status__c(Name='New'); 
        insert testNewStatus;
        
        // Create New Visit
        VisitOps__Visit__c visitObj = new VisitOps__Visit__c(VisitOps__Location__c=testLocation.id, VisitOps__Room__c=testRoom.id,VisitOps__VisitName__c='testVisit', VisitOps__VisitOwner__c =userInfo.getUserId(), VisitOps__VisitType__c=testCustomerVisit1.id, VisitOps__VisitStatus__c=testNewStatus.id, VisitOps__VisitStatus__r=testNewStatus, VisitOps__ArrivalDateTime__c=system.now(), VisitOps__DepartureDateTime__c=system.now()+5, VisitOps__TotalNoOfAttendees__c=100, VisitOps__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'), VisitOps__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
		insert visitObj;
		
		//Create Visit Control record.
		VisitOps__Visit_Control__c visitContObj = new VisitOps__Visit_Control__c(VisitOps__VisitControlVisit__c=visitObj.Id);
		insert visitContObj;		
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(visitContObj);
        VO_SFRCMultiSelect_Ctrl controller = new VO_SFRCMultiSelect_Ctrl(sc); 
		
        String strSelRecord = '';
        
		for(SelectOption selObj: controller.listAllValues){
			controller.listSelectedValues.add(selObj);
            
            //controller.listSelectedValues.add(new SelectOption(selObj.Id, selObj.Solution_Focus_Reporting_Category_Name__c));
            
            strSelRecord = strSelRecord + selObj.getValue() + ';';
		}
        
        controller.strRightOptionsHidden = strSelRecord.subString(0, strSelRecord.length()-1);
		controller.saveValues();
        
        test.startTest();
        
		set<String> setSelRecId= new set<String>(strSelRecord.split(';'));
                
        List<SolutionFocusReportingCategory__c> listSFRCValue =[SELECT Solution_Focus_Reporting_Category_Value__c FROM SolutionFocusReportingCategory__c];
        listSFRCValue[0].Solution_Focus_Reporting_Category_Value__c = 'Test 04';
        update listSFRCValue[0];
        delete listSFRCValue[1];
		test.stopTest();
        
        String strRecord = '';
        for(SolutionFocusReportingCategory__c s:[SELECT Solution_Focus_Reporting_Category_Value__c FROM SolutionFocusReportingCategory__c WHERE id IN:setSelRecId]){
        	strRecord = strRecord + s.Solution_Focus_Reporting_Category_Value__c + '; ';    
        }
        strRecord = strRecord.subString(0, strRecord.length()-2);
        VisitOps__Visit__c visitObj1 = [SELECT Solution_Focus_Reporting_Category__c FROM VisitOps__Visit__c LIMIT 1];
        system.assertEquals(strRecord,visitObj1.Solution_Focus_Reporting_Category__c);
       
	}

}
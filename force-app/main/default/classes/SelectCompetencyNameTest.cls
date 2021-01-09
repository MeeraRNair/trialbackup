@isTest
private class SelectCompetencyNameTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [select id from profile where name='System Administrator'];
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId=p.id;
        insert listUserTdf;
        List<Master_Program_Setup__c> listMasterProSetTdf=TestDataFactory.createNMasterProSetup(4);
        for(Master_Program_Setup__c mP : listMasterProSetTdf){
            mP.Certification_Name__c = 'Server';
        }
        listMasterProSetTdf[1].Region__c='EMEA';
        listMasterProSetTdf[2].Region__c='EMEA-EM';
        listMasterProSetTdf[3].Region__c='LATAM';
        insert listMasterProSetTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void selectCompetencyNameTestMethod1(){
        
        /* Profile p = [select id from profile where name='System Administrator'];
User u = new User(alias = 'testSCN', email='testSCN1234@dell.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_US', profileid = p.Id, country='United States',            
timezonesidkey='America/Los_Angeles', username='testSCN1234@noemail.com', 
Badge_Number__c = string.valueof(datetime.now()).replace(':', '').replace('-', '').replace(' ', '') + datetime.now().millisecond());
insert u;

Master_Program_Setup__c testMPS1 = new Master_Program_Setup__c(Master_Program_Name__c='TestMPS1', CompetencyName2__c = 'Server', Certification_Name__c = 'Server', Competency_FName__c='Server', Competency_F1Name__c='Server', Apply_Requirement_To__c='Global', Active__c=true);       
insert testMPS1;

Master_Program_Setup__c testMPS2 = new Master_Program_Setup__c(Master_Program_Name__c='TestMPS2', CompetencyName2__c = 'Server', Certification_Name__c = 'Server', Competency_FName__c='Server', Competency_F1Name__c='Server', Apply_Requirement_To__c='Region', Region__c='EMEA', Active__c=true);       
insert testMPS2;

Master_Program_Setup__c testMPS2b = new Master_Program_Setup__c(Master_Program_Name__c='TestMPS3', CompetencyName2__c = 'Server', Certification_Name__c = 'Server', Competency_FName__c='Server', Competency_F1Name__c='Server', Apply_Requirement_To__c='Region', Region__c='EMEA-EM', Active__c=true);       
insert testMPS2b;

Master_Program_Setup__c testMPS2c = new Master_Program_Setup__c(Master_Program_Name__c='TestMPS4', CompetencyName2__c = 'Server', Certification_Name__c = 'Server', Competency_FName__c='Server', Competency_F1Name__c='Server', Apply_Requirement_To__c='Region', Region__c='LATAM', Active__c=true);       
insert testMPS2c;

System.assertEquals(testMPS1.CompetencyName2__c, 'Server');
System.assertEquals(testMPS1.Apply_Requirement_To__c, 'Global');
System.assertEquals(testMPS2.Apply_Requirement_To__c, 'Region');

System.assertEquals(testMPS2.Region__c, 'EMEA');
System.assertEquals(testMPS2b.Region__c, 'EMEA-EM');
System.assertEquals(testMPS2c.Region__c, 'LATAM');
*/
        list<User> listUser=[select id from User where Profile.name='System Administrator' and isActive=true Limit 1];
        list<Master_Program_Setup__c> listMasterProSetUp=[select id,Master_Program_Name__c, CompetencyName2__c, Certification_Name__c, Competency_FName__c, Region__c, Apply_Requirement_To__c from Master_Program_Setup__c where Certification_Name__c='Server' limit 4];
        listMasterProSetUp[1].Apply_Requirement_To__c='Region';
        listMasterProSetUp[2].Apply_Requirement_To__c='Region';
        listMasterProSetUp[3].Apply_Requirement_To__c='Region';
        update listMasterProSetUp;
        
        List<Master_Program_Setup__c> listmyDS = new List<Master_Program_Setup__c>();
        Master_Program_Setup__c ds1 = [select id, Master_Program_Name__c, CompetencyName2__c, Certification_Name__c, Competency_FName__c, Region__c, Apply_Requirement_To__c from Master_Program_Setup__c where id=:listMasterProSetUp[0].Id limit 1];
        ds1.CompetencyName2__c = 'Storage OR Networking';
        ds1.Certification_Name__c = 'Storage;Networking';
        ds1.Competency_FName__c = 'Storage;Networking';      
        listmyDS.add(ds1);
        
        test.startTest();   
        system.runas(listUser[0]){
            PageReference pageRef1 = Page.SelectComptncyName;              
            pageRef1.getParameters().put('id',listMasterProSetUp[0].Id);
            Test.setCurrentPageReference(pageRef1);
            SelectComptncyNameControler scc1 = new SelectComptncyNameControler();
            scc1.saveCompetency();
            scc1.add();  
            scc1.doReplace();
            scc1.save();
            scc1.saveandclose(); 
            scc1.refreshList();
            scc1.close();      
            scc1.doDelete();        
            
            PageReference pageRef2 = Page.SelectComptncyName; 
            pageRef2.getParameters().put('id',listMasterProSetUp[1].Id);
            pageRef2.getParameters().put('tab','modify');
            Test.setCurrentPageReference(pageRef2);
            SelectComptncyNameControler scc2 = new SelectComptncyNameControler();
            //integer counter = 1;
            //integer wrapperSize = 2;
            //boolean compChecked = true;
            //string competencyName = 'Networking AND';
            //string newCompetency = 'Data Protection';
            //string backToListString='Networking';
            //Boolean operatorRender = true;
            scc2.saveCompetency();
            scc2.add();  
            scc2.doReplace();
            scc2.save();
            scc2.saveandclose(); 
            scc2.refreshList();
            scc2.close();      
            scc2.doDelete();         
            
            PageReference pageRef2b = Page.SelectComptncyName; 
            pageRef2b.getParameters().put('id',listMasterProSetUp[2].Id);
            Test.setCurrentPageReference(pageRef2b);
            SelectComptncyNameControler scc2b = new SelectComptncyNameControler();         
            
            PageReference pageRef2c = Page.SelectComptncyName; 
            pageRef2c.getParameters().put('id',listMasterProSetUp[3].Id);
            Test.setCurrentPageReference(pageRef2c);
            SelectComptncyNameControler scc2c = new SelectComptncyNameControler();         
            
            PageReference pageRef3 = Page.SelectComptncyName;              
            pageRef3.getParameters().put('id',null);
            Test.setCurrentPageReference(pageRef3);
            SelectComptncyNameControler scc3 = new SelectComptncyNameControler();    
            
            update listmyDS;
            
            System.assertEquals(ds1.CompetencyName2__c, 'Storage OR Networking');
            System.assertEquals(ds1.Apply_Requirement_To__c, 'Global');
            System.assertEquals(ds1.Region__c, '--None--');            
        }
        test.stopTest();
    }                            
}
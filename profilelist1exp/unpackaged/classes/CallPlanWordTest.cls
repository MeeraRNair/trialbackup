@isTest
private class CallPlanWordTest {

    static TestMethod void test_CallPlanWordTest(){



        CallPlanWordController controller;

        //Creating new Acccount
        Account acct = new Account(name='TestMethodAccount01');
        insert acct;

        List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];
        User tempUser = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test',
            Email='test1@dell.com',
            FirstName='Tfirst A',
            LastName='TLast',
            ProfileId = userProfile[0].Id,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser;

        RecordType recType = [Select r.Name, r.Id From RecordType r where r.Name = 'Call Plan'];

        Event testEvent = new Event( WhatId = acct.Id,
                                     Type = 'Cust Conf Call/Live Meeting',
                                     RecordTypeId = recType.Id,
                                     OwnerId= tempUser.Id,
                                     Opening_Statement__c = 'Opening_Statement__c',
                                     Next_Steps__c='Next_Steps__c',
                                     Key_Belief_Actions_3__c='Key_Belief_Actions_3__c',
                                     Key_Belief_Actions_2__c='Key_Belief_Actions_2__c',
                                     Key_Belief_Actions_1__c='Key_Belief_Actions_1__c',
                                     Key_Belief_3__c='Key_Belief_3__c',
                                     Key_Belief_2__c='Key_Belief_2__c',
                                     Key_Belief_1__c='Key_Belief_1__c',
                                     End_in_Mind__c = 'End_in_Mind__c',
                                     Yellow_Light_1__c='Yellow_Light_Response_4__c',
                                     Yellow_Light_Response_1__c='Yellow_Light_Response_1__c',
                                     DurationInMinutes = 30,
                                     ActivityDateTime = system.Today() );
        insert testEvent;

        controller = new CallPlanWordController(new ApexPages.StandardController(testEvent) );

        PageReference pr = Page.CallPlanWord;

        ApexPages.currentPage().getParameters().put('id', testEvent.Id);

        Test.setCurrentPage(pr);

        controller.redirectForWord();
        controller.redirectForView();
        controller.redirectForEdit();
        controller.getPrint();
        controller.getAccountName();
        controller.showMoreKeyBeliefFieldSet();
        controller.showMoreQuestionFieldSet();
         controller.showMoreYellowLightFieldSet();
        controller.getDisplayProperty('');

         Event testEvent1 = new Event( WhatId = acct.Id,
                                     Type = 'Cust Conf Call/Live Meeting',
                                     RecordTypeId = recType.Id,
                                     OwnerId= tempUser.Id,
                                     Opening_Statement__c = 'Opening_Statement__c',
                                     Next_Steps__c='Next_Steps__c',
                                     Key_Belief_Actions_1__c='Key_Belief_Actions_1__c',
                                     Key_Belief_1__c='Key_Belief_1__c',
                                     End_in_Mind__c = 'End_in_Mind__c',
                                     Yellow_Light_1__c='Yellow_Light_Response_4__c',
                                     Yellow_Light_Response_1__c='Yellow_Light_Response_1__c',
                                     DurationInMinutes = 30,
                                     ActivityDateTime = system.Today() );
        insert testEvent1;

        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_2__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_2__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_2__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_2__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_3__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_3__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_3__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_3__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_4__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_4__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_4__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_4__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_5__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_5__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_5__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_5__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_6__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_6__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_6__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_6__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_7__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_7__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_7__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_7__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

        testEvent1.Key_Belief_8__c = 'Key_Belief_1__c';
        testEvent1.Key_Belief_Actions_8__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_8__c = 'Key_Belief_1__c';
        testEvent1.Yellow_Light_Response_8__c = 'Key_Belief_1__c';

        update testEvent1;
        executeCurrentPage(testEvent1);

    }

    static void executeCurrentPage(Event testEvent_p){
    	


        CallPlanWordController controller = new CallPlanWordController(new ApexPages.StandardController(testEvent_p) );

        PageReference pr = Page.CallPlanWord;

        ApexPages.currentPage().getParameters().put('id', testEvent_p.Id);

        Test.setCurrentPage(pr);


    }

}
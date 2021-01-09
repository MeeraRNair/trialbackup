/**
 * @author: aidan@nebulaconsulting.co.uk
 * @date: 12/03/2018
 *
 * MIT License
 *
 * Copyright (c) 2018 Aidan Harding, Nebula Consulting
 *
 * Permission Is hereby granted, free of charge, to any person obtaining a copy
 * of this software And associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, And/Or sell
 * copies of the Software, And to permit persons to whom the Software Is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice And this permission notice shall be included in all
 * copies Or substantial portions of the Software.
 *
 * THE SOFTWARE Is PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
 * IMPLIED, INCLUDING BUT Not LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS Or COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES Or OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING FROM,
 * OUT OF Or IN CONNECTION WITH THE SOFTWARE Or THE USE Or OTHER DEALINGS IN THE
 * SOFTWARE.
 */ 
 
@IsTest
Public Class MetadataTriggerManagerTest {

    Public Static Set<String> setLastNamesSeen = New Set<String>();

    Public Class TestHandler Implements AfterDelete, AfterInsert, AfterUndelete, AfterUpdate, BeforeDelete,
            BeforeInsert, BeforeUndelete, BeforeUpdate {

        Public void handleAfterDelete(List<Contact> listOld) {
            handle(listOld);
        }

        Public void handleAfterInsert(List<Contact> listNew) {
            handle(listNew);
        }

        Public void handleAfterUndelete(List<Contact> listNew) {
            handle(listNew);
        }

        Public void handleAfterUpdate(List<sObject> listNew, Map<Id,SObject> mapOld) {
            handle(listNew);
        }

        Public void handleBeforeDelete(List<Contact> listOld) {
            handle(listOld);
        }

        Public void handleBeforeInsert(List<Contact> listNew) {
            handle(listNew);
        }

        Public void handleBeforeUndelete(List<Contact> listNew) {
            handle(listNew);
        }

        Public void handleBeforeUpdate(List<sObject> listNew, Map<Id,SObject> mapOld) {
            handle(listNew);
        }

        Private void handle(List<Contact> listContact) {
            For (Contact c : listContact) {
                MetaDataTriggerManagerTest.setLastNamesSeen.add(c.LastName);
            }
        }
    }

    @IsTest
    Public Static void basic() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = New Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false},
                'AfterInsert' => new List<Boolean>{false, false, true, false, false},
                'AfterUndelete' => new List<Boolean>{false, false, false, false, true},
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
                'BeforeDelete' => new List<Boolean>{true, false, false, true, false},
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
                'BeforeUndelete' => new List<Boolean>{true, false, false, false, true},
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        For (String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "MetaDataTriggerManagerTest.TestHandler"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);

        MetadataTriggerManager manager = New MetadataTriggerManager(Contact.sObjectType);
        
        String strLastName = 'Simpson';

        List<Contact> listContact = New List<Contact>{New Contact(LastName = strLastName)};

        For (String strEvent : mapEvents.keySet()) {
            List<Boolean> listFlags = mapEvents.get(strEvent);
            setLastNamesSeen = New Set<String>();
            manager.handle(listFlags[0], listFlags[1], listFlags[2], listFlags[3], listFlags[4], listContact, listContact, null);

            System.assert(setLastNamesSeen.contains(listContact[0].LastName));
        }

    }
    @IsTest
    Public Static void noSuchHandler() {
        String strMockMetaData = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"Event__c": "AfterUpdate", '
                + '"sObject__c": "Contact", "Class_Name__c": "NoSuchClass"}]';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        MetadataTriggerManager manager = New MetadataTriggerManager(Contact.sObjectType);
        
        String strLastName = 'Simpson';

        List<Contact> listContact = New List<Contact>{New Contact(LastName = strLastName)};

        Try {
            manager.handle(false, true, false, false, false, listContact, listContact, null);
        } catch(MetadataTriggerManager.ClassNotFoundException e) {
            // expected this!
            Return;
        }

        System.assert(false, 'Expected a ClassNotFoundException');
    }

    @IsTest
    Public Static void noHandlers() {
        MetadataTriggerManager.listMockMetaData = New List<Trigger_Handler__mdt>();
        
        MetadataTriggerManager manager = New MetadataTriggerManager(Contact.sObjectType);
        
        String strLastName = 'Simpson';

        List<Contact> listContact = New List<Contact>{New Contact(LastName = strLastName)};

        manager.handle(false, true, false, false, false, listContact, listContact, null);
        // no result
        
        TriggerEventsToTriggerHandlers handler = MetadataTriggerManager.sObjectNameToEventsToTriggerHandlers.get(Contact.sObjectType.getDescribe().getName());
        
        System.assertEquals(null, handler);
    }

    @IsTest
    Public Static void noHandlersForThisEvent() {
        String strMockMetaData = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"Event__c": "AfterUpdate", '
                + '"sObject__c": "Contact", "Class_Name__c": "NoSuchClass"}]';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        MetadataTriggerManager manager = New MetadataTriggerManager(Contact.sObjectType);
        
        String strLastName = 'Simpson';

        List<Contact> listContact = New List<Contact>{New Contact(LastName = strLastName)};

        manager.handle(true, true, false, false, false, listContact, listContact, null);
        // no result
        
        TriggerEventsToTriggerHandlers handler = MetadataTriggerManager.sObjectNameToEventsToTriggerHandlers.get(Contact.sObjectType.getDescribe().getName());      
        System.assertNotEquals(null, handler);
        
        System.assertEquals(null, handler.getTriggerHandlers('BeforeUpdate'));
    }

    @IsTest
    Public Static void queryHandlers() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = New Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false},
                'AfterInsert' => new List<Boolean>{false, false, true, false, false},
                'AfterUndelete' => new List<Boolean>{false, false, false, false, true},
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
                'BeforeDelete' => new List<Boolean>{true, false, false, true, false},
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
                'BeforeUndelete' => new List<Boolean>{true, false, false, false, true},
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        For (String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "MetaDataTriggerManagerTest.TestHandler"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
                
        MetadataTriggerManager manager = New MetadataTriggerManager(Contact.sObjectType);
        
        String strLastName = 'Simpson';

        List<Contact> listContact = New List<Contact>{New Contact(LastName = strLastName)};    
                
        

        manager.handle(false, true, false, false, false, listContact, listContact, null);
        // no result
        //Start - Added by Ashwini -- CR 18197
        TriggerHandler.ExecutionCounter ecObj = New TriggerHandler.ExecutionCounter(1);
        ecObj.isValid();
        ecObj.incrementCounter();
        ecObj.resetCounter();
        TriggerHandler ecObjc = New TriggerHandler();
        Integer intCounter = ecObjc.getExecutionCounter();
        System.debug('****==' + intCounter);
        System.assertEquals(1,intCounter);
        try{        
        ecObjc.run();
        } Catch(Exception e) {
         System.debug('The following exception has occured:' + e.getMessage());        
        
        System.assertEquals('Trigger handler called outside of Trigger execution',e.getMessage());
        }
        //Stop
        TriggerEventsToTriggerHandlers handler = MetadataTriggerManager.sObjectNameToEventsToTriggerHandlers.get(Contact.sObjectType.getDescribe().getName());
        
        System.assertNotEquals(null, handler);
    }
    //Added by shubham bhatt- for covering checkRecursive.OpportunityTrigger_CBORunOnce 
    Static testMethod void getcounter() {
        Test.startTest();

        checkRecursive.OpportunityTrigger_CBORunOnce();
        System.assertNotEquals(null, Limits.getQueries());
        Test.stopTest();
    }
}
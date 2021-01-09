/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InformaticaIntegrationStatsTriggerTest {

    static testMethod void testBeforeInsertTrigger() {
        List<Informatica_Integration_Statistic__c>  statsList = new List<Informatica_Integration_Statistic__c>();
        
        
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Team Feed', Count__c = 741, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Team Feed', Count__c = 852, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Team Feed', Count__c = 963, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'User Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'User Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'User Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Team Feed', Count__c = 741, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Team Feed', Count__c = 852, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Team Feed', Count__c = 963, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'User Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'User Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'User Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now()+2, Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Team Feed', Count__c = 741, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Team Feed', Count__c = 852, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Team Feed', Count__c = 963, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'User Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'User Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'User Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'Account Team Feed', Count__c = 741, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'Account Team Feed', Count__c = 852, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'Account Team Feed', Count__c = 963, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_acctteam_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Pushed', Feed_Name__c = 'User Feed', Count__c = 123, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Rejects', Feed_Name__c = 'User Feed', Count__c = 456, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
        statsList.add(new Informatica_Integration_Statistic__c(Count_Type__c = 'Queued', Feed_Name__c = 'User Feed', Count__c = 789, Work_Flow_End_Date_Time__c = System.now(), Work_Flow_Start_Date_Time__c = System.now(), Work_Flow_Name__c = 'wf_account_inbound'));
                              
        insert statsList;        
    }
}
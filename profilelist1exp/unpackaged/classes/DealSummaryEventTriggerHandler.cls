public class DealSummaryEventTriggerHandler {
    public static void updateDealSummaryRecords(List < Deal_Summary_event__e > listDealSummaryRecords) {
        list < Deal_Summary__c > listDealSummaries = new list < Deal_Summary__c > ();
        OWD__c owd = OWD__c.getOrgDefaults();
        
        for (Deal_Summary_event__e eachRec: listDealSummaryRecords) {
            
            Deal_Summary__c dealSummaryRec = new Deal_Summary__c();
            
            dealSummaryRec.id = eachRec.Deal_Summary_Id__c;
            dealSummaryRec.Account__c = eachRec.Account__c;
            dealSummaryRec.Stage__c = eachRec.stage_name__C;
            dealSummaryRec.Last_Activity_Date__c = eachRec.Last_Activity_Date__c;
            
            if (eachRec.Scheduled_Opportunity__c == null || eachRec.Scheduled_Opportunity__c == false) {
                dealSummaryRec.Scheduled_Opportunity__c = 'No';
            } else {
                dealSummaryRec.Scheduled_Opportunity__c = 'Yes';
            }
            
            if (eachRec.Related_Strategy__c == null) {
                dealSummaryRec.Linked_Strategy__c = 'No';
            } else {
                dealSummaryRec.Linked_Strategy__c = 'Yes';
            }
            
            if (eachRec.Opportunity_Plan__c == null || eachRec.Opportunity_Plan__c == 'N') {
                dealSummaryRec.Opportunity_Plan__c = 'No';
            } else {
                dealSummaryRec.Opportunity_Plan__c = 'Yes';
            }
            
            integer intDaysInStage = 0;
            if (eachRec.Last_Stage_Changed__c != null) {
                intDaysInStage = eachRec.Last_Stage_Changed__c.daysBetween(System.today());
            }
            
            //CR14534 replace hardcoded stage values with OWD custom setting 
            if (eachRec.Old_Stage_Name__c != eachRec.Stage_Name__c) {
                if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage1__c) {
                    if (eachRec.Stage_Plan__c == null) {
                        dealSummaryRec.Stage_Plan__c = 0;
                    }
                    dealSummaryRec.Stage_Plan__c = Integer.valueOf(eachRec.Stage_Plan__c) + intDaysInStage;
                } else if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage10__c) {
                    if (eachRec.Stage_Discover__c == null) {
                        dealSummaryRec.Stage_Discover__c = 0;
                    }
                    dealSummaryRec.Stage_Discover__c = Integer.valueOf(eachRec.Stage_Discover__c) + intDaysInStage;
                } else if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage30__c) {
                    if (eachRec.Stage_Qualify__c == null) {
                        dealSummaryRec.Stage_Qualify__c = 0;
                    }
                    dealSummaryRec.Stage_Qualify__c = Integer.valueOf(eachRec.Stage_Qualify__c) + intDaysInStage;
                } else if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage60__c) {
                    if (eachRec.Stage_Propose__c == null) {
                        dealSummaryRec.Stage_Propose__c = 0;
                    }
                    dealSummaryRec.Stage_Propose__c = Integer.valueOf(eachRec.Stage_Propose__c) + intDaysInStage;
                } else if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage90__c) {
                    if (eachRec.Stage_Commit__c == null) {
                        dealSummaryRec.Stage_Commit__c = 0;
                    }
                    dealSummaryRec.Stage_Commit__c = Integer.valueOf(eachRec.Stage_Commit__c) + intDaysInStage;
                } else if (eachRec.Old_Stage_Name__c == owd.Oppty_Stage99__c) {
                    if (eachRec.Stage_Order_Submitted__c == null) {
                        dealSummaryRec.Stage_Order_Submitted__c = 0;
                    }
                    dealSummaryRec.Stage_Order_Submitted__c = Integer.valueOf(eachRec.Stage_Order_Submitted__c) + intDaysInStage;
                }
                dealSummaryRec.LastStageChanged__c = System.today();
            }
            dealSummaryRec.ForcedCalculation__c = false;
            listDealSummaries.add(dealSummaryRec);
        }
        try {
            update listDealSummaries;
        } catch (DMLException e) {
            system.debug(e);
        }
    }
}
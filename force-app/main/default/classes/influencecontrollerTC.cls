@isTest
public class influencecontrollerTC{
public static testmethod void runICTest() {
        influencecontroller ic = new influencecontroller();
        ic.isTest = true;
        ic.getSnapshots();
        ic.getDepartments();
        ic.calcDepartments();
        ic.changeDept();
        
        ic.sendInfluence();     
        
        // New Inf parent
        Influence_Parent__c ip = new Influence_Parent__c( active__c = true,  maximum_concurrent_batches__c = 5, track_influence_reports__c = true, start_time__c = datetime.now().addMonths(-12), end_time__c = datetime.now() );
        insert ip;
        
        ic = new influencecontroller();
        ic.ipID = ip.id;
        ic.calcDepartments();
        
        if( ic.getDepartments().size() > 1 ) {
            ic.dept = ic.getDepartments().get(1).getLabel();
            ic.changeDept();
        }
        
        system.assertNotEquals( '', ic.updated );
        
        ic.sendInfluence();
        
        Influence_Tracker__c it = [select id from Influence_Tracker__c where success__c = false and influence_snapshot__c = :ip.id and user__c = :userinfo.getuserid() ];
        
        system.assertNotEquals( null, it.id );
        
        // New inf
        Influence__c inf = new Influence__c( influence_parent__c = ip.id, user__c = userinfo.getuserid(), pc_rank__c = 1, cc_rank__c = 1,
            pr_rank__c = 1, cr_rank__c = 1, f_rank__c = 1, ranking__c = 1, aip_rank__c = 1, acd_rank__c = 1, likes_received_rank__c = 1 );
        insert inf;
        
        ic = new influencecontroller();
        
        ic.sendInfluence();
        
        it = [select id from Influence_Tracker__c where success__c = true and influence_snapshot__c = :ip.id and user__c = :userinfo.getuserid() ];
        
        system.assertNotEquals( null, it.id );
    }
}
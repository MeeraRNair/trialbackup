public class OppSplitUtilHelper {
    
    public static void assembleOSDelArray (List<OpportunitySplit> OppSplitDelArray) {
        
        // Display the function
        system.debug('In function assembleOSDelArray now . . .');
        system.debug('Array size: ' + OppSplitDelArray.size());
        system.debug('Array to delete: ' + OppSplitDelArray);
        
        // Prepare variables used to process deletion
        Integer iDelRecords = 0;
        Integer delDTMArraySize = OppSplitDelArray.size();
        Integer rem = math.mod(delDTMArraySize, 100);
        Integer j = 0;
        Double iLoops = (delDTMArraySize/100);
        List<OpportunitySplit> stBatchDelArray = new List<OpportunitySplit>();
        List<OpportunitySplit> stRemDelArray = new List<OpportunitySplit>();
        List<Id>remOID = new Id[100];
        List<Id>remUID = new Id[100];
        
        Integer f = 0;
        
        
        // Loop through deletion array in batches of 100
        if (iLoops >= 1) {
            for (Integer i=0; i<=(iLoops-1); i++) {
                
                string strQuery='select Id from OpportunitySplit where ';
                
                for(integer x=0; x<100; x++){if(OppSplitDelArray[(i*100)+x]!=null)
                        strQuery=strQuery+(x!=0?' OR ':'')+'(OpportunityId = \''+OppSplitDelArray[(i*100)+x].OpportunityId+'\' and SplitOwnerId = \''+OppSplitDelArray[(i*100)+x].SplitOwnerId+'\' and IsDeleted = False)';                 }
                
                system.debug('### strQuery 1: '+strQuery);
            	stBatchDelArray=Database.query(strQuery);
                system.debug('### stRemDelArray: '+stBatchDelArray);

                // Delete the opportunity team member records
                if (stBatchDelArray.size() > 0) {                    
                    try {deleteOTM(stBatchDelArray);}catch (Exception e) {throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage());}
                }
                
                // Clear the array
                stBatchDelArray.clear();
                
                // Set the value of integer j
                j++;
                
                
            }   // End for loop
            
        }   // End if (iLoops >= 1)
        
        
        
        // Display the value of integer i
        system.debug('#### Batch Loop has ended.  Integer j = ' + j);
        
        // Process the remaining records using integer j
        if (rem > 0) {
            // Set the values for the remaining records
            for (Integer k=0; k<rem; k++) {
                remOID.set(k, OppSplitDelArray[(j*100)+k].OpportunityId);
                remUID.set(k, OppSplitDelArray[(j*100)+k].SplitOwnerId);
                f++;}
            
            
            // Initialize the variables for account Id and user Id
            for (Integer m=f; m<100; m++) {
                remOID.set(m, null);
                remUID.set(m, null);}
            
            
            string strQuery='select Id from OpportunitySplit where ';
            
            for(integer i=0; i<100; i++){
                if(remOID[i]!=null &&remUID[i]!=null)
                    strQuery=strQuery+(i!=0?' OR ':'')+'(OpportunityId =\''+remOID[i]+'\' and SplitOwnerId =\''+remUID[i]+'\' and IsDeleted = False)'; 
            }
            system.debug('### strQuery 2: '+strQuery);
            stRemDelArray=Database.query(strQuery);
            system.debug('### stRemDelArray: '+stRemDelArray);
            
            // Delete the account team member records
            if (stRemDelArray.size() > 0) {
                try {deleteOTM(stRemDelArray);}
                catch (Exception e) {throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage());}}
            
            // Clear the remainder deletion array
            stRemDelArray.clear();
            
            // Clear the Id storage arrays
            remOID.clear();
            remUID.clear();
            
            
        }   // End if (rem > 0)
        
        
    }   // End function assembleOTMDelArray()
    
    public static void deleteOTM (List<OpportunitySplit> otDelArray) {        
        
        // Declare variables
        List<CustomResult> crDeleteOTMResults = new List<CustomResult>();
        
        // Check the limits
        DBUtils.CheckLimits(otDelArray, false);
        
        
        // Delete the opportunity team members
        try {crDeleteOTMResults = DBUtils.DatabaseDelete(otDelArray, 'OpportunitySplit', false);}        
        catch (Exception e) {throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage() + ' The input array was ' + otDelArray);}
        
    }   // End function deleteOTM()
    
    
    
}
public class AccountTeamUtilHelper {

    public static void assembleOTMDelArray (List<OpportunityTeamMember> OppTeamDelArray) {

        // Display the function
        system.debug('In function assembleOTMDelArray now . . .');
        system.debug('Array size: ' + OppTeamDelArray.size());
        system.debug('Array to delete: ' + OppTeamDelArray);

        // Prepare variables used to process deletion
        Integer iDelRecords = 0;
        Integer delDTMArraySize = OppTeamDelArray.size();
        Integer rem = math.mod(delDTMArraySize, 100);
        Integer j = 0;
        Double iLoops = (delDTMArraySize/100);
        List<OpportunityTeamMember> stBatchDelArray = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> stRemDelArray = new List<OpportunityTeamMember>();
        List<Id>remOID = new Id[100];
        List<Id>remUID = new Id[100];

        Integer f = 0;


        // Loop through deletion array in batches of 100
        if (iLoops >= 1) {
            for (Integer i=0; i<=(iLoops-1); i++) {
                stBatchDelArray = [
                                    select Id from OpportunityTeamMember where (OpportunityId = :OppTeamDelArray[(i*100)+0].OpportunityId and UserId = :OppTeamDelArray[(i*100)+0].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+1].OpportunityId and UserId = :OppTeamDelArray[(i*100)+1].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+2].OpportunityId and UserId = :OppTeamDelArray[(i*100)+2].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+3].OpportunityId and UserId = :OppTeamDelArray[(i*100)+3].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+4].OpportunityId and UserId = :OppTeamDelArray[(i*100)+4].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+5].OpportunityId and UserId = :OppTeamDelArray[(i*100)+5].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+6].OpportunityId and UserId = :OppTeamDelArray[(i*100)+6].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+7].OpportunityId and UserId = :OppTeamDelArray[(i*100)+7].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+8].OpportunityId and UserId = :OppTeamDelArray[(i*100)+8].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+9].OpportunityId and UserId = :OppTeamDelArray[(i*100)+9].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+10].OpportunityId and UserId = :OppTeamDelArray[(i*100)+10].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+11].OpportunityId and UserId = :OppTeamDelArray[(i*100)+11].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+12].OpportunityId and UserId = :OppTeamDelArray[(i*100)+12].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+13].OpportunityId and UserId = :OppTeamDelArray[(i*100)+13].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+14].OpportunityId and UserId = :OppTeamDelArray[(i*100)+14].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+15].OpportunityId and UserId = :OppTeamDelArray[(i*100)+15].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+16].OpportunityId and UserId = :OppTeamDelArray[(i*100)+16].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+17].OpportunityId and UserId = :OppTeamDelArray[(i*100)+17].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+18].OpportunityId and UserId = :OppTeamDelArray[(i*100)+18].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+19].OpportunityId and UserId = :OppTeamDelArray[(i*100)+19].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+20].OpportunityId and UserId = :OppTeamDelArray[(i*100)+20].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+21].OpportunityId and UserId = :OppTeamDelArray[(i*100)+21].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+22].OpportunityId and UserId = :OppTeamDelArray[(i*100)+22].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+23].OpportunityId and UserId = :OppTeamDelArray[(i*100)+23].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+24].OpportunityId and UserId = :OppTeamDelArray[(i*100)+24].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+25].OpportunityId and UserId = :OppTeamDelArray[(i*100)+25].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+26].OpportunityId and UserId = :OppTeamDelArray[(i*100)+26].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+27].OpportunityId and UserId = :OppTeamDelArray[(i*100)+27].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+28].OpportunityId and UserId = :OppTeamDelArray[(i*100)+28].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+29].OpportunityId and UserId = :OppTeamDelArray[(i*100)+29].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+30].OpportunityId and UserId = :OppTeamDelArray[(i*100)+30].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+31].OpportunityId and UserId = :OppTeamDelArray[(i*100)+31].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+32].OpportunityId and UserId = :OppTeamDelArray[(i*100)+32].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+33].OpportunityId and UserId = :OppTeamDelArray[(i*100)+33].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+34].OpportunityId and UserId = :OppTeamDelArray[(i*100)+34].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+35].OpportunityId and UserId = :OppTeamDelArray[(i*100)+35].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+36].OpportunityId and UserId = :OppTeamDelArray[(i*100)+36].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+37].OpportunityId and UserId = :OppTeamDelArray[(i*100)+37].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+38].OpportunityId and UserId = :OppTeamDelArray[(i*100)+38].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+39].OpportunityId and UserId = :OppTeamDelArray[(i*100)+39].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+40].OpportunityId and UserId = :OppTeamDelArray[(i*100)+40].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+41].OpportunityId and UserId = :OppTeamDelArray[(i*100)+41].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+42].OpportunityId and UserId = :OppTeamDelArray[(i*100)+42].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+43].OpportunityId and UserId = :OppTeamDelArray[(i*100)+43].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+44].OpportunityId and UserId = :OppTeamDelArray[(i*100)+44].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+45].OpportunityId and UserId = :OppTeamDelArray[(i*100)+45].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+46].OpportunityId and UserId = :OppTeamDelArray[(i*100)+46].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+47].OpportunityId and UserId = :OppTeamDelArray[(i*100)+47].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+48].OpportunityId and UserId = :OppTeamDelArray[(i*100)+48].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+49].OpportunityId and UserId = :OppTeamDelArray[(i*100)+49].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+50].OpportunityId and UserId = :OppTeamDelArray[(i*100)+50].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+51].OpportunityId and UserId = :OppTeamDelArray[(i*100)+51].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+52].OpportunityId and UserId = :OppTeamDelArray[(i*100)+52].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+53].OpportunityId and UserId = :OppTeamDelArray[(i*100)+53].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+54].OpportunityId and UserId = :OppTeamDelArray[(i*100)+54].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+55].OpportunityId and UserId = :OppTeamDelArray[(i*100)+55].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+56].OpportunityId and UserId = :OppTeamDelArray[(i*100)+56].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+57].OpportunityId and UserId = :OppTeamDelArray[(i*100)+57].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+58].OpportunityId and UserId = :OppTeamDelArray[(i*100)+58].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+59].OpportunityId and UserId = :OppTeamDelArray[(i*100)+59].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+60].OpportunityId and UserId = :OppTeamDelArray[(i*100)+60].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+61].OpportunityId and UserId = :OppTeamDelArray[(i*100)+61].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+62].OpportunityId and UserId = :OppTeamDelArray[(i*100)+62].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+63].OpportunityId and UserId = :OppTeamDelArray[(i*100)+63].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+64].OpportunityId and UserId = :OppTeamDelArray[(i*100)+64].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+65].OpportunityId and UserId = :OppTeamDelArray[(i*100)+65].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+66].OpportunityId and UserId = :OppTeamDelArray[(i*100)+66].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+67].OpportunityId and UserId = :OppTeamDelArray[(i*100)+67].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+68].OpportunityId and UserId = :OppTeamDelArray[(i*100)+68].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+69].OpportunityId and UserId = :OppTeamDelArray[(i*100)+69].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+70].OpportunityId and UserId = :OppTeamDelArray[(i*100)+70].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+71].OpportunityId and UserId = :OppTeamDelArray[(i*100)+71].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+72].OpportunityId and UserId = :OppTeamDelArray[(i*100)+72].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+73].OpportunityId and UserId = :OppTeamDelArray[(i*100)+73].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+74].OpportunityId and UserId = :OppTeamDelArray[(i*100)+74].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+75].OpportunityId and UserId = :OppTeamDelArray[(i*100)+75].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+76].OpportunityId and UserId = :OppTeamDelArray[(i*100)+76].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+77].OpportunityId and UserId = :OppTeamDelArray[(i*100)+77].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+78].OpportunityId and UserId = :OppTeamDelArray[(i*100)+78].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+79].OpportunityId and UserId = :OppTeamDelArray[(i*100)+79].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+80].OpportunityId and UserId = :OppTeamDelArray[(i*100)+80].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+81].OpportunityId and UserId = :OppTeamDelArray[(i*100)+81].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+82].OpportunityId and UserId = :OppTeamDelArray[(i*100)+82].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+83].OpportunityId and UserId = :OppTeamDelArray[(i*100)+83].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+84].OpportunityId and UserId = :OppTeamDelArray[(i*100)+84].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+85].OpportunityId and UserId = :OppTeamDelArray[(i*100)+85].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+86].OpportunityId and UserId = :OppTeamDelArray[(i*100)+86].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+87].OpportunityId and UserId = :OppTeamDelArray[(i*100)+87].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+88].OpportunityId and UserId = :OppTeamDelArray[(i*100)+88].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+89].OpportunityId and UserId = :OppTeamDelArray[(i*100)+89].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+90].OpportunityId and UserId = :OppTeamDelArray[(i*100)+90].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+91].OpportunityId and UserId = :OppTeamDelArray[(i*100)+91].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+92].OpportunityId and UserId = :OppTeamDelArray[(i*100)+92].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+93].OpportunityId and UserId = :OppTeamDelArray[(i*100)+93].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+94].OpportunityId and UserId = :OppTeamDelArray[(i*100)+94].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+95].OpportunityId and UserId = :OppTeamDelArray[(i*100)+95].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+96].OpportunityId and UserId = :OppTeamDelArray[(i*100)+96].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+97].OpportunityId and UserId = :OppTeamDelArray[(i*100)+97].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+98].OpportunityId and UserId = :OppTeamDelArray[(i*100)+98].UserId and IsDeleted = False)
                                                                            or (OpportunityId = :OppTeamDelArray[(i*100)+99].OpportunityId and UserId = :OppTeamDelArray[(i*100)+99].UserId and IsDeleted = False)
                ];
    
    
                // Delete the opportunity team member records
                if (stBatchDelArray.size() > 0) {
                    
                    try {
                        deleteOTM(stBatchDelArray);
                        system.debug('### no exception ###');
                    }
                    
                    catch (Exception e) {
                        throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage());
                    }
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
                remOID.set(k, OppTeamDelArray[(j*100)+k].OpportunityId);
                remUID.set(k, OppTeamDelArray[(j*100)+k].UserId);

                // Increment the counter
                f++;
            }


            // Initialize the variables for account Id and user Id
            for (Integer m=f; m<100; m++) {
                remOID.set(m, null);
                remUID.set(m, null);
            }


            stRemDelArray = [
                            select Id from OpportunityTeamMember where (OpportunityId = :remOID[0] and UserId = :remUID[0] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[1] and UserId = :remUID[1] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[2] and UserId = :remUID[2] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[3] and UserId = :remUID[3] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[4] and UserId = :remUID[4] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[5] and UserId = :remUID[5] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[6] and UserId = :remUID[6] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[7] and UserId = :remUID[7] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[8] and UserId = :remUID[8] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[9] and UserId = :remUID[9] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[10] and UserId = :remUID[10] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[11] and UserId = :remUID[11] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[12] and UserId = :remUID[12] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[13] and UserId = :remUID[13] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[14] and UserId = :remUID[14] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[15] and UserId = :remUID[15] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[16] and UserId = :remUID[16] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[17] and UserId = :remUID[17] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[18] and UserId = :remUID[18] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[19] and UserId = :remUID[19] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[20] and UserId = :remUID[20] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[21] and UserId = :remUID[21] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[22] and UserId = :remUID[22] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[23] and UserId = :remUID[23] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[24] and UserId = :remUID[24] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[25] and UserId = :remUID[25] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[26] and UserId = :remUID[26] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[27] and UserId = :remUID[27] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[28] and UserId = :remUID[28] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[29] and UserId = :remUID[29] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[30] and UserId = :remUID[30] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[31] and UserId = :remUID[31] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[32] and UserId = :remUID[32] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[33] and UserId = :remUID[33] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[34] and UserId = :remUID[34] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[35] and UserId = :remUID[35] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[36] and UserId = :remUID[36] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[37] and UserId = :remUID[37] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[38] and UserId = :remUID[38] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[39] and UserId = :remUID[39] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[40] and UserId = :remUID[40] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[41] and UserId = :remUID[41] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[42] and UserId = :remUID[42] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[43] and UserId = :remUID[43] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[44] and UserId = :remUID[44] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[45] and UserId = :remUID[45] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[46] and UserId = :remUID[46] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[47] and UserId = :remUID[47] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[48] and UserId = :remUID[48] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[49] and UserId = :remUID[49] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[50] and UserId = :remUID[50] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[51] and UserId = :remUID[51] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[52] and UserId = :remUID[52] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[53] and UserId = :remUID[53] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[54] and UserId = :remUID[54] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[55] and UserId = :remUID[55] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[56] and UserId = :remUID[56] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[57] and UserId = :remUID[57] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[58] and UserId = :remUID[58] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[59] and UserId = :remUID[59] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[60] and UserId = :remUID[60] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[61] and UserId = :remUID[61] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[62] and UserId = :remUID[62] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[63] and UserId = :remUID[63] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[64] and UserId = :remUID[64] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[65] and UserId = :remUID[65] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[66] and UserId = :remUID[66] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[67] and UserId = :remUID[67] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[68] and UserId = :remUID[68] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[69] and UserId = :remUID[69] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[70] and UserId = :remUID[70] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[71] and UserId = :remUID[71] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[72] and UserId = :remUID[72] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[73] and UserId = :remUID[73] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[74] and UserId = :remUID[74] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[75] and UserId = :remUID[75] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[76] and UserId = :remUID[76] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[77] and UserId = :remUID[77] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[78] and UserId = :remUID[78] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[79] and UserId = :remUID[79] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[80] and UserId = :remUID[80] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[81] and UserId = :remUID[81] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[82] and UserId = :remUID[82] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[83] and UserId = :remUID[83] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[84] and UserId = :remUID[84] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[85] and UserId = :remUID[85] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[86] and UserId = :remUID[86] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[87] and UserId = :remUID[87] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[88] and UserId = :remUID[88] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[89] and UserId = :remUID[89] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[90] and UserId = :remUID[90] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[91] and UserId = :remUID[91] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[92] and UserId = :remUID[92] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[93] and UserId = :remUID[93] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[94] and UserId = :remUID[94] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[95] and UserId = :remUID[95] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[96] and UserId = :remUID[96] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[97] and UserId = :remUID[97] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[98] and UserId = :remUID[98] and IsDeleted = False)
                                                                    or (OpportunityId = :remOID[99] and UserId = :remUID[99] and IsDeleted = False)
            ];  
    
    
            // Delete the account team member records
            if (stRemDelArray.size() > 0) {

                try {
                    deleteOTM(stRemDelArray);
                    system.debug('### no exception ###');
                }
                    
                catch (Exception e) {
                    throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage());
                }

            }

    
            // Clear the remainder deletion array
            stRemDelArray.clear();


            // Clear the Id storage arrays
            remOID.clear();
            remUID.clear();


        }   // End if (rem > 0)


    }   // End function assembleOTMDelArray()



    public static void deleteOTM (List<OpportunityTeamMember> otDelArray) {

        // Display the function
        system.debug('#### In function deleteOTM now . . .');
        

        // Declare variables
        List<CustomResult> crDeleteOTMResults = new List<CustomResult>();


        // Check the limits
        DBUtils.CheckLimits(otDelArray, false);


        // Delete the opportunity team members
        try {
            crDeleteOTMResults = DBUtils.DatabaseDelete(otDelArray, 'OpportunityTeamMember', false);
        }
        
        catch (Exception e) {
            throw new dellUtil.DellException('deleteOTM() Exception: ' + e.getMessage() + ' The input array was ' + otDelArray);
        }

    }   // End function deleteOTM()

}
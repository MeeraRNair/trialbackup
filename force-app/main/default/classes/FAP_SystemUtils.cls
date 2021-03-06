global class FAP_SystemUtils {
    global static final String LINE_SEPARATOR = '\n';

    global static void debugLimits(){
        System.debug(
              LINE_SEPARATOR + '##################################################################'
            + LINE_SEPARATOR + 'Limits:'
            + LINE_SEPARATOR + '##################################################################'
            + LINE_SEPARATOR + 'AggregateQueries: ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries()
            + LINE_SEPARATOR + 'Callouts: ' + Limits.getCallouts() + ' of ' + Limits.getLimitCallouts()
            + LINE_SEPARATOR + 'DMLRows: ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows()
            + LINE_SEPARATOR + 'DMLStatements: ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements()
            + LINE_SEPARATOR + 'EmailInvocations: ' + Limits.getEmailInvocations() + ' of ' + Limits.getLimitEmailInvocations()
            + LINE_SEPARATOR + 'FieldsDescribes: ' + Limits.getFieldsDescribes() + ' of ' + Limits.getLimitFieldsDescribes()
            + LINE_SEPARATOR + 'FindSimilarCalls: ' + Limits.getFindSimilarCalls() + ' of ' + Limits.getLimitFindSimilarCalls()
            + LINE_SEPARATOR + 'FutureCalls: ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls()
            + LINE_SEPARATOR + 'HeapSize: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize()
            + LINE_SEPARATOR + 'Queries: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries()
            + LINE_SEPARATOR + 'PicklistDescribes: ' + Limits.getPicklistDescribes() + ' of ' + Limits.getLimitPicklistDescribes()
            + LINE_SEPARATOR + 'QueryRows: ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows()
            + LINE_SEPARATOR + 'RunAs: ' + Limits.getRunAs() + ' of ' + Limits.getLimitRunAs()
            + LINE_SEPARATOR + 'SavepointRollbacks: ' + Limits.getSavepointRollbacks() + ' of ' + Limits.getLimitSavepointRollbacks()
            + LINE_SEPARATOR + 'Savepoints: ' + Limits.getSavepoints() + ' of ' + Limits.getLimitSavepoints()
            + LINE_SEPARATOR + 'ScriptStatements: ' + Limits.getScriptStatements() + ' of ' + Limits.getLimitScriptStatements()
            + LINE_SEPARATOR + 'SoslQueries: ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries()
            );
    }
    
    global static String to18(String the15charID){
        
        final String BASE ='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456';

        the15charID = FAP_StringUtils.trim(the15charID);
        if(FAP_StringUtils.length(the15charID) != 15){
            return the15charID;
        }
        String result = '';
        List<String> chars = null;
        for(integer i = 0; i < 3; i++){
            chars = FAP_StringUtils.toCharArray(FAP_StringUtils.reverse(the15charID.substring(i*5,i*5+5)));
            String binary = '';
            for(String ch : chars){
                binary += Character.isUpperCase(ch) ? '1' : '0';
            }
            result += FAP_StringUtils.charAt(BASE,FAP_NumberUtils.parseInt(binary,2));
        }
        return the15charID + result;
    }


}
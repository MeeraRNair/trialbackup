/* ============================================================
 * Find a Partner Utility Class    
 * ============================================================
 */
global class FAP_InvalidCharacterStringException extends Exception {
 public FAP_InvalidCharacterStringException(list<String> dummy){
        system.debug('Dummy value'+dummy[0]);
    }
}
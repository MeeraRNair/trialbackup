/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_IllegalArgumentException extends Exception {
  public FAP_IllegalArgumentException(list<String> dummy){
        system.debug('Dummy value'+dummy[0]);
    }
    }
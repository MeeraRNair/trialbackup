/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global interface FAP_SObjectPaginatorListener {
    void handlePageChange(List<SObject> newPage);
}
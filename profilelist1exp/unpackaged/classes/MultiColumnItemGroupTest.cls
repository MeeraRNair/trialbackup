@isTest
private class MultiColumnItemGroupTest {

    static testMethod void testColumnCalculations() {
        MultiColumnItemGroup tcig = new MultiColumnItemGroup('foo', new List<String>{'1'}, 1);

        List<Integer> columnSizes = new List<Integer>();
        tcig.populateColumnSizes(columnSizes, 9, 3);
        System.assertEquals(3, columnSizes[0]);
        System.assertEquals(3, columnSizes[1]);
        System.assertEquals(3, columnSizes[2]);

        columnSizes = new List<Integer>();
        tcig.populateColumnSizes(columnSizes, 8, 3);
        System.assertEquals(3, columnSizes[0]);
        System.assertEquals(3, columnSizes[1]);
        System.assertEquals(2, columnSizes[2]);

        columnSizes = new List<Integer>();
        tcig.populateColumnSizes(columnSizes, 7, 3);
        System.assertEquals(3, columnSizes[0]);
        System.assertEquals(2, columnSizes[1]);
        System.assertEquals(2, columnSizes[2]);
    }

    static testMethod void testColumns() {

        MultiColumnItemGroup tcig = null;

        List<String> items = null;
        List<List<String>> columns = null;

        items = new List<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9'};
        tcig = new MultiColumnItemGroup('foo', items, 3);
        columns = tcig.getColumns();

        System.assertEquals( new List<String>{'1','2','3'}, columns.get(0) );
        System.assertEquals( new List<String>{'4','5','6'}, columns.get(1) );
        System.assertEquals( new List<String>{'7','8','9'}, columns.get(2) );

        items = new List<String>{'1', '2', '3', '4', '5', '6', '7', '8'};
        tcig = new MultiColumnItemGroup('foo', items, 3);
        columns = tcig.getColumns();
        System.assertEquals( new List<String>{'1','2','3'}, columns.get(0) );
        System.assertEquals( new List<String>{'4','5','6'}, columns.get(1) );
        System.assertEquals( new List<String>{'7','8'}, columns.get(2) );

        items = new List<String>{'1', '2', '3', '4', '5', '6', '7'};
        tcig = new MultiColumnItemGroup('foo', items, 3);
        columns = tcig.getColumns();
        System.assertEquals( new List<String>{'1','2','3'}, columns.get(0) );
        System.assertEquals( new List<String>{'4','5'}, columns.get(1) );
        System.assertEquals( new List<String>{'6','7'}, columns.get(2) );

    }
}
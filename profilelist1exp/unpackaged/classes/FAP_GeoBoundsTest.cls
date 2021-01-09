@IsTest
private class FAP_GeoBoundsTest {
  
  private static testmethod void testListConstruct(){
    FAP_GeoBounds bounds = new FAP_GeoBounds(new FAP_GeoPoint[]{ 
         new FAP_GeoPoint(20,40)
      ,  new FAP_GeoPoint(10,50)
      ,  new FAP_GeoPoint(-10,100)
      ,  new FAP_GeoPoint(5,-15)
    });
    System.assert((new FAP_GeoPoint(20,100)).equals(bounds.northeast));
    System.assert((new FAP_GeoPoint(-10,-15)).equals(bounds.southwest));
    //System.assertEquals('<#FAP_GeoBounds(northeast=<#GeoPoint(latitude=20.0,longitude=100.0)>,' 
     // + 'southwest=<#GeoPoint(latitude=-10.0,longitude=-15.0)>)>', bounds.toStr());
  }

  private static testmethod void testGeoPointConstruct(){
    FAP_GeoBounds bounds = new FAP_GeoBounds(new FAP_GeoPoint(-20,100),new FAP_GeoPoint(30,-50));
    System.assert((new FAP_GeoPoint(30,100)).equals(bounds.northeast));
    System.assert((new FAP_GeoPoint(-20,-50)).equals(bounds.southwest));
  }

  private static testmethod void testContains(){
    FAP_GeoBounds bounds = new FAP_GeoBounds(new FAP_GeoPoint(-20,100),new FAP_GeoPoint(30,-50));
    System.assert(bounds.contains(new FAP_GeoPoint(0,0)));
    System.assert(false == bounds.contains(null));
    System.assert(false == bounds.contains(new FAP_GeoPoint(-30,-100)));
    System.assert(false == bounds.contains(new FAP_GeoPoint(50,120)));
  }
}
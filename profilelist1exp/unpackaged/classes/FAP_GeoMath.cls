public class FAP_GeoMath {
  
  public static final Double KM_IN_ONE_LATITUDE_DEGREE = 111.132;
  public static final Double MEAN_EARTH_RADIUS_KM = 6371;
  public static final Double PI = 3.1415926535897932384626433832795;
  
  public static FAP_GeoBounds getBounds(FAP_GeoPoint point, Double distanceInKilometers){
    Double distLatDeg = distanceInKilometers/KM_IN_ONE_LATITUDE_DEGREE;
    Double distLngDeg = distLatDeg/Math.cos((point.lat()*PI)/180);
    Double neLat = point.lat()+distLatDeg;
    Double neLng = point.lng()+distLngDeg;
    Double swLat = point.lat()-distLatDeg;
    Double swLng = point.lng()-distLngDeg;
    neLat = (neLat < -90 || neLat > 90) ? 90 : neLat;
    neLng = (neLng < -180 || neLng > 180) ? 180 : neLng;
    swLat = (swLat < -90 || swLat > 90) ? -90 : swLat;
    swLng = (swLng < -180 || swLng > 180) ? -180 : swLng;
    return new FAP_GeoBounds(new FAP_GeoPoint(neLat, neLng),new FAP_GeoPoint(swLat, swLng));
  }
  
  public static Double distanceInKilometers(FAP_GeoPoint point1, FAP_GeoPoint point2){
    if(point1==null || point2==null){
      throw new IllegalArgumentException();
    }
    Double a = 
      Math.pow(Math.sin(((point2.lat() - point1.lat())*(PI/180))/2),2) + 
      Math.cos(point1.latRadians()) * 
      Math.cos(point2.latRadians()) * 
      Math.pow(Math.sin(((point2.lng() - point1.lng())*(PI/180))/2),2);
    return MEAN_EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  } 

}
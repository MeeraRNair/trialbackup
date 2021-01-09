global class FAP_ConversionUtils {

    global static final Double KILOMETERS_IN_ONE_MILE  = 1.609344;

    global static Double convert(Double distance, FAP_UnitOfLength unit, FAP_UnitOfLength convertTo){
        if(distance == null){
            distance = 0;
        }
        Double conversion = 1;
        if(unit == FAP_UnitOfLength.KILOMETERS && convertTo == FAP_UnitOfLength.MILES){
            conversion = 1/KILOMETERS_IN_ONE_MILE;
        } else if(unit == FAP_UnitOfLength.MILES && convertTo == FAP_UnitOfLength.KILOMETERS){
            conversion = KILOMETERS_IN_ONE_MILE;
        }
        return distance * conversion;
    }

}
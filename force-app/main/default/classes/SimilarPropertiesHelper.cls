public with sharing class SimilarPropertiesHelper {
    private static final Decimal PRICE_TOLERANCE = 0.2;
    private static final Integer MAX_RESULTS = 5;

    /**
     * Returns up to 5 properties in the same city with a price within 20% of the given property.
     */
    public static PagedResult getSimilar(Property__c property) {
        Decimal minPrice = property.Price__c * (1 - PRICE_TOLERANCE);
        Decimal maxPrice = property.Price__c * (1 + PRICE_TOLERANCE);

        PagedResult result = new PagedResult();
        result.pageSize = MAX_RESULTS;
        result.pageNumber = 1;
        result.records = [
            SELECT Id, Name, City__c, Price__c, Beds__c, Baths__c
            FROM Property__c
            WHERE
                City__c = :property.City__c
                AND Id != :property.Id
                AND Price__c >= :minPrice
                AND Price__c <= :maxPrice
            WITH USER_MODE
            ORDER BY Price__c
            LIMIT :MAX_RESULTS
        ];
        result.totalItemCount = result.records.size();
        return result;
    }
}
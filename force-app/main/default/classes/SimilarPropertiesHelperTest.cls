@isTest
private class SimilarPropertiesHelperTest {
    @isTest
    static void returnsOnlySimilarPropertiesInSameCity() {
        Property__c base = new Property__c(Name = 'Base', City__c = 'Boston', Price__c = 100000);
        Property__c similar = new Property__c(Name = 'Similar', City__c = 'Boston', Price__c = 110000);
        Property__c tooExpensive = new Property__c(Name = 'Expensive', City__c = 'Boston', Price__c = 500000);
        Property__c otherCity = new Property__c(Name = 'Other', City__c = 'Miami', Price__c = 100000);
        insert new List<Property__c>{ base, similar, tooExpensive, otherCity };

        Test.startTest();
        PagedResult result = SimilarPropertiesHelper.getSimilar(base);
        Test.stopTest();

        System.assertEquals(1, result.records.size(), 'Only one property should match');
        Property__c found = (Property__c) result.records[0];
        System.assertEquals(similar.Id, found.Id, 'The similar property should be returned');
    }
}
@isTest
private with sharing class TestPropertyController {
    @isTest
    static void getPagedPropertyListUsesDefaultPageSizeWhenNull() {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < 15; i++) {
            properties.add(
                new Property__c(
                    Name = 'Test Property ' + i,
                    Price__c = 100000 + i,
                    Beds__c = 2,
                    Baths__c = 1
                )
            );
        }
        insert properties;

        Test.startTest();
        PagedResult result = PropertyController.getPagedPropertyList(
            null,
            null,
            null,
            null,
            null,
            1
        );
        Test.stopTest();

        Assert.areEqual(
            12,
            result.pageSize,
            'Expected default page size of 12 when pageSize is null.'
        );
        Assert.areEqual(
            12,
            result.records.size(),
            'Expected returned records to respect the default page size.'
        );
        Assert.areEqual(
            15,
            result.totalItemCount,
            'Expected totalItemCount to include all matching properties.'
        );
    }
}

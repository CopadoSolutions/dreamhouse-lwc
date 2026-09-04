@IsTest
private class TestSampleDataController {
    @IsTest
    static void importSampleData() {
        Test.startTest();
        SampleDataController.importSampleData();
        Test.stopTest();

        Integer propertyNumber = [SELECT COUNT() FROM Property__c];
        Integer brokerNumber = [SELECT COUNT() FROM Broker__c];
        Integer contactNumber = [SELECT COUNT() FROM Contact];

        Assert.isTrue(propertyNumber > 0, 'Expected properties were created.');
        Assert.isTrue(brokerNumber > 0, 'Expected brokers were created.');
        Assert.isTrue(contactNumber > 0, 'Expected contacts were created.');
    }

    @IsTest
    static void getProductsForOpportunityReturnsActivePreferredProducts() {
        User recommendationUser = createRecommendationUser();
        PermissionSet dreamhousePermissions = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'dreamhouse'
        ];
        insert new PermissionSetAssignment(
            AssigneeId = recommendationUser.Id,
            PermissionSetId = dreamhousePermissions.Id
        );

        System.runAs(recommendationUser) {
            Opportunity opportunity = new Opportunity(
                Name = 'Hardware renewal',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Preferred_Product_Family__c = 'Hardware'
            );
            insert opportunity;

            insert new List<Product2>{
                new Product2(
                    Name = 'Recommended Laptop',
                    ProductCode = 'TEST-LAPTOP',
                    Family = 'Hardware',
                    IsActive = true
                ),
                new Product2(
                    Name = 'Inactive Printer',
                    ProductCode = 'TEST-PRINTER',
                    Family = 'Hardware',
                    IsActive = false
                ),
                new Product2(
                    Name = 'Software Subscription',
                    ProductCode = 'TEST-SOFTWARE',
                    Family = 'Software',
                    IsActive = true
                )
            };

            Test.startTest();
            List<Product2> products = SampleDataController.getProductsForOpportunity(
                opportunity.Id
            );
            Test.stopTest();

            Assert.areEqual(
                1,
                products.size(),
                'Only active products in the preferred family should be returned.'
            );
            Assert.areEqual('Recommended Laptop', products[0].Name);
            Assert.areEqual('Hardware', products[0].Family);
            Assert.isTrue(products[0].IsActive);
        }
    }

    private static User createRecommendationUser() {
        Profile standardUserProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];
        User user = new User(
            Alias = 'product',
            Email = 'product.recommendations@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Recommendations',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'product.recommendations.' +
                DateTime.now().getTime() +
                '@example.com'
        );
        insert user;
        return user;
    }
}

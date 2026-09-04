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
    static void getProductsReturnsProductsSortedByName() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insertProducts();

            Test.startTest();
            List<Product2> products = SampleDataController.getProducts(
                null,
                null,
                null
            );
            Test.stopTest();

            Assert.areEqual(3, products.size(), 'Expected all products.');
            Assert.areEqual('Alpha Router', products[0].Name);
            Assert.areEqual('Beta Support', products[1].Name);
            Assert.areEqual('Gamma Legacy', products[2].Name);
        }
    }

    @IsTest
    static void getProductsAppliesOptionalFilters() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            String family = getFirstActiveProductFamily();
            insertProducts();

            Test.startTest();
            List<Product2> textMatches = SampleDataController.getProducts(
                'SUP-100',
                null,
                null
            );
            List<Product2> inactiveProducts = SampleDataController.getProducts(
                null,
                null,
                false
            );
            List<Product2> familyMatches = SampleDataController.getProducts(
                null,
                family == null ? 'Unused Family' : family,
                null
            );
            List<Product2> combinedMatches = SampleDataController.getProducts(
                'Alpha',
                family,
                true
            );
            Test.stopTest();

            Assert.areEqual(1, textMatches.size(), 'Expected a code match.');
            Assert.areEqual('Beta Support', textMatches[0].Name);
            Assert.areEqual(
                1,
                inactiveProducts.size(),
                'Expected one inactive product.'
            );
            Assert.areEqual('Gamma Legacy', inactiveProducts[0].Name);
            Assert.areEqual(
                family == null ? 0 : 1,
                familyMatches.size(),
                'Expected the family filter to be applied.'
            );
            Assert.areEqual(
                1,
                combinedMatches.size(),
                'Expected one combined match.'
            );
            Assert.areEqual('Alpha Router', combinedMatches[0].Name);
        }
    }

    private static void insertProducts() {
        String family = getFirstActiveProductFamily();
        insert new List<Product2>{
            new Product2(
                Name = 'Gamma Legacy',
                ProductCode = 'LEG-100',
                IsActive = false
            ),
            new Product2(
                Name = 'Alpha Router',
                ProductCode = 'RTR-100',
                Family = family,
                IsActive = true
            ),
            new Product2(
                Name = 'Beta Support',
                ProductCode = 'SUP-100',
                IsActive = true
            )
        };
    }

    private static String getFirstActiveProductFamily() {
        for (
            Schema.PicklistEntry entry : Product2.Family
                .getDescribe()
                .getPicklistValues()
        ) {
            if (entry.isActive()) {
                return entry.getValue();
            }
        }
        return null;
    }
}

@isTest
private class SampleCalculatorTest {
    @isTest
    static void testAdd() {
        SampleCalculator calc = new SampleCalculator();
        System.assertEquals(5, calc.add(2, 3), 'add should return the sum');
    }

    @isTest
    static void testSubtract() {
        SampleCalculator calc = new SampleCalculator();
        System.assertEquals(1, calc.subtract(3, 2), 'subtract should return the difference');
    }

    @isTest
    static void testIsEven() {
        SampleCalculator calc = new SampleCalculator();
        System.assertEquals(true, calc.isEven(4), '4 should be even');
        System.assertEquals(false, calc.isEven(5), '5 should be odd');
    }
}
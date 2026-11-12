public with sharing class SampleCalculator {
    public Integer add(Integer a, Integer b) {
        System.debug('Added here');
        return a + b;
    }

    public Integer subtract(Integer a, Integer b) {
    System.debug('also Added here');
        return a - b;
    }

    public Boolean isEven(Integer value) {
    System.debug('Added here too');
        return Math.mod(value, 2) == 0;
    }
}
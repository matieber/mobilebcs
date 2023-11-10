package com.mobilebcs.domain.predictions;

public class QualificationSessionAverageDispersion {

    private double average;
    private double standardDeviation;

    public QualificationSessionAverageDispersion(double average, double standardDeviation) {
        this.average = average;
        this.standardDeviation = standardDeviation;
    }

    public double getAverage() {
        return average;
    }

    public double getStandardDeviation() {
        return standardDeviation;
    }
}

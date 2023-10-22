package com.mobilebcs.domain.predictions;

import java.sql.Timestamp;

public class QualificationEntity {

    private Long id;
    private Timestamp endDate;
    private Timestamp startDate;

    private QualificationEntity(){}

    public QualificationEntity(Long id, Timestamp endDate, Timestamp startDate) {
        this.id = id;
        this.endDate = endDate;
        this.startDate = startDate;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("LastQualificationEntity{");
        sb.append("id=").append(id);
        sb.append(", endDate=").append(endDate);
        sb.append(", startDate=").append(startDate);
        sb.append('}');
        return sb.toString();
    }
}

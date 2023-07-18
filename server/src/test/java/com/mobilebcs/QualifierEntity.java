
package com.mobilebcs;

public class QualifierEntity {

    private int userId;
    private long qualificationSessionId;
    private long imageSetId;
    private int score;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public long getQualificationSessionId() {
        return qualificationSessionId;
    }

    public void setQualificationSessionId(long qualificationSessionId) {
        this.qualificationSessionId = qualificationSessionId;
    }

    public long getImageSetId() {
        return imageSetId;
    }

    public void setImageSetId(long imageSetId) {
        this.imageSetId = imageSetId;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }
}

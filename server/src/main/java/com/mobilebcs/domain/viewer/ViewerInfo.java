package com.mobilebcs.domain.viewer;

import java.util.Objects;
import javax.validation.Valid;
import javax.validation.constraints.NotNull;

@Valid
public class ViewerInfo {

    private final String sessionId;
    private final String locationCode;
    private final String name;

    public ViewerInfo(@NotNull String sessionId,@NotNull String locationCode,@NotNull String name) {
        this.sessionId = sessionId;
        this.locationCode = locationCode;
        this.name = name;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getLocationCode() {
        return locationCode;
    }

    public String getName() {
        return name;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        ViewerInfo that = (ViewerInfo) o;
        return Objects.equals(sessionId, that.sessionId) && Objects.equals(locationCode, that.locationCode) && Objects.equals(name, that.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(sessionId, locationCode, name);
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("ViewerInfo{");
        sb.append("sessionId='").append(sessionId).append('\'');
        sb.append(", locationCode='").append(locationCode).append('\'');
        sb.append(", name='").append(name).append('\'');
        sb.append('}');
        return sb.toString();
    }
}

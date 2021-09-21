
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for JobActionEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="JobActionEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Render"/&gt;
 *     &lt;enumeration value="SnapshotCreation"/&gt;
 *     &lt;enumeration value="ReportHistoryCreation"/&gt;
 *     &lt;enumeration value="ExecuteQuery"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "JobActionEnum")
@XmlEnum
public enum JobActionEnum {

    @XmlEnumValue("Render")
    RENDER("Render"),
    @XmlEnumValue("SnapshotCreation")
    SNAPSHOT_CREATION("SnapshotCreation"),
    @XmlEnumValue("ReportHistoryCreation")
    REPORT_HISTORY_CREATION("ReportHistoryCreation"),
    @XmlEnumValue("ExecuteQuery")
    EXECUTE_QUERY("ExecuteQuery");
    private final String value;

    JobActionEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static JobActionEnum fromValue(String v) {
        for (JobActionEnum c: JobActionEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

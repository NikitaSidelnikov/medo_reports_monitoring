
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for JobTypeEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="JobTypeEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="User"/&gt;
 *     &lt;enumeration value="System"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "JobTypeEnum")
@XmlEnum
public enum JobTypeEnum {

    @XmlEnumValue("User")
    USER("User"),
    @XmlEnumValue("System")
    SYSTEM("System");
    private final String value;

    JobTypeEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static JobTypeEnum fromValue(String v) {
        for (JobTypeEnum c: JobTypeEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}


package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for DrillthroughType.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="DrillthroughType"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Detail"/&gt;
 *     &lt;enumeration value="List"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "DrillthroughType")
@XmlEnum
public enum DrillthroughType {

    @XmlEnumValue("Detail")
    DETAIL("Detail"),
    @XmlEnumValue("List")
    LIST("List");
    private final String value;

    DrillthroughType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static DrillthroughType fromValue(String v) {
        for (DrillthroughType c: DrillthroughType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

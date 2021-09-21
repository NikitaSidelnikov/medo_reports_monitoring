
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ParameterTypeEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="ParameterTypeEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Boolean"/&gt;
 *     &lt;enumeration value="DateTime"/&gt;
 *     &lt;enumeration value="Integer"/&gt;
 *     &lt;enumeration value="Float"/&gt;
 *     &lt;enumeration value="String"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "ParameterTypeEnum")
@XmlEnum
public enum ParameterTypeEnum {

    @XmlEnumValue("Boolean")
    BOOLEAN("Boolean"),
    @XmlEnumValue("DateTime")
    DATE_TIME("DateTime"),
    @XmlEnumValue("Integer")
    INTEGER("Integer"),
    @XmlEnumValue("Float")
    FLOAT("Float"),
    @XmlEnumValue("String")
    STRING("String");
    private final String value;

    ParameterTypeEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ParameterTypeEnum fromValue(String v) {
        for (ParameterTypeEnum c: ParameterTypeEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

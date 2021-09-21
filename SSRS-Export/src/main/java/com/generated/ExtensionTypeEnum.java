
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ExtensionTypeEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="ExtensionTypeEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Delivery"/&gt;
 *     &lt;enumeration value="Render"/&gt;
 *     &lt;enumeration value="Data"/&gt;
 *     &lt;enumeration value="All"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "ExtensionTypeEnum")
@XmlEnum
public enum ExtensionTypeEnum {

    @XmlEnumValue("Delivery")
    DELIVERY("Delivery"),
    @XmlEnumValue("Render")
    RENDER("Render"),
    @XmlEnumValue("Data")
    DATA("Data"),
    @XmlEnumValue("All")
    ALL("All");
    private final String value;

    ExtensionTypeEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ExtensionTypeEnum fromValue(String v) {
        for (ExtensionTypeEnum c: ExtensionTypeEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

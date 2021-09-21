
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for WeekNumberEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="WeekNumberEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="FirstWeek"/&gt;
 *     &lt;enumeration value="SecondWeek"/&gt;
 *     &lt;enumeration value="ThirdWeek"/&gt;
 *     &lt;enumeration value="FourthWeek"/&gt;
 *     &lt;enumeration value="LastWeek"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "WeekNumberEnum")
@XmlEnum
public enum WeekNumberEnum {

    @XmlEnumValue("FirstWeek")
    FIRST_WEEK("FirstWeek"),
    @XmlEnumValue("SecondWeek")
    SECOND_WEEK("SecondWeek"),
    @XmlEnumValue("ThirdWeek")
    THIRD_WEEK("ThirdWeek"),
    @XmlEnumValue("FourthWeek")
    FOURTH_WEEK("FourthWeek"),
    @XmlEnumValue("LastWeek")
    LAST_WEEK("LastWeek");
    private final String value;

    WeekNumberEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static WeekNumberEnum fromValue(String v) {
        for (WeekNumberEnum c: WeekNumberEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

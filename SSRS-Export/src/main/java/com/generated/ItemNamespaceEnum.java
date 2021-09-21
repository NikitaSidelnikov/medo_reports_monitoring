
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ItemNamespaceEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="ItemNamespaceEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="PathBased"/&gt;
 *     &lt;enumeration value="GUIDBased"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "ItemNamespaceEnum")
@XmlEnum
public enum ItemNamespaceEnum {

    @XmlEnumValue("PathBased")
    PATH_BASED("PathBased"),
    @XmlEnumValue("GUIDBased")
    GUID_BASED("GUIDBased");
    private final String value;

    ItemNamespaceEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ItemNamespaceEnum fromValue(String v) {
        for (ItemNamespaceEnum c: ItemNamespaceEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}


package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for CredentialRetrievalEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="CredentialRetrievalEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Prompt"/&gt;
 *     &lt;enumeration value="Store"/&gt;
 *     &lt;enumeration value="Integrated"/&gt;
 *     &lt;enumeration value="None"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "CredentialRetrievalEnum")
@XmlEnum
public enum CredentialRetrievalEnum {

    @XmlEnumValue("Prompt")
    PROMPT("Prompt"),
    @XmlEnumValue("Store")
    STORE("Store"),
    @XmlEnumValue("Integrated")
    INTEGRATED("Integrated"),
    @XmlEnumValue("None")
    NONE("None");
    private final String value;

    CredentialRetrievalEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static CredentialRetrievalEnum fromValue(String v) {
        for (CredentialRetrievalEnum c: CredentialRetrievalEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

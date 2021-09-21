
package com.generated;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ModelItemTypeEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="ModelItemTypeEnum"&gt;
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string"&gt;
 *     &lt;enumeration value="Model"/&gt;
 *     &lt;enumeration value="EntityFolder"/&gt;
 *     &lt;enumeration value="FieldFolder"/&gt;
 *     &lt;enumeration value="Entity"/&gt;
 *     &lt;enumeration value="Attribute"/&gt;
 *     &lt;enumeration value="Role"/&gt;
 *   &lt;/restriction&gt;
 * &lt;/simpleType&gt;
 * </pre>
 * 
 */
@XmlType(name = "ModelItemTypeEnum")
@XmlEnum
public enum ModelItemTypeEnum {

    @XmlEnumValue("Model")
    MODEL("Model"),
    @XmlEnumValue("EntityFolder")
    ENTITY_FOLDER("EntityFolder"),
    @XmlEnumValue("FieldFolder")
    FIELD_FOLDER("FieldFolder"),
    @XmlEnumValue("Entity")
    ENTITY("Entity"),
    @XmlEnumValue("Attribute")
    ATTRIBUTE("Attribute"),
    @XmlEnumValue("Role")
    ROLE("Role");
    private final String value;

    ModelItemTypeEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ModelItemTypeEnum fromValue(String v) {
        for (ModelItemTypeEnum c: ModelItemTypeEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}

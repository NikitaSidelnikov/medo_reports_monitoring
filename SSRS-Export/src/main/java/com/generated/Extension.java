
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Extension complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Extension"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="ExtensionType" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ExtensionTypeEnum"/&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="LocalizedName" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Visible" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="IsModelGenerationSupported" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Extension", propOrder = {
    "extensionType",
    "name",
    "localizedName",
    "visible",
    "isModelGenerationSupported"
})
public class Extension {

    @XmlElement(name = "ExtensionType", required = true)
    @XmlSchemaType(name = "string")
    protected ExtensionTypeEnum extensionType;
    @XmlElement(name = "Name")
    protected String name;
    @XmlElement(name = "LocalizedName")
    protected String localizedName;
    @XmlElement(name = "Visible")
    protected boolean visible;
    @XmlElement(name = "IsModelGenerationSupported")
    protected boolean isModelGenerationSupported;

    /**
     * Gets the value of the extensionType property.
     * 
     * @return
     *     possible object is
     *     {@link ExtensionTypeEnum }
     *     
     */
    public ExtensionTypeEnum getExtensionType() {
        return extensionType;
    }

    /**
     * Sets the value of the extensionType property.
     * 
     * @param value
     *     allowed object is
     *     {@link ExtensionTypeEnum }
     *     
     */
    public void setExtensionType(ExtensionTypeEnum value) {
        this.extensionType = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the localizedName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLocalizedName() {
        return localizedName;
    }

    /**
     * Sets the value of the localizedName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLocalizedName(String value) {
        this.localizedName = value;
    }

    /**
     * Gets the value of the visible property.
     * 
     */
    public boolean isVisible() {
        return visible;
    }

    /**
     * Sets the value of the visible property.
     * 
     */
    public void setVisible(boolean value) {
        this.visible = value;
    }

    /**
     * Gets the value of the isModelGenerationSupported property.
     * 
     */
    public boolean isIsModelGenerationSupported() {
        return isModelGenerationSupported;
    }

    /**
     * Sets the value of the isModelGenerationSupported property.
     * 
     */
    public void setIsModelGenerationSupported(boolean value) {
        this.isModelGenerationSupported = value;
    }

}

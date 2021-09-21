
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Policies" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfPolicy" minOccurs="0"/&gt;
 *         &lt;element name="InheritParent" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "policies",
    "inheritParent"
})
@XmlRootElement(name = "GetPoliciesResponse")
public class GetPoliciesResponse {

    @XmlElement(name = "Policies")
    protected ArrayOfPolicy policies;
    @XmlElement(name = "InheritParent")
    protected boolean inheritParent;

    /**
     * Gets the value of the policies property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfPolicy }
     *     
     */
    public ArrayOfPolicy getPolicies() {
        return policies;
    }

    /**
     * Sets the value of the policies property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfPolicy }
     *     
     */
    public void setPolicies(ArrayOfPolicy value) {
        this.policies = value;
    }

    /**
     * Gets the value of the inheritParent property.
     * 
     */
    public boolean isInheritParent() {
        return inheritParent;
    }

    /**
     * Sets the value of the inheritParent property.
     * 
     */
    public void setInheritParent(boolean value) {
        this.inheritParent = value;
    }

}

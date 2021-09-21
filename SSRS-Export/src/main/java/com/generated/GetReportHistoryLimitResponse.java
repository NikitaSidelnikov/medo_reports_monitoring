
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
 *         &lt;element name="HistoryLimit" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="IsSystem" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="SystemLimit" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
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
    "historyLimit",
    "isSystem",
    "systemLimit"
})
@XmlRootElement(name = "GetReportHistoryLimitResponse")
public class GetReportHistoryLimitResponse {

    @XmlElement(name = "HistoryLimit")
    protected int historyLimit;
    @XmlElement(name = "IsSystem")
    protected boolean isSystem;
    @XmlElement(name = "SystemLimit")
    protected int systemLimit;

    /**
     * Gets the value of the historyLimit property.
     * 
     */
    public int getHistoryLimit() {
        return historyLimit;
    }

    /**
     * Sets the value of the historyLimit property.
     * 
     */
    public void setHistoryLimit(int value) {
        this.historyLimit = value;
    }

    /**
     * Gets the value of the isSystem property.
     * 
     */
    public boolean isIsSystem() {
        return isSystem;
    }

    /**
     * Sets the value of the isSystem property.
     * 
     */
    public void setIsSystem(boolean value) {
        this.isSystem = value;
    }

    /**
     * Gets the value of the systemLimit property.
     * 
     */
    public int getSystemLimit() {
        return systemLimit;
    }

    /**
     * Sets the value of the systemLimit property.
     * 
     */
    public void setSystemLimit(int value) {
        this.systemLimit = value;
    }

}


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
 *         &lt;element name="CacheReport" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;choice&gt;
 *           &lt;element name="ScheduleExpiration" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleExpiration" minOccurs="0"/&gt;
 *           &lt;element name="TimeExpiration" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}TimeExpiration" minOccurs="0"/&gt;
 *         &lt;/choice&gt;
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
    "cacheReport",
    "scheduleExpiration",
    "timeExpiration"
})
@XmlRootElement(name = "GetCacheOptionsResponse")
public class GetCacheOptionsResponse {

    @XmlElement(name = "CacheReport")
    protected boolean cacheReport;
    @XmlElement(name = "ScheduleExpiration")
    protected ScheduleExpiration scheduleExpiration;
    @XmlElement(name = "TimeExpiration")
    protected TimeExpiration timeExpiration;

    /**
     * Gets the value of the cacheReport property.
     * 
     */
    public boolean isCacheReport() {
        return cacheReport;
    }

    /**
     * Sets the value of the cacheReport property.
     * 
     */
    public void setCacheReport(boolean value) {
        this.cacheReport = value;
    }

    /**
     * Gets the value of the scheduleExpiration property.
     * 
     * @return
     *     possible object is
     *     {@link ScheduleExpiration }
     *     
     */
    public ScheduleExpiration getScheduleExpiration() {
        return scheduleExpiration;
    }

    /**
     * Sets the value of the scheduleExpiration property.
     * 
     * @param value
     *     allowed object is
     *     {@link ScheduleExpiration }
     *     
     */
    public void setScheduleExpiration(ScheduleExpiration value) {
        this.scheduleExpiration = value;
    }

    /**
     * Gets the value of the timeExpiration property.
     * 
     * @return
     *     possible object is
     *     {@link TimeExpiration }
     *     
     */
    public TimeExpiration getTimeExpiration() {
        return timeExpiration;
    }

    /**
     * Sets the value of the timeExpiration property.
     * 
     * @param value
     *     allowed object is
     *     {@link TimeExpiration }
     *     
     */
    public void setTimeExpiration(TimeExpiration value) {
        this.timeExpiration = value;
    }

}

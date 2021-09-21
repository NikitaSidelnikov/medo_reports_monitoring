
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for WeeklyRecurrence complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="WeeklyRecurrence"&gt;
 *   &lt;complexContent&gt;
 *     &lt;extension base="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}RecurrencePattern"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="WeeksInterval" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *         &lt;element name="DaysOfWeek" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DaysOfWeekSelector" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/extension&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WeeklyRecurrence", propOrder = {
    "weeksInterval",
    "daysOfWeek"
})
public class WeeklyRecurrence
    extends RecurrencePattern
{

    @XmlElement(name = "WeeksInterval")
    protected Integer weeksInterval;
    @XmlElement(name = "DaysOfWeek")
    protected DaysOfWeekSelector daysOfWeek;

    /**
     * Gets the value of the weeksInterval property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getWeeksInterval() {
        return weeksInterval;
    }

    /**
     * Sets the value of the weeksInterval property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setWeeksInterval(Integer value) {
        this.weeksInterval = value;
    }

    /**
     * Gets the value of the daysOfWeek property.
     * 
     * @return
     *     possible object is
     *     {@link DaysOfWeekSelector }
     *     
     */
    public DaysOfWeekSelector getDaysOfWeek() {
        return daysOfWeek;
    }

    /**
     * Sets the value of the daysOfWeek property.
     * 
     * @param value
     *     allowed object is
     *     {@link DaysOfWeekSelector }
     *     
     */
    public void setDaysOfWeek(DaysOfWeekSelector value) {
        this.daysOfWeek = value;
    }

}

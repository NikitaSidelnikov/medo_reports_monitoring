
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * <p>Java class for ScheduleDefinition complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ScheduleDefinition"&gt;
 *   &lt;complexContent&gt;
 *     &lt;extension base="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleDefinitionOrReference"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="StartDateTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/&gt;
 *         &lt;element name="EndDate" type="{http://www.w3.org/2001/XMLSchema}dateTime" minOccurs="0"/&gt;
 *         &lt;choice&gt;
 *           &lt;element name="MonthlyDOWRecurrence" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}MonthlyDOWRecurrence" minOccurs="0"/&gt;
 *           &lt;element name="MinuteRecurrence" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}MinuteRecurrence" minOccurs="0"/&gt;
 *           &lt;element name="DailyRecurrence" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DailyRecurrence" minOccurs="0"/&gt;
 *           &lt;element name="WeeklyRecurrence" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}WeeklyRecurrence" minOccurs="0"/&gt;
 *           &lt;element name="MonthlyRecurrence" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}MonthlyRecurrence" minOccurs="0"/&gt;
 *         &lt;/choice&gt;
 *       &lt;/sequence&gt;
 *     &lt;/extension&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ScheduleDefinition", propOrder = {
    "startDateTime",
    "endDate",
    "monthlyDOWRecurrence",
    "minuteRecurrence",
    "dailyRecurrence",
    "weeklyRecurrence",
    "monthlyRecurrence"
})
public class ScheduleDefinition
    extends ScheduleDefinitionOrReference
{

    @XmlElement(name = "StartDateTime", required = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar startDateTime;
    @XmlElement(name = "EndDate")
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar endDate;
    @XmlElement(name = "MonthlyDOWRecurrence")
    protected MonthlyDOWRecurrence monthlyDOWRecurrence;
    @XmlElement(name = "MinuteRecurrence")
    protected MinuteRecurrence minuteRecurrence;
    @XmlElement(name = "DailyRecurrence")
    protected DailyRecurrence dailyRecurrence;
    @XmlElement(name = "WeeklyRecurrence")
    protected WeeklyRecurrence weeklyRecurrence;
    @XmlElement(name = "MonthlyRecurrence")
    protected MonthlyRecurrence monthlyRecurrence;

    /**
     * Gets the value of the startDateTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getStartDateTime() {
        return startDateTime;
    }

    /**
     * Sets the value of the startDateTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setStartDateTime(XMLGregorianCalendar value) {
        this.startDateTime = value;
    }

    /**
     * Gets the value of the endDate property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getEndDate() {
        return endDate;
    }

    /**
     * Sets the value of the endDate property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setEndDate(XMLGregorianCalendar value) {
        this.endDate = value;
    }

    /**
     * Gets the value of the monthlyDOWRecurrence property.
     * 
     * @return
     *     possible object is
     *     {@link MonthlyDOWRecurrence }
     *     
     */
    public MonthlyDOWRecurrence getMonthlyDOWRecurrence() {
        return monthlyDOWRecurrence;
    }

    /**
     * Sets the value of the monthlyDOWRecurrence property.
     * 
     * @param value
     *     allowed object is
     *     {@link MonthlyDOWRecurrence }
     *     
     */
    public void setMonthlyDOWRecurrence(MonthlyDOWRecurrence value) {
        this.monthlyDOWRecurrence = value;
    }

    /**
     * Gets the value of the minuteRecurrence property.
     * 
     * @return
     *     possible object is
     *     {@link MinuteRecurrence }
     *     
     */
    public MinuteRecurrence getMinuteRecurrence() {
        return minuteRecurrence;
    }

    /**
     * Sets the value of the minuteRecurrence property.
     * 
     * @param value
     *     allowed object is
     *     {@link MinuteRecurrence }
     *     
     */
    public void setMinuteRecurrence(MinuteRecurrence value) {
        this.minuteRecurrence = value;
    }

    /**
     * Gets the value of the dailyRecurrence property.
     * 
     * @return
     *     possible object is
     *     {@link DailyRecurrence }
     *     
     */
    public DailyRecurrence getDailyRecurrence() {
        return dailyRecurrence;
    }

    /**
     * Sets the value of the dailyRecurrence property.
     * 
     * @param value
     *     allowed object is
     *     {@link DailyRecurrence }
     *     
     */
    public void setDailyRecurrence(DailyRecurrence value) {
        this.dailyRecurrence = value;
    }

    /**
     * Gets the value of the weeklyRecurrence property.
     * 
     * @return
     *     possible object is
     *     {@link WeeklyRecurrence }
     *     
     */
    public WeeklyRecurrence getWeeklyRecurrence() {
        return weeklyRecurrence;
    }

    /**
     * Sets the value of the weeklyRecurrence property.
     * 
     * @param value
     *     allowed object is
     *     {@link WeeklyRecurrence }
     *     
     */
    public void setWeeklyRecurrence(WeeklyRecurrence value) {
        this.weeklyRecurrence = value;
    }

    /**
     * Gets the value of the monthlyRecurrence property.
     * 
     * @return
     *     possible object is
     *     {@link MonthlyRecurrence }
     *     
     */
    public MonthlyRecurrence getMonthlyRecurrence() {
        return monthlyRecurrence;
    }

    /**
     * Sets the value of the monthlyRecurrence property.
     * 
     * @param value
     *     allowed object is
     *     {@link MonthlyRecurrence }
     *     
     */
    public void setMonthlyRecurrence(MonthlyRecurrence value) {
        this.monthlyRecurrence = value;
    }

}

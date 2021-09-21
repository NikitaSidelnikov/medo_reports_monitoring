
package com.generated;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfModelPerspective complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfModelPerspective"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="ModelPerspective" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ModelPerspective" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfModelPerspective", propOrder = {
    "modelPerspective"
})
public class ArrayOfModelPerspective {

    @XmlElement(name = "ModelPerspective", nillable = true)
    protected List<ModelPerspective> modelPerspective;

    /**
     * Gets the value of the modelPerspective property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the modelPerspective property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getModelPerspective().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ModelPerspective }
     * 
     * 
     */
    public List<ModelPerspective> getModelPerspective() {
        if (modelPerspective == null) {
            modelPerspective = new ArrayList<ModelPerspective>();
        }
        return this.modelPerspective;
    }

}

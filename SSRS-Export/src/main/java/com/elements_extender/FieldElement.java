package com.elements_extender;

import com.generated.ReportParameter;
import javafx.scene.control.TextField;


public class FieldElement extends ParamElement {

    private final TextField paramField;

    public FieldElement(ReportParameter param) {
        this.param = param;
        paramField = new TextField();
        paramField.textProperty().addListener((observableValue, s, t1) -> setValue(paramField.getText()));

        this.initialize();
        this.addElement(paramField);
    }

    @Override
    public void setDestinationValue(String paramValue) {
        this.paramValue = paramValue;
        paramField.setText(paramValue);
    }


    private void setValue(String paramValue){
        modified = true;
        if (!paramValue.isEmpty())
            this.paramValue = paramValue;
    }
}


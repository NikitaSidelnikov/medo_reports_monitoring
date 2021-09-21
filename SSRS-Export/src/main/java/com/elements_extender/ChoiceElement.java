package com.elements_extender;

import com.elements_extender.auxiliary_classes.FilterComboBox;
import com.elements_extender.auxiliary_classes.MapConverter;
import com.generated.ReportParameter;
import com.generated.ValidValue;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.scene.control.*;


import java.util.List;

public class ChoiceElement extends ParamElement {

    private final FilterComboBox<ValidValue> paramChoice = new FilterComboBox<>();
    private ValidValue selectedValidValue = null;
    private boolean updatingFlag = false;
    private boolean clearingSelection = false;

    public ChoiceElement(ReportParameter param) {
        setParam(param);

        paramChoice.setDefaultVisibleRowCount(10);
        paramChoice.setStrictCompare(false);
        paramChoice.getStylesheets().add("fxml/style.css");

        paramChoice.setPlaceholder(new Label("Nothing"));

        paramChoice.setConverter(new MapConverter());

        paramChoice.selectedValueProperty().addListener((observableValue, validValue, newValidValue) -> {
            setValue(newValidValue);
        });

        this.initialize();
        this.addElement(paramChoice);
    }

    private void setValue(ValidValue paramValue){
        modified = true;
        if(paramValue != null)
            this.paramValue = paramValue.getValue();
    }

    @Override
    public void setParam(ReportParameter param) {
        this.param = param;

        paramChoice.getItems().clear();
        if(param.getValidValues() != null) {
            final List<ValidValue> validValues = param.getValidValues().getValidValue();
            paramChoice.updateList(validValues);
        }
    }

    @Override
    public void setDestinationValue(String paramValue) {
        this.paramValue = paramValue;
        for(ValidValue validValue : paramChoice.getItems()){
            if(validValue.getValue().equals(paramValue)) {
                paramChoice.setValue(validValue);
                return;
            }
        }
        this.paramValue = null;
    }

}
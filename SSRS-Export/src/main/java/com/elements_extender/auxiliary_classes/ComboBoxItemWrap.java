package com.elements_extender.auxiliary_classes;

import com.generated.ValidValue;
import javafx.beans.property.BooleanProperty;
import javafx.beans.property.SimpleBooleanProperty;

public class ComboBoxItemWrap  {
    private final BooleanProperty check = new SimpleBooleanProperty(false);
    private final ValidValue validValue;

    public ComboBoxItemWrap(ValidValue validValue) {
        this.validValue = validValue;
    }

    public BooleanProperty getCheckProperty() {
        return check;
    }
    public void setCheckProperty(boolean checkBoolean) { check.set(checkBoolean); }

    public String getValue() {
        return validValue.getValue();
    }

    public String getLabel() {
        return validValue.getLabel();
    }

    public boolean getCheck() {
        return check.getValue();
    }
}

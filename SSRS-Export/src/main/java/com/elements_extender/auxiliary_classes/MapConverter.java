package com.elements_extender.auxiliary_classes;

import com.generated.ValidValue;
import javafx.util.StringConverter;

public class MapConverter extends StringConverter<ValidValue> {
    @Override
    public String toString(ValidValue validValue) {
        return validValue != null ? validValue.getLabel() : null;
    }

    @Override
    public ValidValue fromString(String validValueAsString) {
        final ValidValue validValue = new ValidValue();
        validValue.setLabel(validValueAsString);
        return validValue;
    }
}
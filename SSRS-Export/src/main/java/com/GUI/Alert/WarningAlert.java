package com.GUI.Alert;

import javafx.scene.control.Alert;
import javafx.scene.control.TextArea;

public class WarningAlert {
    public void show(String message) {
        Alert alert = new Alert(Alert.AlertType.WARNING);

        alert.setHeight(200);
        alert.setWidth(300);
        alert.setTitle("Warning alert");
        alert.getDialogPane().setContent(new TextArea(message));
        alert.setHeaderText(null);
        alert.showAndWait();
    }
}

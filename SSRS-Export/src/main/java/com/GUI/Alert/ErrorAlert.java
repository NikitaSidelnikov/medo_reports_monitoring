package com.GUI.Alert;

import javafx.scene.control.Alert;
import javafx.scene.control.TextArea;

public class ErrorAlert {

    public static void show(Exception e){
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle("Exception error");
        alert.getDialogPane().setContent(new TextArea(String.valueOf(e)));

        alert.getDialogPane().setMaxHeight(300);
        alert.getDialogPane().setMaxWidth(400);

        alert.show();

        e.printStackTrace();
    }

    public static void show(String s) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle("Exception error");
        alert.getDialogPane().setContent(new TextArea(s));

        alert.getDialogPane().setMaxHeight(300);
        alert.getDialogPane().setMaxWidth(400);

        alert.show();
    }
}

package com.Controller;

import com.AppProperties;
import javafx.fxml.FXML;
import javafx.scene.control.CheckBox;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;


public class AuthController {
    @FXML
    public TextField login;
    public PasswordField psw;
    public CheckBox rememberUserCB;
    //public Label error;

    public AuthController() {
    }

    public void initialize() {
        final String username = AppProperties.getUsername();

        //login.setPromptText(System.getProperty("user.name"));
        if(!username.equals("null")) {
            login.setText(username);
            rememberUserCB.setSelected(true);
        }
        else
            rememberUserCB.setSelected(false);
    }

    public String getPsw() {
        if(psw.getText() != null)
            return psw.getText();
        return null;
    }

    public String getLogin() {
        if(login.getText() != null)
            return login.getText();
        return null;
    }

/*    public void setVisibleError(){
        error.setVisible(true);
    }*/

    public boolean getRememberUserCB() {
        return rememberUserCB.isSelected();
    }

    public void hideCheckBox() {
        rememberUserCB.setVisible(false);
    }
}

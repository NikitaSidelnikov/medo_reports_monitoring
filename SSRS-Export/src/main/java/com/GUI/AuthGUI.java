package com.GUI;

import com.AppProperties;
import com.Client.Client;
import com.Controller.AuthController;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.control.ButtonType;
import javafx.scene.control.Dialog;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.Optional;

public class AuthGUI {

    private final Stage stage;
    private final Client client = new Client();
    private String url;
    private final AuthController authController = new AuthController();

    public AuthGUI(Stage stage){
        this.stage = stage;
    }

    public AuthGUI(Stage stage, String url) {
        this.stage = stage;
        this.url = url;
    }

    /* Set function for auth */
    public boolean authorization() throws IOException {
        boolean successAuth = false;
        boolean checkCloseAuth = false;
        while(!successAuth){ // wait until the authorization is completed successfully
            checkCloseAuth = authorizationWindow();
            if(checkCloseAuth)
                break; // waiting for authorization stops, if the auth window was closed
            if(url!=null)
                client.setURL(url);
            successAuth = client.clientAuthorization(authController.getLogin(), authController.getPsw());

            //controller.editStatus("Ошибка входа: введены неверные логин или пароль", "#941107");
        }
        return !checkCloseAuth;
    }

    /* Create auth page */
    @FXML
    public boolean authorizationWindow() throws IOException {
        final Dialog<ButtonType> dialog = new Dialog<>();
        dialog.initOwner(stage.getScene().getWindow());
        dialog.setTitle("Authentication");
        final FXMLLoader fxmlLoader = new FXMLLoader();
        fxmlLoader.setLocation(getClass().getResource("/fxml/authScene.fxml"));

        fxmlLoader.setController(authController);

        dialog.getDialogPane().setContent(fxmlLoader.load());
        dialog.getDialogPane().getButtonTypes().add(ButtonType.OK);
        if(url!=null)
            authController.hideCheckBox();

        final Optional<ButtonType> result = dialog.showAndWait();

        if(url==null) {
            if (authController.getRememberUserCB() && authController.getLogin().length() != 0)
                AppProperties.setUsername(authController.getLogin());
            else
                AppProperties.setUsername("null");
            AppProperties.saveProperties();
        }
        return result.isEmpty() || result.get() != ButtonType.OK;
    }

}

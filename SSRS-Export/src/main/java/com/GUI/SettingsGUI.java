package com.GUI;

import com.Controller.SettingsController;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import java.net.URL;

public class SettingsGUI {

    public void initialize(){
        /* Create sett page */
        final FXMLLoader loader = new FXMLLoader();
        final URL xmlUrl = getClass().getResource("/fxml/settScene.fxml");
        final Stage settStage = new Stage();

        settStage.setResizable(false);

        /*InputStream iconStream = getClass().getResourceAsStream("/icon.png");
        Image image = null;
        if (iconStream != null) {
            image = new Image(iconStream);
            primaryStage.getIcons().add(image);
        }*/

        final SettingsController settingsController = new SettingsController(settStage);
        loader.setController(settingsController);
        loader.setLocation(xmlUrl);
        Parent root;
        try {
            root = loader.load();
            settStage.setScene(new Scene(root));
            settStage.setTitle("Settings");
            settStage.show();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

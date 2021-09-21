package com.GUI;

import com.Controller.Controller;
import javafx.application.Application;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import javafx.fxml.FXMLLoader;
import javafx.stage.StageStyle;

import java.io.InputStream;
import java.net.URL;

public class GUI extends Application{

    public static void main(String[] args) {
        launch(args);
    }

    /* Start Application. Create Authorization window */
    @Override
    public void start(Stage primaryStage) throws Exception {
        /* Create primary page */
        final FXMLLoader loader = new FXMLLoader();
        final URL xmlUrl = getClass().getResource("/fxml/mainScene.fxml");

        final InputStream iconStream = getClass().getResourceAsStream("/icon.png");
        Image image;
        if (iconStream != null) {
            image = new Image(iconStream);
            primaryStage.getIcons().add(image);
        }


        final Controller controller = new Controller( this, primaryStage);
        loader.setController(controller);
        loader.setLocation(xmlUrl);
        final Parent root = loader.load();
        primaryStage.setScene(new Scene(root));
        primaryStage.initStyle(StageStyle.DECORATED);
        primaryStage.setTitle("Reporting service export");
        primaryStage.setMinHeight(350);
        primaryStage.setMinWidth(550);
        primaryStage.show();

        /* Create auth page */
        final AuthGUI authGUI = new AuthGUI(primaryStage);
        if(authGUI.authorization())
            controller.loadController(); //if authorization is completed successfully
        else
            controller.loadControllerWithoutClient(); //else start authorization by pressing the "Export" button
    }

    public void createSettWindow() {
        (new SettingsGUI()).initialize();
    }

}

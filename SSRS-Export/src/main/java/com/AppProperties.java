package com;

import com.GUI.Alert.ErrorAlert;

import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.File;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class AppProperties {

    private static String URL;
    private static String FORMAT_EXPORT;
    private static String SAVE_PATH;
    private static Boolean FILE_OPENING;
    private static String USERNAME;

    private final static Map<String, Integer> propStatus = new HashMap<>();

    public static String getUrl() {
        return URL;
    }
    public static String getFormat() {
        return FORMAT_EXPORT;
    }
    public static String getSavePath() {
        return SAVE_PATH;
    }
    public static Boolean getFileOpening() {
        return FILE_OPENING;
    }
    public static String getUsername() { return USERNAME; }

    public static void setUrl(String UrlSSRS) {
        AppProperties.URL = UrlSSRS;
    }
    public static void setFormat(String FORMAT) {
        AppProperties.FORMAT_EXPORT = FORMAT;
    }
    public static void setSavePath(String PATH_SAVE) {
        AppProperties.SAVE_PATH = PATH_SAVE;
    }
    public static void setFileOpening(Boolean OPEN_FILE) {
        AppProperties.FILE_OPENING = OPEN_FILE;
    }
    public static void setUsername(String USERNAME) { AppProperties.USERNAME = USERNAME; }

    public static void setPropStatus(String propName, int code) {
        propStatus.put(propName, code);
    }
    public static int getPropStatus(String propName) {
        return propStatus.get(propName);
    }

    public static String getPropCheckerErr() {
        for(Map.Entry<String, Integer> item : propStatus.entrySet()){
            if(item.getValue() == 3)
                return item.getKey();
        }
        return null;
    }

    public static void loadProperties(){
           /*
            code 1 - no changes
            code 2 - was changed
            code 3 - was changed with error
         */
        propStatus.put("UrlSSRS", 1);
        propStatus.put("FORMAT", 1);
        propStatus.put("PATH_SAVE", 1);
        propStatus.put("OPEN_FILE", 1);
        propStatus.put("USERNAME", 1);

        FileInputStream fis;
        Properties property = new Properties();

        checkLocalPropFile();

        try {
            fis = new FileInputStream(System.getProperty("user.home") + "/.ssrsexport/config.properties");

            property.load(fis);

            URL = property.getProperty("URL");
            FORMAT_EXPORT = property.getProperty("FORMAT_EXPORT");
            SAVE_PATH = property.getProperty("SAVE_PATH");
            FILE_OPENING = Boolean.valueOf(property.getProperty("FILE_OPENING"));
            USERNAME = property.getProperty("USERNAME");

            fis.close();
        } catch (IOException e) {
            ErrorAlert.show(e);
        }
    }

    public static void saveProperties() {
        FileOutputStream fis;
        Properties property = new Properties();
        checkLocalPropFile();

        try {
            fis = new FileOutputStream(System.getProperty("user.home") + "/.ssrsexport/config.properties");

            property.setProperty("URL", URL);
            property.setProperty("FORMAT_EXPORT", FORMAT_EXPORT);
            property.setProperty("SAVE_PATH", SAVE_PATH);
            property.setProperty("FILE_OPENING", String.valueOf(FILE_OPENING));
            property.setProperty("USERNAME", String.valueOf(USERNAME));
            property.store(fis, "Properties");
            fis.close();
        } catch (IOException e) {
            ErrorAlert.show(e);
        }
    }

    private static void checkLocalPropFile() {
        File folder = new File(System.getProperty("user.home") + "/.ssrsexport");
        folder.mkdirs();
        File file = new File(System.getProperty("user.home") + "/.ssrsexport/config.properties");
        if (!file.exists()) {
            try (InputStream in =
                         AppProperties.class.getResourceAsStream("/config.properties")) {
                if (in != null)
                    Files.copy(in, file.toPath());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

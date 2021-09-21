package com;
import com.GUI.GUI;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.FileNotFoundException;

// NewMain.java
public class NewMain {

    public static void main(String[] args) {
        //createLogFile();
        AppProperties.loadProperties();
        GUI.main(args);
    }

    public static void createLogFile() {
        File file = new File(System.getProperty("user.home") + "/.ssrsexport/log.txt");

        PrintStream out;
        try {
            out = new PrintStream(
                    new FileOutputStream(file.getPath(), false), true);
            System.setOut(out);
            System.setErr(out);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}


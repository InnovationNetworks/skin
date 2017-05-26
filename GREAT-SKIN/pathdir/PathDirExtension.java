// PathDirExtension
// Charles Staelin, Smith College
// Modified for NetLogo 5.0beta3 and added isDirectory? - June 2011
// Modified for new API with NetLogo 5.0beta4 - August 2011

/*
 * Contains a number of procedures for finding paths, and for creating,
 * renaming and deleting directories.
 * REMEMBER THAT ANY PROCEDURES THAT FOOL WITH YOUR FILES MAY BE DANGEROUS!
 */
package org.nlogo.extensions.pathdir;

import org.nlogo.api.LogoException;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Argument;
import org.nlogo.api.Syntax;
import org.nlogo.api.Context;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.api.DefaultCommand;
import org.nlogo.api.DefaultReporter;

import java.io.File;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.IOException;

public class PathDirExtension extends org.nlogo.api.DefaultClassManager {

    // Prepends to the attachName argument the current working directory as
    // specified in the NetLogo model's context.  However, if attachName is an
    // absolute path, it is returned unchanged.
    private static String attachCWD(Context context, String attachName) throws ExtensionException {
        if (attachName.length() == 0) {
            attachName = ".";
        }
        try {
            attachName = context.attachCurrentDirectory(attachName);
        } catch (java.net.MalformedURLException ex) {
            throw new ExtensionException(ex);
        }

        File f = new File(attachName);
        try {
            return (f.getCanonicalFile()).toString();
        } catch (IOException ex) {
            ExtensionException eex = new ExtensionException(ex);
            eex.setStackTrace(ex.getStackTrace());
            throw eex;
        }
    }

    public void load(org.nlogo.api.PrimitiveManager primManager) {
        primManager.addPrimitive("get-separator", new getSeparator());
        primManager.addPrimitive("get-model", new getModelDirectory());
        primManager.addPrimitive("get-home", new getHomeDirectory());
        primManager.addPrimitive("get-current", new getCurrentDirectory());
        primManager.addPrimitive("create", new createDirectory());
        primManager.addPrimitive("isDirectory?", new isDirectory());
        primManager.addPrimitive("list", new listDirectory());
        primManager.addPrimitive("move", new moveFileOrDirectory());
        primManager.addPrimitive("delete", new deleteDirectory());
        primManager.addPrimitive("exists?", new fileExists());
        primManager.addPrimitive("get-size", new getFileSize());
        primManager.addPrimitive("get-date-ms", new getFileDateTimeInMS());
        primManager.addPrimitive("get-date", new getFileDateTimeAsString());
    }

    // Returns the path separator for the current operating system, for 
    // use in creating new path strings in NetLogo.
    public static class getSeparator extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(Syntax.StringType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException {
            return File.separator;
        }
    }

    // Returns the absolute directory path to the current NetLogo model, 
    // as specified in the model's context.
    public static class getModelDirectory extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(Syntax.StringType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException {

            String modelDirName;
            try {
                modelDirName = context.attachModelDir(".");
            } catch (java.net.MalformedURLException ex) {
                throw new ExtensionException(ex);
            }
            File f = new File(modelDirName);
            try {
                return (f.getCanonicalFile()).toString();
            } catch (IOException ex) {
                ExtensionException eex = new ExtensionException(ex);
                eex.setStackTrace(ex.getStackTrace());
                throw eex;
            }
        }
    }

    // Returns the absolute directory path to the users home directory,
    // as specified "user.home" environment variable in the current
    // operating system.
    public static class getHomeDirectory extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(Syntax.StringType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException {

            String homeDirName = System.getProperty("user.home");
            File f = new File(homeDirName);
            try {
                return (f.getCanonicalFile()).toString();
            } catch (IOException ex) {
                ExtensionException eex = new ExtensionException(ex);
                eex.setStackTrace(ex.getStackTrace());
                throw eex;
            }
        }
    }

    // Returns the absolute directory path to the current working directory
    // as specified in the NetLogo model's context.
    public static class getCurrentDirectory extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(Syntax.StringType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException {
            return attachCWD(context, ".");
        }
    }

    // Creates a directory.  If the input string does not contain an 
    // absolute path, the directory is created relative to the current 
    // working directory specified in the NetLogo model's context.
    // Note that this procedure will create as many intermediate directories
    // as are needed to create the final directory in the specified path.
    // If the directory already exists, nothing is done.
    public static class createDirectory extends DefaultCommand {

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]{Syntax.StringType()});
        }

        public void perform(Argument args[], Context context) throws ExtensionException, LogoException {

            File f = new File( attachCWD(context, args[0].getString()) );
            if (!f.exists()) {
                boolean success = f.mkdirs();
                if (!success) {
                    throw new ExtensionException("Could not create the directory at " + f.toString() + ".");
                }
            }
        }
    }

    // Returns TRUE if the argument both exists and is a directory; otherwise, 
    // returns FALSE.
    public static class isDirectory extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.BooleanType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File f = new File( attachCWD(context, args[0].getString()) );
            if (f.exists()&& f.isDirectory()) {
                return true;
            }

            return false;
        }
    }

    // Returns a NetLogo list of strings, with each string being an element
    // of the listing of the specified directory.  If the input string does
    // not contain an absolute path, the path is assumed to be relative to 
    // the current working directory as specified in the NetLogo model's
    // context.
    public static class listDirectory extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.ListType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File f = new File( attachCWD(context, args[0].getString()) );
            if (!f.exists()|| !f.isDirectory()) {
                throw new ExtensionException(f.toString() + " does not exist as a directory.");
            }

            String[] dirListArray = f.list();
            LogoListBuilder dirList = new LogoListBuilder();
            // need to deal with no such directory exception (null file pointer)
            for (int i = 0; i < dirListArray.length; i++) {
                dirList.add(dirListArray[i]);
            }
            return dirList.toLogoList();
        }
    }

    // moves the file or directory in the first input string to the new
    // name and/or location in the second input string.  It can simply be used
    // to rename a file or directory as well.  If either input string does not
    // contain an absolute path, it assumes the directory or file is located in
    // the current working directory as specified in the NetLogo model's context.
    public static class moveFileOrDirectory extends DefaultCommand {

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]{Syntax.StringType(),
                        Syntax.StringType()});
        }

        public void perform(Argument args[], Context context) throws ExtensionException, LogoException {

            File fOldName = new File( attachCWD(context, args[0].getString()) );
            if (!(fOldName.exists())) {
                throw new ExtensionException("Source file or directory " + fOldName.toString()
                                              + " does not exist.");
            }

            File fNewName = new File( attachCWD(context, args[1].getString()) );
            if (fNewName.exists()) {
                throw new ExtensionException("The destination " + fNewName.toString()
                                              + " already exists.");
            }

            boolean flag = fOldName.renameTo(fNewName);
            if (!flag) {
                throw new ExtensionException("Could not rename/move " + fOldName.toString()
                                              + " to " + fNewName.toString() + ".");
            }
        }
    }

    // deletes a directory.  If the input string does not contain an
    // absolute path, it assumes the directory to be deleted is in the
    // current working directory as specified by the NetLogo model's context.
    // Only directories may be deleted (as there is already a NetLogo
    // primitive for files) and the directory must be
    // both empty and not hidden.
    public static class deleteDirectory extends DefaultCommand {

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]{Syntax.StringType()});
        }

        public void perform(Argument args[], Context context) throws ExtensionException, LogoException {

            File f = new File( attachCWD(context, args[0].getString()) );
            if (!f.exists() || !f.isDirectory()) {
                throw new ExtensionException(f.toString() + " does not exist as a directory.");
            }
            if (f.isHidden()) {
                throw new ExtensionException(f.toString() + " is hidden and will not be deleted.");
            }
            if (f.list().length != 0) {
                throw new ExtensionException(f.toString() + " is not empty and will not be deleted.");
            }

            boolean flag = f.delete();
            if (!flag) {
                throw new ExtensionException(f.toString() + " could not be deleted.");
            }
        }
    }
    
    public static class fileExists extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.BooleanType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File fName = new File(attachCWD(context, args[0].getString()));
            if (!(fName.exists())) {
                return false;
            }

            return true;
        }
    }    
    
    public static class getFileSize extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.NumberType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File fName = new File(attachCWD(context, args[0].getString()));
            if (!(fName.exists())) {
                throw new ExtensionException("Source file or directory " + fName.toString()
                        + " does not exist.");
            }

            return (double)fName.length();
        }
    }
    
    public static class getFileDateTimeInMS extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.NumberType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File fName = new File(attachCWD(context, args[0].getString()));
            if (!(fName.exists())) {
                throw new ExtensionException("Source file or directory " + fName.toString()
                        + " does not exist.");
            }

            return (double)fName.lastModified();
        }
    }
    
    public static class getFileDateTimeAsString extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.StringType()}, Syntax.StringType());
        }

        public Object report(Argument args[], Context context) throws ExtensionException, LogoException {

            File fName = new File(attachCWD(context, args[0].getString()));
            if (!(fName.exists())) {
                throw new ExtensionException("Source file or directory " + fName.toString()
                        + " does not exist.");
            }

            return new SimpleDateFormat("dd-MM-yyyy HH-mm-ss").format(new Date(fName.lastModified()));
        }
    }        
}

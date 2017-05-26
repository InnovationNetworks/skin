The pathdir extension:

(Note that this information is also on the Info tab of PathDir.nlogo in a format that is a bit easier to read.)


pathdir:get-separator
Returns a string with the character used by the host operating system to separate directories in the path.  E.g., for Windows the string "\\" would be returned (as the backslash must be escaped), while for Mac OSX, the string "/" would be returned.  Useful for creating operating system-independent path strings

pathdir:get-model
Returns a string with the full (absolute) path to the directory in which the current model is located, as specified in the NetLogo context for the current model.

pathdir:get-home
Returns a string with the full (absolute) path to the user's home directory, as specified by the "user.home" environment variable of the host operating system.  This may not exist for all operating systems?

pathdir:get-current
Returns a string with the full (absolute) path to the current working directory (CWD) as specified in the NetLogo context for the current model.  The CWD may be set by the NetLogo command set-current-directory.  Note that set-current-directory will accept a path to a directory that does not actually exist and subsequently using the nonexistent CWD, say to open a file, will normally cause an error.  Note that when a NetLogo model first opens, the CWD is set to the directory from which the model is opened.

pathdir:create <string>
Creates the directory specified in the given string.  If the string does not contain an absolute path, i.e. the path does not begin at the root of the file system, then the directory is created relative to the current working directory.  Note that this procedure will create as many intermediate directories as are needed to create the last directory in the path.  So, if one specifies pathdir:create "dir1\\dir2\\dir3" (using Windows path syntax) and if dir1 does not exist in the CWD, then the procedure will create dir1 in the CWD, dir2 in dir1, and finally dir3 in dir2.  If the directory to be created already exists, then no action is taken.

pathdir:isDirectory? <string>
Returns TRUE if the file or directory given by the string both exists and is a directory.  Otherwise, returns FALSE.  (Note that the NetLogo command file-exists? can be used to see if a file or directory simply exists.)  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

pathdir:list <string>
Returns a NetLogo list of strings, each element of which contains an element of the directory listing of the specified directory.  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  If the directory is empty, the command returns an empty list.  To get a listing of the CWD one could use pathdir:list pathdir:get-current or, more simply, pathdir:list "".

pathdir:move <string1> <string2>
Moves or simply renames the file or directory given by string1 to string2.  If either string does not contain an absolute path, i.e., the path does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  E.g., 
pathdir:move "dir1\\file1.csv" (word pathdir:get-home "\\keep.csv")
will rename and move the file "file1.csv" in dir1 of the CWD to "keep.csv" in the user's home directory.  If the file with the same name already exists at the destination, an error is returned.

pathdir:delete <string>
Deletes the directory given by the string.  The directory must be empty and must not be hidden.  (The check for a read-only directory currently does not work.)  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  This command will return an error if the path refers to a file rather than a directory as there already is a NetLogo command for deleting a file: file-delete.

pathdir:get-size <string>
Returns the size in bytes of the file given by the string. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

pathdir:get-date <string>
Returns the modification date of the file given by the string. The date is returned as a string in the form dd-MM-yyyy HH-mm-ss, where dd is the day in the month, MM the month in the year, yyyy the year, HH the hour in 24-hour time, mm the minute in the hour and ss the second in the minute. Two dates may be compared with the relational operators. Thus pathdir:get-date "file1" > pathdir:get-date "file2" will be true if file1 has a later modification date than file2, and false otherwise. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

pathdir:get-date-ms <string>
Returns the modification date of the file given by the string. The date is returned as the number of milliseconds since the base date of the operating system, making it easy to compare dates down to the millisecond. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.


Anyone is welcome to extend and/or refine the functionality of this extension.


This extension was written by Charles Staelin, Smith College, Northampton, MA.
Latest version is October 2012.
extensions [pathdir]

; !!CAUTION: THIS PROCEDURE CREATES AND DELETES DIRECTORIES IN THE USER'S HOME DIRECTORY!!
;   MAKE SURE THERE ARE NOT ALREADY DIRECTORIES WITH THE NAMES "dir1", "dir1a" or "dir1b" 
;   THERE AS tMAY BE BE DELETED.

to go
  
  print "Get the model directory: pathdir:get-model"
  show pathdir:get-model
  print ""
  print "Get the user's home directory: pathdir:get-home"
  show pathdir:get-home
  print ""
  print "Get the current working directory: pathdir:get-current"
  show pathdir:get-current
  print ""
  
  print "Get the directory listing of the home directory: pathdir:list pathdir:get-home"
  show pathdir:list pathdir:get-home
  print ""
  print "Get the directory listing of the current directory: pathdir:list pathdir:get-current"
  show pathdir:list pathdir:get-current
  print ""
  print  "Or more simply, do the same with a relative path: show pathdir:list \"\" "
  show pathdir:list ""
  print ""
  
  ; Here we use isDirectory? to filter out the entries that are not directories in the 
  ; directory listing of the CWD so that we can open the first subdirectory.
  print "Get the directory lising of the first subdirectory in the current directory (if any)."
  let current filter [pathdir:isDirectory? ?] pathdir:list pathdir:get-current
  if not empty? current [
    print "That subdirectory is:"
    show first current
    print "And its listing is:"
    show pathdir:list first current
  ]
  print ""
  
  print "Change the CWD to the user's home directory: set-current-directory pathdir:get-home"
  set-current-directory pathdir:get-home
  show pathdir:get-current
  print ""
  
  ; We will use the path separator here so we have the right syntax for creating new directories.
  print "Get the path separator for this OS: let sep pathdir:get-separator"
  let sep pathdir:get-separator
  show sep
  print ""
  
  ; Before proceding we make sure that the user does not have a directory "dir1" in their
  ; home directory so that the rest of this procedure will do no damage.
  if pathdir:isDirectory? "dir1" [
    print "A directory called dir1 already exists in the user's home director.  We'll stop"
    print "here so as to do no damage to your files."
    stop
  ]
  print "Now create create in the CWD a new directory, dir1, and subdirectory, dir1a:"
  print "pathdir:create (word \"dir1\" sep \"dir1a\")"
  pathdir:create (word "dir1" sep "dir1a")
  print "And list the CWD and then dir1 to see that the new directories exist"
  show pathdir:list ""
  show pathdir:list "dir1"
  print ""

  print "Rename dir1a to dir1b: pathdir:move (word \"dir1\" sep \"dir1a\") (word \"dir1\" sep \"dir1b\")"
  pathdir:move (word "dir1" sep "dir1a") (word "dir1" sep "dir1b")
  print "And list dir1 to see that dir1a has been renamed to dir1b"
  show pathdir:list "dir1"
  print ""
  
  print "Now move dir1b up a level: pathdir:move (word \"dir1\" sep \"dir1b\") \"dir1b\""
  pathdir:move (word "dir1" sep "dir1b") "dir1b"
  print "And list CWD to see that dir1b is there"
  show pathdir:list ""
  print ""
  
  print "Finally, cleanup by deleting the new directories:"
  print "pathdir:delete \"dir1b\""
  pathdir:delete "dir1b"
  print "pathdir:delete \"dir1\""
  pathdir:delete "dir1"
  print ""
  print "All gone"
  show pathdir:list ""
  
  print ""
  print "Set the CWD to the directory in which this NetLogo model is located and"
  print "then get the size and date of the 'PathDir.nlogo' file, the latter first as"
  print "a string and then in milliseconds."
  set-current-directory pathdir:get-model
  show pathdir:get-size "PathDir.nlogo"
  show pathdir:get-date "PathDir.nlogo"
  show pathdir:get-date-ms "PathDir.nlogo"
  
  
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

@#$#@#$#@
## WHAT IS IT?

The pathdir extension:


This extension contains a number of procedures for finding paths and for creating,
renaming and deleting directories.


**pathdir:get-separator**
Returns a string with the character used by the host operating system to separate directories in the path.  E.g., for Windows the string "\\\\" would be returned (as the backslash must be escaped), while for Mac OSX, the string "/" would be returned.  Useful for creating operating system-independent path strings

**pathdir:get-model**
Returns a string with the full (absolute) path to the directory in which the current model is located, as specified in the NetLogo context for the current model.

**pathdir:get-home**
Returns a string with the full (absolute) path to the user's home directory, as specified by the "user.home" environment variable of the host operating system.  This may not exist for all operating systems?

**pathdir:get-current**
Returns a string with the full (absolute) path to the current working directory (CWD) as specified in the NetLogo context for the current model.  The CWD may be set by the NetLogo command **set-current-directory _string_**.  Note that **set-current-directory** will accept a path to a directory that does not actually exist and subsequently using the nonexistent CWD, say to open a file, will normally cause an error.  Note that when a NetLogo model first opens, the CWD is set to the directory from which the model is opened.

**pathdir:create _string_**
Creates the directory specified in the given string.  If the string does not contain an absolute path, i.e. the path does not begin at the root of the file system, then the directory is created relative to the current working directory.  Note that this procedure will create as many intermediate directories as are needed to create the last directory in the path.  So, if one specifies `pathdir:create "dir1\\dir2\\dir3"` (using Windows path syntax) and if dir1 does not exist in the CWD, then the procedure will create dir1 in the CWD, dir2 in dir1, and finally dir3 in dir2.  If the directory to be created already exists, then no action is taken.

**pathdir:isDirectory? _string_**
Returns TRUE if the file or directory given by the string both exists and is a directory.  Otherwise, returns FALSE.  (Note that the NetLogo command **file-exists? _string_** can be used to see if a file or directory simply exists.)  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

**pathdir:list _string_**
Returns a NetLogo list of strings, each element of which contains an element of the directory listing of the specified directory.  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  If the directory is empty, the command returns an empty list.  To get a listing of the CWD one could use `pathdir:list pathdir:get-current` or, more simply, `pathdir:list ""`.

**pathdir:move _string1_ _string2_**
Moves or simply renames the file or directory given by string1 to string2.  If either string does not contain an absolute path, i.e., the path does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  E.g., 
`pathdir:move "dir1\\file1.csv" (word pathdir:get-home "\\keep.csv")`
will rename and move the file "file1.csv" in dir1 of the CWD to "keep.csv" in the user's home directory.  If the file with the same name already exists at the destination, an error is returned.

**pathdir:delete _string_**
Deletes the directory given by the string.  The directory must be empty and must not be hidden.  (The check for a read-only directory currently does not work.)  If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.  This command will return an error if the path refers to a file rather than a directory as there already is a NetLogo command for deleting a file: **file-delete _string_**.

**pathdir:get-size _string_**
Returns the size in bytes of the file given by the string. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

**pathdir:get-date _string_**
Returns the modification date of the file given by the string. The date is returned as a string in the form dd-MM-yyyy HH-mm-ss, where dd is the day in the month, MM the month in the year, yyyy the year, HH the hour in 24-hour time, mm the minute in the hour and ss the second in the minute. Two dates may be compared with the relational operators. Thus pathdir:get-date "file1" > pathdir:get-date "file2" will be true if file1 has a later modification date than file2, and false otherwise. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

**pathdir:get-date-ms _string_**
Returns the modification date of the file given by the string. The date is returned as the number of milliseconds since the base date of the operating system, making it easy to compare dates down to the millisecond. If the path given by the string is not an absolute path, i.e., it does not begin at the root of the file system, then the path is assumed to be relative to the current working directory.

## EXTENDING THE MODEL

Anyone is welcome to extend and/or refine the functionality of this extension.

## CREDITS AND REFERENCES

This extension was written by Charles Staelin, Smith College, Northampton, MA.
It was updated for NetLogo 5.0 in June 2011, and the get-size, get-date and get-date-ms primitives were added in October 2012.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@

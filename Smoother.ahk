#SingleInstance, force
SetMouseDelay, 25

; Logs
global Track  = []

; States
global Logging   = false
global GotTrack  = false
global Smoothing = false

; Positional Data
global SmoothX = 1143
global SmoothY = 906

global StartX = 0
global StartY = 0

global passes = 1
global smoothText

Gui, Add, Button, x10 y10 w200, Trace

Gui, Add, Button, y+5 w155 vSmooth,
GuiControl, disable, Smooth


Gui, Add, Button, x+5 gDecrementPass, -
Gui, Add, Button, x+5 gIncrementPass, +
Gui, +AlwaysOnTop
Gui, Show, w500 h500, Hello
return

GuiClose:
   ExitApp
   return

DecrementPass:
   passes := passes - 1
   passes := passes > 1 ? passes : 1
   MsgBox, %passes%
   return

IncrementPass:
   passes := passes + 1
   Gui, Show, w500 h500, Hello
   MsgBox, %passes%
   return

StartLogMouse() {
   if (Logging) {
      MouseGetPos, StartX, StartY
   }
}

EndLogMouse() {
   if (Logging) {
      MouseGetPos, EndX, EndY
      Segment := Array(StartX, StartY, EndX, EndY)
      Track.Push(Segment)
   }
}

Smooth() {
   MouseMove %SmoothX%, %SmoothY%
   Click, down
   Sleep, 5
   Click, up
}

StartSmooth() {
   loop 4 {
      i := 1
      leng := Track.Length()

      MsgBox %leng%

      while (i <= leng) {
         Segment := Track[i]

         StartX := Segment[1]
         StartY := Segment[2]
         EndX   := Segment[3]
         EndY   := Segment[4]

         MouseMove, %StartX%, %StartY%
         Click, down
         Sleep, 5
         MouseMove, %EndX%, %EndY%
         Sleep, 5
         Click, up

         Smooth()

         i := i + 1
      }
   }
}

StartLogging() {
   Logging = true
}

StopLogging() {
   Logging = false
   GotTrack = true
}

RunScript() {
   if !(GotTrack) {
      if !(Logging) {
         StartLogging()
      } else {
         StopLogging()
         StartSmooth()
      }
   }
}

^x:: RunScript()
LControl & LButton:: StartLogMouse()
LControl & LButton up:: EndLogMouse()
^p:: ExitApp

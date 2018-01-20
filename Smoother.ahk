if not A_IsAdmin {
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

#SingleInstance, force
CoordMode, Mouse, Screen
SetMouseDelay, 10
SetDefaultMouseSpeed, 1

; Logs
global Track  = []

; States
global RegisteringSmooth = false
global GotSmooth         = false

global Tracing           = false
global GotTrace          = false

global Smoothing         = false

; Positional Data
global SmoothX = 0
global SmoothY = 0

global StartX = 0
global StartY = 0

global Passes = 4

Gui, Add, Button, x10 y10 w200 gStartRegisterSmooth, Register Smooth
Gui, Add, Button, x+5 w125 vSmoothPos, None

Gui, Add, Button, x10 y+5 w200 gToggleTrace vTrace, Start Tracing
Gui, Add, Button, x+5 w125 vTrackCount, None

Gui, Add, Button, x10 y+5 w200 vSmooth gStartSmooth, Smooth: %Passes%
GuiControl, disable, Smooth

Gui, Add, Button, x+5 w30 gDecrementPass, -
Gui, Add, Button, x+5 w30 gIncrementPass, +

Gui, Add, Text, x10 y+45, Instructions:
Gui, Add, Text, y+5, 0. Run Planet Coaster in Borderless mode.
Gui, Add, Text, y+5, 1. Create your rollercoaster with 4m pieces.
Gui, Add, Text, y+5, 2. Select the first 4 track pieces.
Gui, Add, Text, y+5, 3. Run the script.
Gui, Add, Text, y+5, 4. Press 'Register Smooth', then LCtrl + LClick on the smooth button.
Gui, Add, Text, y+5, 5. Press 'Start Tracing'.
Gui, Add, Text, y+5, 6. While holding LCtrl, click the blue marker and move it one
Gui, Add, Text, y+5, track forward, then release the LCick button.
Gui, Add, Text, y+5, 7. Repeat this until you are at the end of the track, then do
Gui, Add, Text, y+5, the process backwards to your starting point. All while holding LCtrl.
Gui, Add, Text, y+5, 8, Press the 'Smotth: x' button.

Gui, Add, Text, y+10, Note: Keep an eye out while smoothing.
Gui, Add, Text, y+5, Sometimes the marker will not be moved.
Gui, Add, Text, y+5, When this happends press LCtrl + P to stop the process.
Gui, Add, Text, y+5, Then move the marker back at your starting spot and press
Gui, Add, Text, y+5, 'Smooth: x' again.

Gui, Add, Text, y+25, Tip: Smooth your coaster in small segments of ~20 pieces.
Gui, Add, Text, y+5, Mark your start and end points by coloring the track.

Gui, Show, w350 h520, Planet Coaster Smoothing Tool.

return

GuiClose:
   ExitApp
   return

StartRegisterSmooth:
   RegisteringSmooth := true
   return

ToggleTrace:
   if (Tracing) {
      GuiControl,,Trace, Start Tracing
      GuiControl, enable, Smooth

      GotTrace := true
   } else {
      GuiControl,,Trace, Stop Tracing
      GuiControl,,TrackCount, None
      GuiControl, disable, Smooth

      Track    := []
      GotTrace := false
   }

   Tracing := !Tracing

   return

DecrementPass:
   Passes := Passes - 1
   Passes := Passes > 1 ? Passes : 1

   GuiControl,,Smooth,% "Smooth: " . Passes

   return

IncrementPass:
   Passes := Passes + 1

   GuiControl,,Smooth,% "Smooth: " . Passes

   return

StartSmooth:
   Smoothing := true
   StartSmooth()

   return

StartLogMouse() {
   MouseGetPos, StartX, StartY
}

EndLogMouse() {
   MouseGetPos, EndX, EndY
   Segment := Array(StartX, StartY, EndX, EndY)
   Track.Push(Segment)

   GuiControl,,TrackCount,% Track.Length()
}

Smooth() {
   Sleep, 25
   MouseMove %SmoothX%, %SmoothY%
   Sleep, 25
   Click, down
   Sleep, 25
   Click, up
   sleep, 25
}

StopSmooth() {
   Smoothing := false
}

StartSmooth() {
   Smoothing := true

   Smooth()

   loop %Passes% {
      i := 1
      leng := Track.Length()

      while (i <= leng) & Smoothing {
         Segment := Track[i]

         StartX := Segment[1]
         StartY := Segment[2]
         EndX   := Segment[3]
         EndY   := Segment[4]

         MouseMove, %StartX%, %StartY%, 2
         Sleep, 25
         Click, down
         Sleep, 100
         MouseMove, %EndX%, %EndY%, 2
         Sleep, 25
         Click, up
         Sleep, 25


         Smooth()

         i := i + 1
      }
   }

   StopSmooth()
}

RegisterSmooth() {
   MouseGetPos, SmoothX, SmoothY
   GuiControl,,SmoothPos,% SmoothX . " : " . SmoothY
}

LClickDown() {
   if (RegisteringSmooth) {
      RegisterSmooth()
      RegisteringSmooth := false
   }

   if (Tracing) {
      StartLogMouse()
   }
}

LClickUp() {
   if (Tracing) {
      EndLogMouse()
   }
}

LControl & LButton:: LClickDown()
LControl & LButton up:: LClickUp()
^p:: StopSmooth()

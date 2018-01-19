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
Gui, Add, Button, x+5 w100 vSmoothPos, None

Gui, Add, Button, x10 y+5 w200 gToggleTrace vTrace, Start Tracing
Gui, Add, Button, x+5 w100 vTrackCount, None

Gui, Add, Button, x10 y+5 w200 vSmooth gStartSmooth, Smooth: %Passes%
GuiControl, disable, Smooth

Gui, Add, Button, x+5 w30 gDecrementPass, -
Gui, Add, Button, x+5 w30 gIncrementPass, +
Gui, Show, w325 h500, Planet Coaster Smoothing Tool
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

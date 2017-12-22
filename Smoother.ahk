SetMouseDelay, 35

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
   loop 2 {
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

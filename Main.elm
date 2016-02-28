import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse
import Window
import Debug
import BoidLayout

type alias BoidFish = {
  boid: List Form
}
boidFish : BoidFish
boidFish =
  let
    head = toForm (image 42 25 "/imgs/head.png" )
    fin   = toForm (image 39 63 "/imgs/fin.png" )
    spine = toForm (image 38 25 "/imgs/spine.png" )
    fish = [head] ++ repeat 2 spine ++ [fin] ++ repeat 9 spine  ++ [fin] ++ repeat 6 spine
    repeat = List.repeat
  in {
    boid = fish
 }

boidLayout = BoidLayout.initLayout (List.length boidFish.boid)

updateForm : (Form) -> (Int, Int, Float, Float, Float) -> Form
updateForm (form) (x,y,angle,scalez,alphaz) =  form |> move ( toFloat x, toFloat y) |> rotate angle |> scale scalez |> alpha alphaz

scene : (Int,Int) -> List (Int,Int,Float, Float, Float) -> Element
scene  (w,h) boidLayout =
  let
    (wcx,wcy) = (round (toFloat w /2), round (toFloat h /2))
    screenRel (x,y,angle,scale,alpha) = (x - wcx, wcy - y,angle,scale,alpha)
    screenLayout = List.map screenRel boidLayout
  in
    collage w h (List.map2 updateForm boidFish.boid screenLayout)

-- SIGNALS
main : Signal Element
main = Signal.map2 scene Window.dimensions boidLayoutReducer

boidLayoutReducer : Signal (List (Int,Int,Float,Float,Float))
boidLayoutReducer = Signal.foldp BoidLayout.update boidLayout Mouse.position

{-
Adapted from a BIONIC SIMULATION (C) 2001 - Luis Pabon (luis@pabon.com) made available on FlashKit
Original mentions that "You can freely use and modify this code but please, give credit to the author"
-}
module BoidLayout where

import Debug

type alias LayoutItem = (Int, Int, Float, Float,Float)

dampR         = 10 -- how slow the fish follows the mouse for firstNode only
scaleFactor   = 0.96
alphaFactor   = 0.95
compactFactor = 1.3 -- compactness (depends on dampR)

layoutPos : (Int, Int) ->  (Int) -> LayoutItem
layoutPos   (x,y)          idx =
  let
    sp = 9
    angle = 0.0
    alpha = 1.0
    scale = 1.0
  in
    (x + (sp* idx) , y, angle, scale, alpha)

initLayout : Int -> List LayoutItem
initLayout segmentQty  = List.map (layoutPos (0, 0)) [1..segmentQty]

diff : (Int,Int) -> (Int,Int) -> (Int,Int)
diff (x,y) (px,py) = ( x - px , y - py)

dampenByFactor : Float -> Int -> Int
dampenByFactor factor x = round(toFloat x / factor)

average : Int -> Int -> Int
average a b = round ((toFloat (a + b)) / 2)

update : (Int, Int) -> List LayoutItem -> List LayoutItem
update (x, y) layout =
  case layout of
    [] -> [] -- never occurs, fuck you elm
    head::tail ->
      let
        -- watchLay = Debug.watch "head,tail" (head, tail)
        head' = updateHead head (x,y)
      in
        [head'] ++ (reduceBody head' tail)

updateHead : LayoutItem  -> (Int, Int) -> LayoutItem
updateHead item (x,y) =
  let
    alpha = 1.0
    scale = 1.0
    (px, py, a, b, c) = item
    dampen = dampenByFactor dampR
    (dx, dy) =  diff (x,y) (px,py)
    (ex, ey) = ( average px (px+ dampen dx), average py (py+ dampen dy) )
    radian = pi - atan2 (toFloat dy) (toFloat dx)
    -- watchAngle = Debug.watch "angle" (57.2958 *  radian)
  in
    (ex, ey, radian, scale, alpha)

reduceBody : LayoutItem -> List LayoutItem -> List LayoutItem
reduceBody previousItem items =
  case items of
      [] -> []
      head::tail ->
        let
          (px,py,ha,hb,hc) = head
          (x,y,a,b,c) = previousItem
          dampen = dampenByFactor compactFactor
          (dx, dy) =  diff (x,y) (px,py)
          (ex, ey) = ( average px (px+ dampen dx), average py (py+ dampen dy) )
          radian = pi - atan2 (toFloat dy) (toFloat dx)
          head' = ( ex,  ey,  radian, b*scaleFactor, c*alphaFactor)
        in
          [head'] ++ (reduceBody head' tail)

updateNode : LayoutItem -> LayoutItem -> LayoutItem
updateNode previousItem item = item

-- item.x += (previousItem.x - item.x);
-- item.y += (previousItem.y - item.y);

import Html exposing (Html)
import Html.App
import Element
import Window
import Collage exposing (..)
import Mouse
import BoidLayout exposing (BoidLayout)
import Task

-- http://0.0.0.0:8000/Main.elm?debug -- debug disabled in early realase of 0.17

main = Html.App.program { init = init, view = view, update = update , subscriptions = subscriptions }

-- Data

type alias Model = {window: (Int, Int), layout: BoidLayout}

boidLayout = BoidLayout.initLayout (List.length boidFish.boid)

init : (Model, Cmd Msg)
init = ({window = (800, 800), layout = boidLayout} , initialSizeCmd)

-- Interactivity

type Msg = WindowResize (Int, Int) | MouseMsg Mouse.Position | NoOp

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
    Window.resizes sizeToMsg,
    Mouse.moves MouseMsg
  ]


initialSizeCmd : Cmd Msg
initialSizeCmd =
  Task.perform (\_ -> NoOp) sizeToMsg Window.size

sizeToMsg : Window.Size -> Msg
sizeToMsg size =
  WindowResize (size.width, size.height)

-- Application states

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    WindowResize (w, h)  ->
      ({window = (w, h), layout = model.layout}, Cmd.none)
    NoOp  ->
      ({window = model.window, layout = model.layout}, Cmd.none)
    MouseMsg position ->
      ({window = model.window, layout = BoidLayout.update (position.x, position.y) model.layout}, Cmd.none)

-- View

view : Model -> Html Msg
view model =
  let
    (w,h) = model.window
    (wcx,wcy) = (round (toFloat w /2), round (toFloat h /2))
    screenRel (x,y,angle,scale,alpha) = (x - wcx, wcy - y,angle,scale,alpha)
    screenLayout = List.map screenRel model.layout
    -- reverted = (List.reverse (List.map2 updateForm boidFish.boid screenLayout))
    -- z = Debug.watch "z" reverted
  in
    Html.div []
        [
          Html.div [] [Html.text (toString model.window)],
          -- Html.div [] [Html.text (toString model)],
          collage w h
            [ group (List.map2 updateForm boidFish.boid screenLayout) ]
            |> Element.toHtml
        ]

updateForm : (Form) -> (Int, Int, Float, Float, Float) -> Form
updateForm (form) (x,y,angle,scalez,alphaz) =  form |> move ( toFloat x, toFloat y) |> rotate angle |> scale scalez |> alpha alphaz

type alias BoidFish = {
  boid: List Form
}
boidFish : BoidFish
boidFish =
  let
    head = toForm (Element.image 42 25 "imgs/head.png" )
    fin   = toForm (Element.image 39 63 "imgs/fin.png" )
    spine = toForm (Element.image 38 25 "imgs/spine.png" )
    fish = [head] ++ repeat 2 spine ++ [fin] ++ repeat 9 spine  ++ [fin] ++ repeat 6 spine
    repeat = List.repeat
  in {
    boid = fish
 }

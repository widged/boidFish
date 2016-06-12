import Html exposing (Html)
import Html.App
import Element
import Window
import Collage exposing (..)
import Mouse
import BoidLayout exposing (BoidLayout)
import Task
import Debug

-- http://0.0.0.0:8000/Main.elm?debug -- debug disabled in early realase of 0.17

main = Html.App.program { init = init, view = render, update = update , subscriptions = subscriptions }

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


-- Data

type alias Model = {
    window: (Int, Int),
    layout: BoidLayout
  }

init : (Model, Cmd Msg)
init = (
    {
      window = (800, 800),
      layout = BoidLayout.init (List.length boidFish.boid)
    },
    initialSizeCmd
  )

-- Application states

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    x = Debug.log "log_id" "value"
  in
  case msg of
    WindowResize (w, h)  ->
      ({ model | window = (w, h) }, Cmd.none)
    NoOp  ->
      (model, Cmd.none)
    MouseMsg position ->
      ({ model | layout = BoidLayout.update (position.x, position.y) model.layout }, Cmd.none)

-- View

render : Model -> Html Msg
render model =
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
          Html.div [] [Html.text ("Move your mouse around. " ++ "Window dimensions " ++ (toString model.window))],
          -- Html.div [] [Html.text (toString model)],
          collage w h
            [ group (List.map2 updateForm boidFish.boid screenLayout) ]
            |> Element.toHtml
        ]

updateForm : (Form) -> (Int, Int, Float, Float, Float) -> Form
updateForm (form) (x,y,angle,scalez,alphaz) =
  form |> move ( toFloat x, toFloat y) |> rotate angle |> scale scalez |> alpha alphaz

type alias BoidFish = { boid: List Form }
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

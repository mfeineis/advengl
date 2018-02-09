module Main exposing (main)

import AnimationFrame
import Env
import Html exposing (Html)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import Render
import Task
import Time exposing (Time)
import WebGL.Texture as Texture exposing (Error, Texture)


type alias Flags =
    Decode.Value


type Msg
    = Animate Time
    | Incoming Decode.Value
    | TextureLoaded (Result Error Texture)
    | ToggleAnimation


type alias Model =
    { isRunning : Bool
    , texture : Maybe Texture
    , theta : Float
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init defaultFlags
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


defaultFlags : Flags
defaultFlags =
    Encode.object
        [ ( "type", Encode.string "INIT" )
        ]


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { isRunning = False, texture = Nothing, theta = 0 }
    , Task.attempt TextureLoaded (Texture.load (Env.backendRoot ++ "/resources/textures/wood-crate.jpg"))
      --, Task.attempt TextureLoaded (Texture.load "http://localhost:8081/resources/textures/bg-fall-in-the-woods.jpg")
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.isRunning then
            AnimationFrame.diffs Animate
          else
            Sub.none
        , Ports.toElm Incoming
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate dt ->
            ( { model | theta = model.theta + dt / 10000 }, Cmd.none )

        Incoming value ->
            Debug.log ("Incoming: " ++ toString value)
                ( model, Cmd.none )

        TextureLoaded textureResult ->
            ( { model | texture = Result.toMaybe textureResult }, Cmd.none )

        ToggleAnimation ->
            ( { model | isRunning = not model.isRunning }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Sample" ]
        , Html.button [ onClick ToggleAnimation ] [ Html.text "Toggle" ]
        , Render.view model
        ]

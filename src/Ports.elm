port module Ports exposing (fromElm, toElm)

import Json.Decode exposing (Value)


port fromElm : Value -> Cmd msg


port toElm : (Value -> msg) -> Sub msg

{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Data.Monoid (mconcat)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)

main :: IO()
main = scotty 3000 $ do
    middleware logStdoutDev

    get "/" $ do
        html "<h1>TESTE: Quem é você?!</h1>"

    get "/:nome" $ do
        nome <- pathParam "nome"
        html $ mconcat ["<h1>Ola, ", nome, "!</h1>"]

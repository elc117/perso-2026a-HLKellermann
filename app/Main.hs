{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Data.Aeson (FromJSON, ToJSON)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)

ordemDeGrandeza :: [(Int, String, String)]
ordemDeGrandeza = 
  [(24, "Y", "iota"),
   (21, "Z", "zeta"),
   (18, "E", "exa"),
   (15, "P", "peta"),
   (12, "T", "tera"),
   (9, "G", "giga"),
   (6, "M", "mega"),
   (3, "k", "quilo"),
   (2, "h", "hecto"),
   (1, "da", "deca"),
   (-1, "d", "deci"),
   (-2, "c", "centi"),
   (-3, "m", "mili"),
   (-6, "µ", "micro"),
   (-9, "n", "nano"),
   (-12, "p", "pico"),
   (-15, "f", "femto"),
   (-18, "a", "ato"),
   (-21, "z", "zepto"),
   (-24, "y", "iocto")]


-- Converte entre grandezas
converte :: Double -> Int -> Double
converte valor expo = valor * (10 ** fromIntegral expo) -- ** pois ^ nao aceita negativo

-- Devolve uma lista de tupla conseguida atraves de list compreension, cada tupla eh uma conversao e seu simbolo
--tupla 'recebe' o valor resultante da funcao 'converte' e o simbolo 's'. O expoente e o simbolo vem da tupla 'atual' da ordemDeGrandeza, repete-se
conversoes :: Double -> [(Int, String, String)] -> [(Double, String)]
conversoes valor ordemDeGrandeza = [(converte valor e, s) | (e,s,_) <- ordemDeGrandeza]

-- 'converte' passa para 'conversoes' o numero sem nenhum simbolo, e essa devolve uma lista das conversoes realizadas para cada ordem
realizaFuncoes :: Double -> Int -> [(Double, String)]
realizaFuncoes num expo = conversoes (converte num expo) ordemDeGrandeza

-- refatorar para receber dos dois modos o expoente:
-- elevado a 'x'(int) OU receber o prefixo(char)

main :: IO()
main = scotty 3000 $ do
    middleware logStdoutDev

    get "/:numero/:expoente" $ do
        numero <- pathParam "numero"
        expoente <- pathParam "expoente"
        json (realizaFuncoes numero expoente)

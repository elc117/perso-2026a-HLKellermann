{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import qualified Data.Text as T
import Data.Scientific (Scientific, scientific, formatScientific, FPFormat(Fixed), fromFloatDigits)
import Text.Printf (printf)
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


-- Converte entre grandezas. 'scientific' faz 1 * 10^expoente (1 porque ja eh na base 10)
converte :: Scientific -> Int -> Scientific
converte valor expo = valor * scientific 1 expo

-- Devolve uma lista de tupla conseguida atraves de list compreension, cada tupla eh uma conversao e seu simbolo
--tupla 'recebe' o valor resultante da funcao 'converte' e o simbolo 's'. O expoente e o simbolo vem da tupla 'atual' da ordemDeGrandeza, repete-se
conversoes :: Scientific -> [(Int, String, String)] -> [(Scientific, String)]
conversoes valor ordemDeGrandeza = [(converte valor e, s) | (e,s,_) <- ordemDeGrandeza]

-- Arredonda as casas decimais apenas se o numero for maior que 1
-- Se for menor(expoente era negativo), mantem o valor normal para poder visualizar quantas casas ele "andou pra frente"
formataDec :: Scientific -> String
formataDec = formatScientific Fixed (Just 5)

-- 'converte' passa para 'conversoes' o numero sem nenhum simbolo, e essa devolve uma lista das conversoes realizadas para cada ordem
realizaFuncoes :: Scientific -> Int -> [(String, String)]
realizaFuncoes num expo = [(formataDec v, s) | (v, s) <- conversoes (converte num expo) ordemDeGrandeza]


main :: IO()
main = scotty 3000 $ do
    middleware logStdoutDev

    get "/:numero/:expoente" $ do
        numDouble <- pathParam "numero" :: ActionM Double
        expoente <- pathParam "expoente" :: ActionM Int
        let numero = fromFloatDigits numDouble
        json (realizaFuncoes numero expoente)

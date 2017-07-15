import Exploration

import Data.Algorithm.Munkres (hungarianMethodFloat)

import qualified Data.Set as S
import qualified Data.Map as M
import qualified Data.Array.IArray as A

data Problem = Problem {
    sourceN :: Int,
    -- ^ Cantidad de sources.
    facilityN :: Int,
    -- ^ Cantidad de facilities.
    apportation :: Int -> Int -> Float,
    -- ^ El balance de conectar la facility con el source.
    goodSources :: Int -> [Int],
    -- ^ Sources que entregan un balance positivo para la facility (optimización).
    constantCost :: Float,
    -- ^ Costo constante de agregar cada nueva facility.
    facilityDistance :: Int -> Int -> Float
    -- ^ Distancia entre dos facilities.
}

data Combi = Combi {
    facilities :: S.Set Int,
    worked :: M.Map Int Int,
    profit :: Float
}

instance Eq Combi where
    (==) a b = (facilities a) == (facilities b)
instance Ord Combi where
    compare a b = compare (facilities a) (facilities b)

emptyCombi :: Combi
emptyCombi = Combi S.empty M.empty 0.0

addFacility :: Problem -> Int -> Combi -> Combi
addFacility prob fa combI
    | fa < 0 || fa >= facilityN prob = error "Invalid facility number."
    | S.member fa (facilities combI) = combI
    | otherwise                      = foldr (\src comb -> let
        newApport = (apportation prob) src fa
        oldApport = if M.member src (worked comb) then 0.0
                    else (apportation prob) src (worked comb M.! src)
        in if newApport > oldApport then
            comb {
                worked = M.insert src fa (worked comb),
                profit = (profit comb) + newApport - oldApport
            } else comb
    ) combI {profit = profit combI - constantCost prob} (goodSources prob $ fa)

dissimilitude :: Problem -> Combi -> Combi -> Float
dissimilitude prob ca cb = let
    fsa = facilities ca
    fsb = facilities cb
    dists = A.array ((1,1),(length fsa,length fsb)) [((i,j),
        (facilityDistance prob) (S.elemAt (i-1) fsa) (S.elemAt (j-1) fsb)) |
        i <- [1..length fsa], j <- [1..length fsb]]
    in snd $ hungarianMethodFloat dists

module Geoloc (
    Problem(..),

) where

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
    -- ^ El balance de conectar el source con la facility.
    constantCost :: Float,
    -- ^ Costo constante de agregar cada nueva facility.
    facilityDistance :: Int -> Int -> Float
    -- ^ Distancia entre dos facilities.
}
{- | Genera un problema donde los puntos candidatos a tener las facilities son los mismos que los de los sources, esto en el plano donde el costo depende de la distancia euclidiana.
    points = los sources, (x,y,tamaño).
    facilityCost = costo constante de cada facility.
    unitGain = ganancia por cada unidad de tamaño de cada source agregado.
    transportCost = costo de por cada unidad de tamaño por cada unidad de distancia entre cada source agregado y su facility.
-}
euclidianProblem :: [(Float,Float,Float)] -> Float -> Float -> Float -> Problem
euclidianProblem points facilityCost unitGain transportCost = let
    lps = length points
    pair_indexes = [(i,j) | i <- [0..lps-1], j <- [0..lps-1]]
    dists = [sqrt ((sx-fx)**2+(sy-fy)**2) |
        (sx,sy,_) <- points, (fx,fy,_) <- points]
    dists' = A.array ((0,0),(lps-1,lps-1)) $ zip pair_indexes dists
        :: A.Array (Int,Int) Float
    apports = [ss * (unitGain - transportCost * sqrt ((sx-fx)**2+(sy-fy)**2)) |
        (sx,sy,ss) <- points, (fx,fy,_) <- points]
    apports' =  A.array ((0,0),(lps-1,lps-1)) $ zip pair_indexes apports
        :: A.Array (Int,Int) Float
    in Problem {
        sourceN = lps, facilityN = lps,
        apportation = (\so fa -> apports' A.! (so,fa)),
        constantCost = facilityCost,
        facilityDistance = (\f1 f2 -> dists' A.! (f1,f2))
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
    ) combI {profit = profit combI - constantCost prob} [0..sourceN prob-1]

dissimilitude :: Problem -> Combi -> Combi -> Float
dissimilitude prob ca cb = let
    fsa = facilities ca
    fsb = facilities cb
    dists = A.array ((1,1),(length fsa,length fsb)) [((i,j),
        (facilityDistance prob) (S.elemAt (i-1) fsa) (S.elemAt (j-1) fsb)) |
        i <- [1..length fsa], j <- [1..length fsb]]
    in snd $ hungarianMethodFloat dists

module Exploration (
    reduce,
    explore
) where

import qualified Data.List as L
import qualified Data.Set as S
import qualified Data.Map as M

{- | Función genérica de reducción:
    objective = función objetivo para una solución tipo a.
    disim = medida de disimilitud entre dos soluciones.
    vis_range = rango de las comparaciones evaluadas entre soluciones ordenadas por función objetivo.
    target_len = cantidad de elementos representativos a los que se quiere reducir el conjunto de soluciones.
    sols = lista de soluciones.
-}
reduce :: (Ord a, Real o, Ord d) => (a -> o) -> (a -> a -> d) -> Int -> Int ->
    [a] -> [a]
reduce objective disim vis_range target_len sols = let
    ordered_sols = L.sortBy (\a b -> compare (objective b) (objective a)) sols
    smap = M.fromList (zip [0..] ordered_sols)
    pairs = [(x,x+i) | x <- M.keys smap ,
        i <- [1..vis_range], x + i < length smap]
    disimils = S.fromList $
        map (\(a,b) -> (disim (smap M.! a) (smap M.! b), (a,b))) pairs
    in M.elems $ reduce' disim vis_range target_len disimils smap

reduce' :: (Ord a, Ord d) => (a -> a -> d) -> Int -> Int ->
    S.Set (d,(Int,Int)) -> M.Map Int a -> M.Map Int a
reduce' disim vis_range target_len disimils sols
    | length sols <= target_len                = sols
    | M.notMember a sols || M.notMember b sols =
        reduce' disim vis_range target_len disimils' sols
    | otherwise                                =
        reduce' disim vis_range target_len disimils'' sols'
    where
    dis@(_,(a,b)) = minimum disimils
    disimils' = S.delete dis disimils
    idx = M.findIndex b sols
    sols' = M.delete b sols
    new_pairs = [(M.elemAt a sols', M.elemAt (a+vis_range) sols') |
        a <- [(idx-vis_range)..(idx-1)], 0 <= a, a+vis_range < length sols']
    new_disimils = S.fromList $
        map (\((a,sa),(b,sb)) -> (disim sa sb, (a,b))) new_pairs
    disimils'' = S.union disimils' new_disimils

{- | Función genérica de exploración de soluciones, las soluciones que resultan de expandir otra y obtienen un valor menor en la función objetivo que esta son desechadas.
    objective = función objetivo para una solución tipo a.
    disim = medida de disimilitud entre dos soluciones.
    extend = función que expande una solución con un elemento.
    vis_range = rango de las comparaciones evaluadas entre soluciones ordenadas por función objetivo.
    pool_size = cantidad de elementos representativos que quedarán por cada iteración.
    empty_sol = solución base, sin ningún elemento.
    elements = lista de elementos con los que se forman las soluciones.
-}
explore :: (Ord a, Real o, Ord d) =>
    (a -> o) -> (a -> a -> d) -> (e -> a -> a) -> Int -> Int -> a ->
    [e] -> [a]
explore objective disim extend vis_range pool_size empty_sol elements = let
    expan = explore' objective disim extend vis_range pool_size elements
    solutions = takeWhile (not . null) (tail $ iterate expan [empty_sol])
    in map snd $ reverse $
    L.sort $ map (\a -> (objective a, a)) $ concat solutions

explore' :: (Ord a, Real o, Ord d) =>
    (a -> o) -> (a -> a -> d) -> (e -> a -> a) -> Int -> Int ->
    [e] -> [a] -> [a]
explore' objective disim extend vis_range pool_size elements previous = let
    nextgen = S.toList $ S.fromList [new | e <- elements, a <- previous,
        let new = extend e a, objective a < objective new, new /= a]
    in reduce objective disim vis_range pool_size nextgen

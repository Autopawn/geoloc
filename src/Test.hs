import Exploration
import Geoloc

import qualified Data.Set as S

grid_n = 5 :: Int
vis_range = 500 :: Int
pool_size = 2000 :: Int

main :: IO ()
main = do
    putStrLn $ "grid_n:    "++(show grid_n)
    putStrLn $ "vis_range: "++(show vis_range)
    putStrLn $ "pool_size: "++(show pool_size)
    let fI = fromIntegral
    let pts = [(fI x,fI y,fI (1 + (abs $ x-y))) |
            x <- [1..grid_n], y <- [1..grid_n]]
    let prob = euclidianProblem pts 20 5 1
    let best = explore profit (simpleDissimilitude prob) (addFacility prob)
            vis_range pool_size emptyCombi [0..facilityN prob - 1]
    print $ map (\c -> (profit c,map (\f -> let (x,y,_) = pts !! f in (x,y)) $
        S.toList (facilities c))) best

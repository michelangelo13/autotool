module Autolib.NFA.Determine where

-- vom NFA zum DFA

--  $Id$

import Autolib.NFA.Type
import Autolib.NFA.Eq
import qualified Autolib.NFA.Example
import qualified Autolib.NFA.Check
import Autolib.NFA.Restrict
import Autolib.NFA.Some
import Autolib.NFA.Minimize
import Autolib.NFA.Normalize
import Autolib.NFA.Det

import Autolib.Inter.Types
import Autolib.Util.Datei
import Autolib.Util.Size
import Autolib.Util.Cache
import Autolib.Util.Seed
import Autolib.Util.Zufall
import Autolib.Set
import Autolib.ToDoc
import Autolib.Reporter

import qualified Challenger as C


data Determine = Determine deriving ( Eq, Ord, Show, Read )

-- DetermineInstance
data DI = DI { nea :: NFA Char Int
             , alphabet :: Set Char
             , dea ::  NFA Char Int
             , config :: Conf  -- TODO: optinal machen , minimiert :: Bool
             }
    deriving ( Show )


-- p,b,i = problem,instance,beweis

instance C.Partial  Determine DI ( NFA Char Int )  where
    describe p i =
            let minitxt = 
	          if (mustmini $ config i) 
	          then " minimierten, vollständigen" 
	          else ""
            in  vcat
		[ text "Gegeben ist der Automat"
		, nest 4 $ toDoc ( nea i)
		, text $ "Finden Sie einen dazu äquivalenten" 
			  ++ minitxt
			  ++ " deterministischen Automaten!"
		]

    initial p i   = NFA.Example.example

    -- partielle korrektheit
    partial p i b = do
        restrict_states b -- 
        restrict_alpha ( alphabet i ) b 
        NFA.Check.deterministisch b -- muss dea sein

    total   p i b = do

    -- sind die automatensprache von i und b gleich?
    f <- equ ( informed ( text "Sprache des gegebenen Automaten") ( nea i ))
            ( informed ( text "Sprache Ihres Automaten" )        b )

    assert f $ text "Stimmen die Sprachen überein?"

	-- b minimiert?
    -- TODO: if (mustmini . config) i then
    let isize = size $ dea  i
    let bsize = size b
    if (mustmini . config) i 
       then assert ( isize == bsize ) $ text "Ist Ihr Automat minimiert?"
	   else return ()
    return () 

data Conf = Conf
         { alpha :: Set Char
         , nea_size :: Int
         , min_dea_size :: Int
         , max_dea_size :: Int
	 , mustmini :: Bool
	 , randomizer :: Int
         }
    deriving ( Eq, Ord, Read, Show )

throw :: Conf -> IO ( NFA Char Int, NFA Char Int, NFA Char Int )
throw conf = repeat_until
    ( do a <- nontrivial ( alpha conf ) ( nea_size conf )
         let b = normalize $ det a 
         let d = minimize0 a
         return ( a, b, d )
    ) ( \ ( a, b, d ) -> 
                  size d < size b
	       && min_dea_size conf <= size d 
               && size d <= max_dea_size conf
    )

determine :: String -- aufgabe (major)
     -> String -- aufgabe (minor)
     -> Conf
     -> Var  Determine DI ( NFA Char Int )
determine auf ver conf = 
    Var { problem = Determine
        , aufgabe = auf
        , version = ver
        , key = \ matrikel -> do 
          return matrikel
        , gen = \ key -> do
          seed $ randomizer conf * read key
          ( i, _, b ) <- cache (  Datei { pfad = [ "autotool", "cache"
                                              , auf, ver
                                              ]
                                     , name = key
				     , extension = "cache"
                                     }
                            ) ( throw conf )
          return $ do
            return $ DI { nea = i
                       , alphabet = alpha conf
                       , dea = b -- merken uns auch einen zielautomat
                       , config = conf
                       }
        }




-- | ein Code ist beschrieben durch 
-- * length: anzahl der bits pro code-wort
-- * size: anzahl der code-wörter
-- * dist: minimaler Hamming-Abstand der code-wörter
-- es gibt deswegen drei aufgabentypen:
-- jeweils zwei parameter sind fixiert,
-- der dritte ist zu optimieren

module Code.Hamming 

( module Code.Hamming.Data
, make
)

where

import Prelude hiding ( length )

import Code.Hamming.Data
import Code.Hamming.Partial

import Inter.Types
import Control.Monad ( mzero )

{-    

version_tag :: Config -> String
version_tag conf = do
    ( f, tag ) <- attributes
    case f conf of
        (_, i) -> take 1 tag ++ show i

make :: Config
     -> IO Variant
make conf = return $ Variant
     $ Var { problem = Hamming
	   , tag = show Hamming ++ "-" ++ version_tag conf
	   , key = \ matrikel -> return undefined
           , gen = \ _ -> do
                 return $ return conf
	   }
-}

make :: Make
make = direct Hamming Code.Hamming.Data.example

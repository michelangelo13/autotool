module Code.Check where

--  $Id$

import Code.Type
import ToDoc
import Sets
import Data.FiniteMap
import Data.List
import Control.Monad
import qualified Reporter.Checker as C
import qualified Reporter.Subset

istotal :: ( Ord a )
      => Set a
      -> Code a b
      -> Reporter ()
istotal xs code = do
    inform $ fsep 
	   [ text "ist", toDoc code, text "vollst�ndig"
	   , text "f�r", toDoc xs, text "?"
	   ]
    nested 4 $ Reporter.Subset.check 
	     ( text "zu codierende Buchstaben" , xs )
	     ( text "tats�chlich codierte Buchstaben", mkSet $ keysFM code )

isprefix :: ( Ord a, Eq b )
      => Code a b
      -> Reporter ()
isprefix code = do
    inform $ text "ist" <+> toDoc code <+> "ein Pr�fix-Code?"
    sequence_ $ do
        (x, cs) <- fmToList code
        (y, ds) <- fmToList code
	guard $ x /= y
	return $ do
            when ( isPrefixOf cs ds ) $ reject
	       $ text "Nein:" <+> toDoc (x, cs) <+> toDoc (y, ds)
    inform $ text "Ja."

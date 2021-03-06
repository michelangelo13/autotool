-- © 2001 Peter Thiemann
module Wash.HTMLBase 
  (ATTR_(), attr_, attr_name, attr_value
  ,ELEMENT_(), element_, empty_, cdata_, comment_, doctype_
  ,CDATA_OPTIONS(..)
  ,add_, add_attr_)
where

import Char

-- untyped layer
-- attributes

data ATTR_ =
  ATTR_ { attr_name :: String
        , attr_value :: String
	}

attr_ = ATTR_

-- elements

data ELEMENT_ =
    ELEMENT_ { tag :: String
    	     , attrs :: [ATTR_]
	     , elems :: [ELEMENT_]
	     }
  | EMPTY_   { tag :: String
  	     , attrs :: [ATTR_]
	     }
  | CDATA_ String
  | COMMENT_ String
  | DOCTYPE_ { doctype :: [String]
  	     , elems :: [ELEMENT_]
	     }

data CDATA_OPTIONS = CDATA_ENCODED | CDATA_FORMATTED
  deriving (Eq)

element_ = ELEMENT_
empty_ = EMPTY_
cdata_ opt = CDATA_ . format . encode
  where format | CDATA_FORMATTED `elem` opt = id
	       | otherwise = htmlFormat
	encode | CDATA_ENCODED `elem` opt = id
	       | otherwise = htmlEncode
comment_ = COMMENT_
doctype_ = DOCTYPE_

add_ e_ e'_ = e_ { elems = e'_ : elems e_}
add_attr_ e_ att = 
  let nameOfAtt = attr_name att
      all_attrs = attrs e_
      f [] = Nothing
      f (att' : attrs) = if attr_name att' == nameOfAtt 
      			 then return (att : attrs)
			 else f attrs >>= \ attrs' -> return (att' : attrs')
      new_attrs = case f all_attrs of
		    Nothing -> att : all_attrs
		    Just attrs -> attrs
  in  e_ { attrs = new_attrs }

-- show functions

instance Show ATTR_ where
  showsPrec i = shows_attribute
  showList    = shows_attributes

shows_attributes :: [ATTR_] -> ShowS
shows_attributes atts = foldr (.) id (map shows_attribute atts)

shows_attribute :: ATTR_ -> ShowS
shows_attribute a =
  showChar ' ' . showString (attr_name a) .
  case attr_value a of
    "()" ->
      id
    str@('\"':_) ->
      showString "=\"" . showString (read str) . showString "\""
    str ->
      showString "=\"" . showString str . showString "\""

instance Show ELEMENT_ where
  showsPrec i = shows_element
  showList = shows_elements

shows_elements :: [ELEMENT_] -> ShowS
shows_elements elts = foldr (.) id (reverse (map shows_element elts))

shows_element :: ELEMENT_ -> ShowS
shows_element (EMPTY_ tag atts) =
  showChar '<' . showString tag . shows atts . showString "\n/>"
shows_element (ELEMENT_ tag atts elts) =
  showChar '<' . showString tag . shows atts . showChar '>'
  . shows_elements elts
  . showString "</" . showString tag . showString "\n>"
shows_element (DOCTYPE_ strs elems) =
  showString "<!DOCTYPE" . 
  foldr (\str f -> showChar ' ' . showString str . f) id strs . showString "\n>" .
  showString "<!-- generated by WASH/HTML 0.9\n-->" .
  shows_elements elems .
  showChar '\n'
shows_element (CDATA_ str) =
  showString str
shows_element (COMMENT_ str) =
  showString "<!-- " . showString str . showString "\n-->"

htmlEncode "" = ""
htmlEncode (x:xs) = 
	case x of
	  '&' -> "&amp;" ++ htmlEncode xs
	  '<' -> "&lt;"  ++ htmlEncode xs
	  '>' -> "&gt;"  ++ htmlEncode xs
	  '\"' -> "&quot;" ++ htmlEncode xs
	  _ -> x : htmlEncode xs

htmlFormat s = s
{--htmlFormat "" = ""
htmlFormat (x:xs) =
	if isSpace x then
	  "\n " ++ htmlFormat (dropWhile isSpace xs)
	else
	  x : htmlFormat xs	  
--}


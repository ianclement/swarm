{-# LANGUAGE TypeFamilies #-}

-- |
-- SPDX-License-Identifier: BSD-3-Clause
--
-- Parser for the Swarm language.  Note, you probably don't want to
-- use this directly, unless there is a good reason to parse a term
-- without also type checking it; use
-- 'Swarm.Language.Pipeline.processTerm' instead, which parses,
-- typechecks, elaborates, and capability checks a term all at once.
module Swarm.Language.Parser (
  readTerm,
  readTerm',
) where

import Data.Bifunctor (bimap)
import Data.Sequence (Seq)
import Data.Text (Text)
import Swarm.Language.Parser.Core (ParserError, runParser)
import Swarm.Language.Parser.Lex (sc)
import Swarm.Language.Parser.Term (parseTerm)
import Swarm.Language.Syntax (Comment, Syntax)
import Swarm.Util.Parse (fullyMaybe)
import Text.Megaparsec.Error (errorBundlePretty)
import Witch (from)

-- | Parse some input 'Text' completely as a 'Term', consuming leading
--   whitespace and ensuring the parsing extends all the way to the
--   end of the input 'Text'.  Returns either the resulting 'Term' (or
--   'Nothing' if the input was only whitespace) or a pretty-printed
--   parse error message.
readTerm :: Text -> Either Text (Maybe Syntax)
readTerm = bimap (from . errorBundlePretty) fst . runParser (fullyMaybe sc parseTerm)

-- | A lower-level `readTerm` which returns the megaparsec bundle error
--   for precise error reporting, as well as the parsed comments.
readTerm' :: Text -> Either ParserError (Maybe Syntax, Seq Comment)
readTerm' = runParser (fullyMaybe sc parseTerm)
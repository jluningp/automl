import System.Environment
import System.Process
import System.IO
import Control.Monad
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Token
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC

data Typ = Atom String
         | Arrow Typ Typ
         | Star Typ Typ
         | Plus Typ Typ
         | Unit
         | Void
         deriving Show

languageDef =
  emptyDef { Token.identStart      = char '\''
           , Token.identLetter     = letter
           , Token.reservedOpNames = ["+", "*", "->", "unit", "void"]
           }

lexer = Token.makeTokenParser languageDef

identifier = Token.identifier lexer
reservedOp = Token.reservedOp lexer
whiteSpace = Token.whiteSpace lexer
parens     = Token.parens     lexer


tExpression :: Parser Typ
tExpression = buildExpressionParser tOperators tTerm


tOperators = [ [Infix (reservedOp "*" >> return Star) AssocLeft,
                 Infix (reservedOp "+" >> return Plus) AssocLeft],
               [Infix (reservedOp "->" >> return Arrow) AssocRight]
             ]

tTerm = parens tExpression
  <|> liftM Atom identifier
  <|> (reservedOp "unit" >> return Unit)
  <|> (reservedOp "void" >> return Void)

whileParser :: Parser Typ
whileParser = whiteSpace >> tExpression


toSMLType :: Typ -> String
toSMLType (Atom s) = "Atom " ++ "\"" ++ s ++ "\""
toSMLType (Arrow t1 t2) = "Imp(" ++ toSMLType t1 ++ "," ++ toSMLType t2 ++ ")"
toSMLType (Star t1 t2) = "And(" ++ toSMLType t1 ++ "," ++ toSMLType t2 ++ ")"
toSMLType (Plus t1 t2) = "Or(" ++ toSMLType t1 ++ "," ++ toSMLType t2 ++ ")"
toSMLType Unit = "True"
toSMLType Void = "False"

parseString :: String -> String
parseString str =
  case parse whileParser "" str of
    Left e  -> error $ show e
    Right r -> toSMLType r

parseFile :: String -> IO Typ
parseFile file =
  do program  <- readFile file
     case parse whileParser "" program of
       Left e  -> print e >> fail "parse error"
       Right r -> return r

runProcess :: IO ()
runProcess =
  let str = parseString "'a * 'a -> 'a" in
    do
      (Just hin, Just hout, _, _) <- createProcess (proc "sml" ["-m", "sources.cm"]){ std_out = CreatePipe,
                                                                                      std_in = CreatePipe }
      contents <- hGetContents hout
      hPutStr hin $ "open G4ip; open Prop; Option.map (Term.toML) (certify (" ++ str ++ "));"
      (_, s) <- return (B.breakSubstring (BC.pack "SOME") (BC.pack contents))
      (s, _) <- return (B.breakSubstring (BC.pack ":") s)
      putStrLn (BC.unpack s)
      (_, s) <- return (B.breakSubstring (BC.pack "\"") s)
      print s
      (s, _) <- return (B.breakSubstring (BC.pack "\"") s)
      print s
      return ()

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> print "Usage: ./parse <string>"
    x:xs -> putStrLn (parseString x)

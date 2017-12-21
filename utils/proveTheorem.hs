import System.Environment
import System.Process
import System.IO
import Control.Monad
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Token
import Prop
import G4ip
import qualified Term as Term

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


tExpression :: Parser Prop
tExpression = buildExpressionParser tOperators tTerm


tOperators = [ [Infix (reservedOp "*" >> return And) AssocLeft,
                 Infix (reservedOp "+" >> return Or) AssocLeft],
               [Infix (reservedOp "->" >> return Imp) AssocRight]
             ]

tTerm = parens tExpression
  <|> liftM Atom identifier
  <|> (reservedOp "unit" >> return PTrue)
  <|> (reservedOp "void" >> return PFalse)

whileParser :: Parser Prop
whileParser = whiteSpace >> tExpression

parseString :: String -> Prop
parseString str =
  case parse whileParser "" str of
    Left e  -> error $ show e
    Right r -> r


proveTheorem :: String -> String
proveTheorem str = case certify $ parseString str of
                     Nothing -> "raise Fail (\"Could not prove " ++ str ++ ".\")"
                     Just code -> Term.toML code


main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> print "Usage: ./parse <string>"
    [x] -> putStrLn $ (proveTheorem x)
    _ -> print "Usage: ./parse <string>"

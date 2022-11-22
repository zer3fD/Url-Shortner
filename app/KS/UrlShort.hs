{-#LANGUAGE OverloadedStrings#-}
{-#LANGUAGE QuasiQuotes#-}

module KS.UrlShort where

----------------------IMPORTS---------------------------------------
import System.Random
import qualified Data.Text as T
import Data.Text.Encoding     (encodeUtf8,decodeUtf8)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Binary as Bin
import Crypto.Hash (hash, SHA256 (..), Digest)
import Data.ByteArray.Encoding (convertToBase, Base (Base64),convertFromBase)
--------------------------------------------------------------------
--Encode or Hash
-- For Now Hash and Encode.
--Shorten Url using key
type Key = BS.ByteString
hasher :: Key -> Digest SHA256
hasher = hash

--Convert Hash to Base64 encoded
converter :: Key -> Key
converter text = convertToBase Base64 (hasher text)

--decode the encode to Int
decoder :: Key -> Int
decoder text = Bin.decode $ BSL.fromStrict $ encodeUtf8 $ decodeUtf8 text
--------------------------------------------------------------------
url text = BS.take 6 (converter text)
-------------------------------------------------------------------------------
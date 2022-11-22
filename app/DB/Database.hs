{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module DB.Database where

------------IMPORTS------------------------------
import qualified Data.Map as M
import qualified Data.Set as S
import           Data.Int(Int64)
import           Control.Applicative
import qualified Data.Text as T
import           Database.SQLite.Simple
import           Database.SQLite.Simple.FromRow
import           Database.SQLite.Simple.ToField
import           Database.SQLite.Simple.Internal
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.Aeson.Parser
import           GHC.Generics
import qualified Data.ByteString as BS
import Data.Text.Encoding (encodeUtf8,decodeUtf8)

import KS.UrlShort as Url
------------IMPORTS------------------------------

-----------Schema-------------------------------
data User = User{
                  name :: T.Text      
                  ,host :: T.Text
                }deriving (Eq,Read,Show,Generic)

instance ToJSON User
instance FromJSON User


instance FromRow User where
    fromRow = User <$> field <*> field

-- when inserting a new Person, ignore personId. SQLite will provide it for us.
instance ToRow User where
  toRow (User pName pHost) = toRow (pName,pHost)


data Links = Links{
                    username :: T.Text
                    ,link :: T.Text
                    ,short :: T.Text
                    }deriving (Eq,Read,Show,Generic)
                    
instance FromRow Links where
    fromRow = Links <$> field <*> field <*> field

-- when inserting a new Person, ignore personId. SQLite will provide it for us.
instance ToRow Links where
  toRow (Links pName pLink pShort) = toRow (pName,pLink,pShort)


 -----------Schema-------------------------------
listUsers = do
    conn <- open "user.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS user (username TEXT PRIMARY KEY,host TEXT)"
    xs <- query_ conn "SELECT * FROM user" :: IO [User]
    mapM_ print xs
    close conn

addUser user@(User name hosts) = do
    conn <- open "user.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS user (username TEXT PRIMARY KEY,host TEXT)"
    execute conn "INSERT INTO user (username,host) VALUES (?,?)" (user)
    close conn

-- addKey :: T.Text -> T.Text -> IO    

addKey k userN = do
    conn <- open "user.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS url (username TEXT,link TEXT,short TEXT)"
    let sSh = decodeUtf8 (Url.url (encodeUtf8 k))
    executeNamed conn "IF EXISTS (SELECT link FROM url where username = :uN AND link = :lN) BEGIN SELECT 'KEY EXISTS' END  ELSE BEGIN INSERT INTO url (username,link,short) VALUES (:uN,:lN,:lS) END" [":uN" := (userN::T.Text) , ":lN" := (k::T.Text) , ":lS" := (sSh::T.Text)]
    close conn  

delKey k userN = do
    conn <- open "user.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS url (username TEXT,link TEXT,short TEXT)"
    executeNamed conn "IF EXISTS (SELECT link FROM url where username = :uN AND link = :lN) BEGIN SELECT 'Doesn't have Key' END  ELSE BEGIN DELETE FROM url (username,link) VALUES (:uN,:lN) END" [":uN" := (userN :: T.Text), ":lN" := (k::T.Text)]
    close conn
------------------------------------------------------------------------------------------












-- checkList :: a -> a -> Bool
-- checkList x xs = x `elem` xs    
{--
"
IF EXISTS (SELECT link FROM url where username = :uN AND link = :lN)
BEGIN
    SELECT 'KEY EXISTS'
END
ELSE
BEGIN
    UPDATE url
    INSERT INTO url (username,link) VALUES (:uN,:lN)
END
"[":uN" := userN , ":lN" := k]
--}

----------------------------------SQL Commands---------------------------
-- add :: Query
-- add = " \
--         \ IF EXISTS (SELECT link FROM url where username = :uN AND link = :lN)\
--         \ BEGIN\
--             \SELECT 'KEY EXISTS'\
--         \END\
--         \ELSE\
--         \BEGIN\
--             \UPDATE url\
--             \INSERT INTO url (username,link) VALUES (:uN,:lN)\
--         \END\
--        \"[":uN" := userN , ":lN" := k]\


----------------------------------SQL Commands---------------------------
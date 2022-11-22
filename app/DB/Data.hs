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
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DeriveAnyClass #-}

module DB.Data where

------------IMPORTS------------------------------
import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH
import           Control.Applicative
import qualified Data.Text as T
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.Aeson.Parser
import           GHC.Generics
import qualified Data.ByteString as BS
import Data.Text.Encoding (encodeUtf8,decodeUtf8)
import Yesod

import KS.UrlShort as Url
------------IMPORTS------------------------------

-----------Schema-------------------------------

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
User
    name T.Text
    host T.Text
    UniqueUsername name
    UniqueUserHost host
    deriving Show
Links
    uname UserId
    key T.Text
    short T.Text
    UniqueLinksKey key
    UniqueLinksShort short
    deriving Show
|]

-------------------------------------
addUser name host = insertUniqueEntity $ User name host
delUser name = deleteBy $ UniqueUsername name 

addKey userName key = do
    uu <- getBy $ UniqueUsername userName
    case uu of
        Nothing -> error "User Not Exists"
        Just (Entity userId person) -> insertUniqueEntity $ Links userId key enS
    where enS = decodeUtf8 (Url.url (encodeUtf8 key))

delKey username key = do
    uu <- getBy $ UniqueUsername username
    case uu of
        Nothing -> error "User Not Exists"
        Just (Entity userId person) -> deleteBy $ UniqueLinksKey key
-------------------------------------
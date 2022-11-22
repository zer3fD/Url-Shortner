{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE ViewPatterns               #-}

module Web where

import qualified  Data.Text as T
import Yesod
import Database.Persist.Sqlite
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.Aeson.Parser
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.Logger (runStderrLoggingT)
import DB.Data

data WebAPI = WebAPI ConnectionPool

mkYesod "WebAPI" [parseRoutes|
-- / UsersR GET
/user/add/#Username/#Host AddUserR POST
-- /user/addKey/#Username/#SecretKey AddKeyR POST
-- /user/delKey/#Username/#SecretKey DelKeyR POST
|]

instance Yesod WebAPI

instance YesodPersist WebAPI where
    type YesodPersistBackend WebAPI = SqlBackend
    runDB action = do
        WebAPI pool <- getYesod
        runSqlPool action pool


type Username = T.Text
type Key = T.Text
type Host = T.Text

openConnectionCount :: Int
openConnectionCount = 10

--postAddUserR :: Username -> Host -> Handler Value
postAddUserR name host = do
	uu <- addUser name host
	case uu of
		Nothing -> return $ object ["msg" .= "User Exist"]
		_ -> do
			-- addUser name host
			return $ keyValueEntityToJSON uu
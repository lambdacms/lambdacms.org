{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module LambdaCmsOrg.Page.Models where

import           Data.Time                  (UTCTime)
import           Data.Typeable              (Typeable)
import           Database.Persist.Quasi
import           LambdaCmsOrg.Page.PageType
import           Text.Markdown
import           Yesod.Text.Markdown
import           Yesod

share [mkPersist sqlSettings, mkMigrate "migrateLambdaCmsOrgPage"]
    $(persistFileWith lowerCaseSettings "config/models")

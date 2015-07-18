{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module LambdaCmsOrg.Tutorial.Models where

import           Data.Text              (Text)
import           Data.Time              (UTCTime)
import           Data.Typeable          (Typeable)
import           Database.Persist.Quasi
import           Text.Markdown
import           Yesod
import           Yesod.Text.Markdown    ()

share [mkPersist sqlSettings, mkMigrate "migrateLambdaCmsOrgTutorial"]
    $(persistFileWith lowerCaseSettings "config/models")

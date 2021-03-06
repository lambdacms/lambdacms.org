{-# LANGUAGE TemplateHaskell #-}

module LambdaCmsOrg.Page.PageType where

import Database.Persist.TH

data PageType = Homepage
              | Documentation
              | Community
              | License
                deriving (Show, Read, Eq, Bounded, Enum)

derivePersistField "PageType"

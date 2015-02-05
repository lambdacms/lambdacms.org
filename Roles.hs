module Roles where

import           ClassyPrelude.Yesod

data RoleName = Admin
              deriving (Eq, Ord, Show, Read, Enum, Bounded, Typeable)

derivePersistField "RoleName"

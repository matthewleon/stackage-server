{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Home where

import           Data.Slug
import qualified Database.Esqueleto as E
import           Import

-- This is a handler function for the GET request method on the HomeR
-- resource pattern. All of your resource patterns are defined in
-- config/routes
--
-- The majority of the code you will write in Yesod lives in these handler
-- functions. You can spread them across multiple files if you are so
-- inclined, or create a single monolithic file.
getHomeR :: Handler Html
getHomeR = do
    fpHandle <- mkSlug "fpcomplete"
    stackages <- runDB $ E.select $ E.from $ \(stackage `E.InnerJoin` user) -> do
        E.on (stackage E.^. StackageUser E.==. user E.^. UserId)
        E.orderBy [E.desc $ stackage E.^. StackageUploaded]
        E.where_ (E.like (user E.^. UserDisplay) (E.val "%@fpcomplete.com") E.||.
                  user E.^. UserHandle E.==. E.val fpHandle)
        E.limit 4
        return
            ( stackage E.^. StackageIdent
            , stackage E.^. StackageTitle
            , stackage E.^. StackageUploaded
            , user E.^. UserDisplay
            , user E.^. UserHandle
            )
    defaultLayout $ do
        setTitle "Stackage Server"
        $(widgetFile "homepage")

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import AWS.Lambda.Runtime (mRuntime)
import Control.Exception
import Data.Aeson
import Data.Text (Text)
import GHC.Generics
import Katip
import System.IO (stdout)

data Event = Event
  { eventName :: Text
  , eventValue :: Int
  } deriving (Show, Generic)

instance FromJSON Event

data LambdaResult = LambdaResult
  { resultMessage :: Text
  } deriving (Show, Generic)

instance ToJSON LambdaResult


runKatip :: KatipContextT IO b -> IO b
runKatip action = do
  handler <- mkHandleScribe ColorIfTerminal stdout (permitItem InfoS) V2
  let makeLogEnv = do env <- initLogEnv "MyApp" "production"
                      registerScribe "stdout" handler defaultScribeSettings env
  bracket makeLogEnv closeScribes $ \logEnv -> runKatipContextT logEnv () "main" action


main :: IO ()
main = runKatip $ mRuntime $ \event -> do
  logFM InfoS "Hello, Lambda!"
  logFM InfoS $ "Got event: " <> logStr (eventName event)
  return $ LambdaResult "Success!"

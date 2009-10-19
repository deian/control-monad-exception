{-# LANGUAGE CPP #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverlappingInstances, FlexibleInstances #-}

{-|
Defines the @Throws@ binary relationship between types.
-}

module Control.Monad.Exception.Throws (Throws, Caught, UncaughtException, NoExceptions, ParanoidMode) where

#if __GLASGOW_HASKELL__ < 610
import Control.Exception.Extensible (Exception(..), SomeException)
#else
import Control.Exception (Exception(..), SomeException)
#endif


-- | A type level witness of a exception handler.
data Caught e l


-- Closing a type class with an unexported constraint
--  @Private@  is unexported
class Private l
instance Private (Caught e l)

{-| @Throws@ is a type level binary relationship
    used to model a list of exceptions.

    Usually there is no need for the user
    to add further instances to @Throws@ except
    to encode subtyping.
    As there is no way to automatically infer
    the subcases of an exception,  they have to be encoded
    manually mirroring the hierarchy defined in the defined
    'Exception' instances.

    For example,
    the following instance encodes that @MyFileNotFoundException@ is
    a subexception of @MyIOException@ :

 > instance Throws MyFileNotFoundException (Caught MyIOException l)

   'Throws' is not a transitive relation and every ancestor relation
   must be explicitly encoded.

>                                                 --   TopException
>                                                 --         |
>   instance Throws MidException   TopException   --         |
>                                                 --   MidException
>   instance Throws ChildException MidException   --         |
>   instance Throws ChildException TopException   --         |
>                                                 --  ChildException

'SomeException' is automatically
   an ancestor of every other exception type.


-}

class (Private l, Exception e) => Throws e l

instance Throws e l  => Throws e (Caught e' l)
instance Exception e => Throws e (Caught e l)

-- | @SomeException@ is at the top of the exception hierarchy
--   .
--   Capturing SomeException captures every possible exception
instance Exception e => Throws e (Caught SomeException l)

-- | Uncaught Exceptions model unchecked exceptions (a la RuntimeException in Java)
--
--   In order to declare an unchecked exception @e@,
--   all that is needed is to make @e@ an instance of @UncaughtException@
class Exception e => UncaughtException e
instance UncaughtException e => Throws e NoExceptions


data NoExceptions
instance Private NoExceptions

data ParanoidMode
instance Private ParanoidMode
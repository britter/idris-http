module Http.Request

import Data.Vect
import Http.Uri

%access public

||| The HTTP Method which is either POST or GET
data Method = POST | GET | HEAD

instance Show Method where
  show POST = "POST"
  show GET  = "GET"
  show HEAD = "HEAD"

||| A String-alias for Hosts.
Host : Type
Host = String

||| A type alias for HTTP Versions.
||| HttpVersion shall have the value "HTTP/1.0" or "HTTP/1.1"
HttpVersion : Type
HttpVersion = String

httpVersion : HttpVersion
httpVersion = "HTTP/1.1"

||| A data type for requests.
||| A request consists out of a method,
||| a host, a port, a path, a query and a http version.
record Request where
  constructor MkRequest
  ||| The requests method. Either POST or GET.
  method   : Method

  ||| The URI we're attempting to access.
  uri : URI

  ||| The post data which gets send when method = POST.
  postData : Vect p (String, String)

  ||| Headers to pass along.
  headers : Vect q (String, String)

urlEncode : String -> String
urlEncode = id -- TODO: Implement

||| This fiunctions folds a list of query parameters
||| into a query string without prepending '?'.
||| It will also url encode all strings.
|||
||| For example `encodeQuery [("hello", "world"), ("foo", "bar")]`
||| encodes to "hello=world&foo=bar".
|||
||| @ n The length of the vector => the number of query parameters
||| @ q The vector of query param tuples
encodeQuery : (q : Vect n (String, String)) -> String
encodeQuery [] = ""
encodeQuery ((k,v) :: []) = urlEncode k ++ "=" ++ urlEncode v
encodeQuery ((k,v) :: xs) =
  urlEncode k ++ "=" ++ urlEncode v ++ "&" ++ encodeQuery xs

||| This is the first line of a Full-Request defined in RFC1945 Section 5.1.
||| This does not end with a CRLF
|||
||| @ req The request to get the request line from.
private
requestLine : (req : Request) -> String
requestLine req =
  show (method req) ++ " " ++ uriToString (uri req) ++ " " ++ httpVersion

||| This returns a String containing all headers
||| which are seperated by CRLF. This also
||| prepends a CRLF so it can be directly appended to the
||| request line.
|||
||| @ req The request to get the header string from.
private
requestHeaders : (req : Request) -> String
requestHeaders req =
  foldl (\x, (k,v) => x ++ "\r\n" ++ k ++ ": " ++ v) "" (headers req)

resolveRequest : Request -> String
resolveRequest req =
  requestLine req ++ requestHeaders req ++ "\r\n\r\n"
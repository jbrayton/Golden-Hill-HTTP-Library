# Golden Hill HTTP Library

This library provides functionality to make working with HTTP APIs easier. Specifically, it provides:

* Consolidated detection and message generation for HTTP errors (connection issues, HTTP status codes, JSON deserialization, interpretation of JSON data).
* The ability to disable redirects, to only allow redirects to HTTPS URLs, or to block redirects from HTTPS URLs to non-HTTPS URLs.
* TLS/SSL Pinning.
* Convenience methods on URLRequest and HTTPURLResponse.

To use with Carthage, add this to your Cartfile:

    github "jbrayton/Golden-Hill-HTTP-Library" "1.0.1"

Pull requests welcome.

## URLSession Extension

The URLSession extension encapsulates the work of error checking, parsing the JSON response body, and calling a user-defined method to convert the deserialized JSON into a suitable object.

These are the method declarations:

```swift
public func ghs_dataTask<T>( 
    request: URLRequest, 
    apiLabel: String, 
    operationLabel: String, 
    jsonResponseInterpreter: @escaping JsonResponseInterpreter<T>, 
    errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, 
    handler: @escaping HTTPAPIResultHandler<T> )
    -> URLSessionDataTask

public func ghs_dataTask( 
    request: URLRequest, 
    apiLabel: String, 
    operationLabel: String, 
    errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, 
    handler: @escaping HTTPAPIResultHandler<Void> )
    -> URLSessionDataTask
```
    
The key difference between the two methods above is that the second has no JSON response interpreter. Instead it assumes the request is successful if it gets a response with a 200, 201, 202, or 204 status code.

These are the parameters to these methods:

**request**: The request to be submitted.

**apiLabel**: The name of the service. For example, “Gmail” or “Feed Wrangler”. This is used to generate error messages.

**operationLabel**: A short name for the operation being performed. For example, “create label” or “subscribe”. This is used to generate error messages.

**jsonResponseInterpreter**: This converts a deserialized JSON object of type Any into a Swift object of type T? (T is the generic). If the method returns nil the library will return an error message indicating that the JSON response could not be interpreted.

**errorMessageInterpreter**: If the web service returns a 4xx or 5xx error and a JSON response body, this method will be called asking it to return a string describing the error based on that response body. This is useful for web services that embed error messages in JSON 4xx and 5xx responses. If this parameter is not specified or if the error message interpreter returns nil, an error message will be generated without it.

**handler**: A method that will accept the result of the request. The result object is based on the [Result](https://github.com/antitypical/Result) library. The result will be of type HTTPAPIResult. If successful and jsonResponseInterpreter returns an object, the Result object will have the result returned by jsonResultInterpreter. If successful and no jsonResponseInterpreter is specified, the Result object will be HTTPAPIResult with Void as the payload. If a failure occurs, the Result object will be a failure with an HTTPAPIError.

Some relevant type aliases:

```swift
public typealias ErrorMessageInterpreter = (Any) -> String?
public typealias JsonResponseInterpreter<T> = (Any) -> T?
public typealias HTTPAPIResult<T> = Result<T,HTTPAPIError>
public typealias HTTPAPIResultHandler<T> = (Result<T,HTTPAPIError>) -> Void
```

HTTPAPIError error objects contain these variables:

```swift
public var shortErrorMessage: String
public var detailedErrorMessage: String
public var combinedErrorMessage: String
```

In general, *shortErrorMessage* indicates what operation could not be performed, *detailedErrorMessage* provides the reason that the operation could not be performed, and *combinedErrorMessage* combines *shortErrorMessage* with *detailedErrorMessage*. If you are presenting an error in a UIAlertController, you might use the shortErrorMessage as the title and the *detailedErrorMessage* as the message. If you need one long string describing an error, you would use *combinedErrorMessage* instead.

For an example of this in action, here is a method that retrieves a list of subscriptions from a user’s Feedbin account:

```swift
func getSubscriptionList( credential: Credential, 
						  handler: @escaping HTTPAPIResultHandler<[Subscription]> ) {
	let urlString = "https://api.feedbin.com/v2/subscriptions.json"
	var request = URLRequest(url: URL(string: urlString)!)
	self.add(credential: credential, toRequest: &request)

	let dataTask = self.urlSession.ghs_dataTask(request: request, 
		apiLabel: String.localizedStringWithFormat("Feedbin"), 
		operationLabel: String.localizedStringWithFormat("get subscription list"), 
		jsonResponseInterpreter: self.interpretSubscriptionList, 
		handler: handler)

	dataTask.resume()
}
```

The JSON response interpreter in the sample above, self.interpretSubscriptionList(Any), is a separate function that is thoroughly unit tested and returns an array of Subscription objects. 

This method will delete a Feedbin subscription:

```swift
public func unsubscribe( credential: Credential, 
						 subscription: Subscription, 
						 handler: @escaping HTTPAPIResultHandler<Void> ) {
	let urlString = String(
	   format: "https://api.feedbin.com/v2/subscriptions/%@.json", 
	   arguments: [subscription.subscriptionId])
	var request = URLRequest(url: URL(string: urlString)!)
	request.httpMethod = "DELETE"
	self.add(credential: credential, toRequest: &request)
	let dataTask = self.urlSession.ghs_dataTask(request: request, 
		apiLabel: String.localizedStringWithFormat("Feedbin"), 
		operationLabel: String.localizedStringWithFormat("unsubscribe"), 
		handler: handler)
	dataTask.resume()
}
```

In both cases the work of validating that a response is received and that it has a successful status code is done by the library. In getSubscriptionList(...) the work of deserializing the JSON response is and sending it to the interpretSubscriptionList method is also done by the library.

## URLRequest Extension

The URLRequest extension provides convenience methods for URLRequest:

```swift
public mutating func ghs_setPostJson(_ jsonDictionary: [String: Any])
```

This sets the httpBody of the request to the dictionary serialized to JSON. It also sets the method to “POST” and sets the Content-Type of the request to “application/json”.

```swift
public mutating func ghs_setPostArgString( _ value: String )
```

This sets the httpBody of the request to the string and sets the method to “POST”.

```swift
public mutating func ghs_setBasicAuth( username: String, password: String )
```

This adds an Authorization header with the username and password for basic authentication.

## HTTPURLResponse Extension

The HTTPURLResponse extension adds two convenience methods onto HTTPURLResponse:

```swift
public func ghs_value(forHeaderNamed requestedHeaderName: String) -> String?
```

This returns the value of the specified header. The header name is case-insensitive.

```swift
public var ghs_redirectType: RedirectType
```

This returns the redirect type that the response represents: permanent, temporary, or none. This is the definition of RedirectType:

```swift
public enum RedirectType {
	case temporary
	case permanent
	case none
}
```


## Delegates

This library provides two delegate classes:

### SimpleURLSessionDelegate

SimpleURLSessionDelegate provides a simple way to manage redirects for a URLSession. The options are FollowRedirects.always, FollowRedirects.never, FollowRedirects.httpsOnly, and FollowRedirects.httpsOnlyWhenFromHttps. The last option will only follow a redirect to a URL other than an HTTPS URL if the referring URL is not an HTTPS URL.

This is the class declaration:

```swift
public class SimpleURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate
```

This is the constructor:

```swift
public init( followRedirects: FollowRedirects )
```

This is the declaration of FollowRedirects:

```swift
public enum FollowRedirects {
	case always
	case never
	case httpsOnly
	case httpsOnlyWhenFromHttps
}
```

### PinningURLSessionDelegate

PinningURLSessionDelegate provides SSL pinning functionality and the same redirect management that PinningURLSessionDelegate provides. The PinningURLSessionDelegate requires that the app have a local copy of allowed certificates in DER format.

This is the class declaration:

```swift
public class PinningURLSessionDelegate: SimpleURLSessionDelegate
```
    
This is the constructor:

```swift
public init( followRedirects: FollowRedirects, certificateUrls: [URL] )
```


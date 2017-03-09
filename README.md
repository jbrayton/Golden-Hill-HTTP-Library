# Golden Hill HTTP Library

This library provides functionality to make working with HTTP APIs easier. Specifically, it provides:

* Consolidated error handling functionality for HTTP requests (connection errors, HTTP status codes, JSON deserialization and interpretation errors).
* The ability to disable redirects, to only allow redirects to HTTPS URLs, or to only allow redirects to HTTPS URLs when redirected from an HTTPS URL.
* TLS/SSL Pinning.
* Convenience methods on URLRequest and HTTPURLResponse.

## URLSession Extension

The URLSession extension provides methods that remove the tedious work of determining whether a response was received, whether the status code indicates that the response was successful, and converting a JSON response into a JSON object.

These are the method declarations:

    public func ghs_dataTask<T>( request: URLRequest, apiLabel: String, operationLabel: String, jsonResponseInterpreter: @escaping JsonResponseInterpreter<T>, errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, handler: @escaping HTTPAPIResultHandler<T> )
    
    public func ghs_dataTask( request: URLRequest, apiLabel: String, operationLabel: String, errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, handler: @escaping HTTPAPIResultHandler<Void> ) -> URLSessionDataTask
    
The key difference between the two methods above is that the second has no JSON response interpretter. Instead it assumes the request is successful it gets a response with a 200, 201, 202, or 204 response code. It returns nothing to the caller.

The parameters to these methods break down as follows:

**request**: The request to be submitted.

**apiLabel**: The name of the service. For example, "Gmail" or "Feed Wrangler". "This is used to generate error messages.

**operationLabel**: A short name for the operation being performed. For example, "create label" or "subscribe".

**jsonResponseInterpreter**: This converts a deserialized JSON object of type Any into a Swift object of type T (the generic). If unable to perform the conversion for any reason, this method can return nil. The underlying method will return an error message indicating that the JSON response could not be interpreted. If this parameter is not specified, it will be assumed that the response body is not needed and that a response code of 200, 201, 202, or 204 indicates success.

**errorMessageInterpreter**: If the web service returns a 4xx or 5xx error and a JSON response body, this method will be called asking it to return a string describing the error based on that response body. Some web services embed error messages in JSON for 4xx or 5xx errors. If this parameter is not specified or if it returns nil, an error message will be generated without it.

**handler**: A method that will accept the result of the request. The result object is based on the [Result](https://github.com/antitypical/Result) library. If successful and a jsonResponseInterpreter returned an object, the Result object will have the result returned by jsonResultInterpreter. If successful and no jsonResponseInterpreter, the Result object will be Result<Void>. If a failure occurs, the Result object will be a failure with an HTTPAPIError.

Some relevant type aliases:

    public typealias ErrorMessageInterpreter = (Any) -> String?

    public typealias JsonResponseInterpreter<T> = (Any) -> T?

    public typealias HTTPAPIResult<T> = Result<T,HTTPAPIError>

    public typealias HTTPAPIResultHandler<T> = (Result<T,HTTPAPIError>) -> Void

HTTPAPIError error objects contain these variables:

    public var shortErrorMessage: String
    public var detailedErrorMessage: String
    public var combinedErrorMessage: String
    
In general, *shortErrorMessage* indicates that an operation could not be performed, *detailedErrorMessage* provides the reason that the operation could not be performed, and *combinedErrorMessage* concatenates the two together. If you are presenting an error in a UIAlertController, you might use the shortErrorMessage as the title and the *detailedErrorMessage* as the message. If you need one long string describing the situation, you would use *combinedErrorMessage* instead.

For an example of this in action, here is a method that retrieves a list of subscriptions from a user's Feedbin account:

    func getSubscriptionList( credential: Credential, handler: @escaping HTTPAPIResultHandler<[Subscription]> ) {
        let urlString = "https://api.feedbin.com/v2/subscriptions.json"
        var request = URLRequest(url: URL.ghs_from(string: urlString)!)
        
        // The ghs_setBasicAuth extension method is described further down.
        request.ghs_setBasicAuth(username: credential.username, password: credential.password)

        let dataTask = self.urlSession.ghs_dataTask(request: request, apiLabel: String.localizedStringWithFormat("Feedbin"), operationLabel: String.localizedStringWithFormat("retrieve subscription list"), jsonResponseInterpreter: self.parseFeedList, handler: handler)

        dataTask.resume()
    }

The JSON response interpreter, interpretSubscriptionList(Any), is a separate function that is thoroughly unit tested and that returns an array of Subscription objects. 

This code will unsubscribe the user from a subscription:

    public func unsubscribe( credential: Credential, subscription: Subscription, handler: @escaping HTTPAPIResultHandler<Void> ) {
        var request = URLRequest(url: URL.ghs_from(string: "https://newsblur.com/reader/delete_feed")!)
        self.add(credential: credential, toRequest: &request)
        request.ghs_setPostArgString(String(format: "feed_id=%@", arguments: [subscription.subscriptionId]))
        let dataTask = self.urlSession.ghs_dataTask(request: request, apiLabel: String.localizedStringWithFormat("Feedbin"), operationLabel: String.localizedStringWithFormat("unsubscribe"), handler: handler)
        dataTask.resume()
    }

In both cases the work of checking for an HTTP-level error, checking the status code, and checking the success of deserializing the JSON into a Swift object, and generating any appropriate error messages is done by this library.

## URLRequest Extension

The URLRequest extension provides convenience methods for URLRequest:

    public mutating func ghs_setPostJson(_ jsonDictionary: [String: Any])

This sets the httpBody of the request to the dictionary serialized to JSON. It also handles setting the method to "POST" and setting the Content-Type of the request to "application/json".

    public mutating func ghs_setPostArgString( _ value: String )

This sets the httpBody of the request to the string and sets the method to "POST".

    public mutating func ghs_setBasicAuth( username: String, password: String )

This adds an Authorization header with the username and password for basic authentication.

## HTTPURLResponse Extension

The HTTPURLResponse extension adds two convenience methods onto HTTPURLResponse:

    public func ghs_value(forHeaderNamed requestedHeaderName: String) -> String?

This returns the value of the specified header. The header name is case-insensitive.

    public var ghs_redirectType: RedirectType

This returns the redirect type that the response represents: permanent, temporary, or none. This is the definition of RedirectType:

    public enum RedirectType {
        case temporary
        case permanent
        case none
    }


## Delegates

This library provides two delegate classes:

### SimpleURLSessionDelegate

SimpleURLSessionDelegate provides a simple way to manage redirects for a URLSession. The options are FollowRedirects.always, FollowRedirects.never, FollowRedirects.httpsOnly, and FollowRedirects.httpsOnlyWhenFromHttps. The last option will only follow a redirect to a URL other than an HTTPS URL if the referring URL is not an HTTPS URL.

This is the class declaration:

    public class SimpleURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate

This is the constructor:

    public init( followRedirects: FollowRedirects )

This is the declaration of FollowRedirects:

    public enum FollowRedirects {
        case always
        case never
        case httpsOnly
        case httpsOnlyWhenFromHttps
    }

### PinningURLSessionDelegate

PinningURLSessionDelegate provides SSL pinning functionality and the same redirect management that PinningURLSessionDelegate provides. The PinningURLSessionDelegate requires that the app have a local copy of allowed certificates in DER format.

This is the class declaration:

    public class PinningURLSessionDelegate: SimpleURLSessionDelegate
    
This is the constructor:

    public init( followRedirects: FollowRedirects, certificateUrls: [URL] )


# AlamofireExample

Alamofire를 본격적으로 알아보기 전에 Alamofire를 이용한 APIClient 예제를 만들어보도록 하겠습니다.
APIClinet를 만드는 순서는 아래와 같습니다.

1. API Router: endpoint builder
2. API Client: 요청 생성 및 수행
3. Codable: JSON 분석 및 데이터 구조에 매핑
4. Futer/Pormises 사용
5. 구동을 위한 APP 만들기

## API Router: endpoint builder

[REST API와 endpoint](https://medium.com/@dydrlaks/rest-api-3e424716bab)
REST API에서 메소드는 같은 URI들에 대해서도 다른 요청을 하게끔 구별해주는 항목이 있습니다.  이것을 endpoint라고 합니다.

Endpoint를 제공하는 API 요청 buider를 만들어야 합니다.
Router는 http 메소드, http 헤더, 경로 및 매개 변수를 사용하여 endpoint를 제공합니다.
권장되는 방버 중 하나는 swift enum을 사용하여 api router를 만드는 것입니다. router 구현은 다음과 같습니다.
**APIRouter.swift**

```swift
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case login(email:String, password:String)
    case posts
    case post(id: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .posts, .post:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/login"
        case .posts:
            return "/posts"
        case .post(let id):
            return "/posts/\(id)"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [K.APIParameterKey.email: email, K.APIParameterKey.password: password]
        case .posts, .post:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
 
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
```

그리고 관리를 용이하게 하기 위한 `Constants.swift`을 만듭니다.

**Constants.swift**

```swift
import Foundation

struct K {
    struct ProductionServer {
        static let baseURL = "https://api.medium.com/v1"
    }
    
    struct APIParameterKey {
        static let password = "password"
        static let email = "email"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
```



그리고 하나의 라우터만 있으면서 엔드포인트가 여러개인 경우 프로토콜을 이용해 router 로직을 다른 router로 분리하여 정의할 수 있습니다.

```swift
protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}
```

이 프로토콜을 이용해 `UserEndpoint` 를 만들겠습니다.

**UserEndpoint.swift**

```swift
import Alamofire

protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

enum UserEndpoint: APIConfiguration {
    
    case login(email:String, password:String)
    case profile(id: Int)
 
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .profile:
            return .get
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .profile(let id):
            return "/profile/\(id)"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [K.APIParameterKey.email: email, K.APIParameterKey.password: password]
        case .profile:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
 
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
```

이제 네트워크 요청 후에 JSON 데이터를  클래스 및 구조체로 변환 할 준비가되었습니다.

## Codable

데이터 모델을 정의하고 Codable프로토콜을 채택합닌다.

**User.swift**

```swift
import Foundation

struct User: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let image: URL
}
```

**Article.swift**

```swift
import Foundation

struct Article: Codable {
    let id: Int
    let title: String
    let image: URL
    let author : String
    let categories: [Category]
    let datePublished: Date
    let body: String?
    let publisher: String?
    let url: URL?
}
```

그리고 Article 모델에는 `Category` 타입의 프로퍼티가 존재하므로 이를 정의해줘야 합니다.
현재 모든 모델이 `Codable` 프로토콜을 준수하고 있기때문에 표준 타입이 아닌 `Category` 또한 `Codable` 을 준수해야 합니다.

**Category.swift**

```swift
import Foundation

struct Category: Codable {
    let id: Int
    let name: String
    let parentID: Int?
}

extension Category {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case parentID = "parent_id"
    }
}
```

이제 모든 모델이 파싱준비가 되었습니다. 이제 요청을 수행하는 방법을 살펴보겠습니다. Codable에 대한 자세한 내용은 [여기1](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types), [여기2](http://minsone.github.io/programming/swift-codable-and-exceptions-extension)를 보시면 됩니다.

## Request

Alamofire를 사용할 것입니다. Alamofire의 설치방법은 [여기](https://github.com/Alamofire/Alamofire#installation)를 참고하시며 됩니다.

아래는 Alamofire를 이용해 login 요청을 하는 코드입니다.

**APIClient.swift**

```swift
import Alamofire

class APIClient {
    static func login(email: String, password: String, completion:@escaping (Result<User, AFError>)->Void) {
        AF.request(APIRouter.login(email: email, password: password))
                 .responseDecodable { (response: DataResponse<User, AFError>) in
                    completion(response.result)
        }
    }
}
```

이전에 만들었던 APIRouter의 login 메소드를 이용해 login 메서드를 호출하고 있습니다.

이제 article의 리스트를 요청하는 로직을 구현해보겠습니다.
본격적인 로직을 구현전에 우리의 article의 전용 date formatter 를 작성하겠습니다.

**DateFormatter.swift**

```swift
import Foundation

extension DateFormatter {
    static var articleDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
```

그리고 apiclient를 마저 작성해줍니다.

**APIClient.swift**

```swift
import Foundation
import Alamofire

class APIClient {
    static func login(email: String, password: String, completion:@escaping (Result<User, AFError>)->Void) {
        AF.request(APIRouter.login(email: email, password: password))
                 .responseDecodable { (response: DataResponse<User, AFError>) in
                    completion(response.result)
        }
    }
    
    static func getArticles(completion: @escaping (Result<[Article], AFError>) -> Void){
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.articleDateFormatter)
        
        AF.request(APIRouter.articles)
            .responseDecodable(decoder: jsonDecoder){ (response: DataResponse<[Article], AFError>) in
                completion(response.result)
        }
    }
}
```

로그인 request와 거의 동일하지만 약간의 차이가 있습니다.
커스텀 디코더를 전달했습니다. 
`.responseDecodable(decoder: jsonDecoder){ (response: DataResponse<[Article], AFError>)`
`responseRecodable` 메소드의 문서를 보겠습니다.

![image-20200227151736278](/Users/gihyunkim/Documents/neowiz/wimes_docs/Alamofire_example.assets/image-20200227151736278.png)

문서를 보면 기본 매개변수가 있는 2개의 매개변수 queue와 디코더가 있음을 알기 때문에 첫번째 로그인 요청에서 completionHandler인 responseDecodable을 호출할 때 하나의 매개변수를 전달한 것입니다.

getArticles의 request에서는 responseDecoable을 호출할 때 우리가 직접 정의한 `DateFormatter` 를 사용하기 때문에 이 형식에 맞춰서 분석을 해줘야 합니다.
따라서 `JSONDecoder` 를 사용했고, `jsonDecoder` 의 속성을 따로 정의를 해줬습니다.

```swift
jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.articleDateFormatter)
```



최종적으로 APIClient를 통해 네트워크 요청은 아래와 같습니다.

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        List{
            Button(action: self.login){
                Text("Login")
            }
            Button(action: self.getArticles){
                Text("Get Articles")
            }
        }
    }
    
    func login(){
        APIClient.login(email: "test@gamil.com", password: "myPassword") { result in
            switch result{
            case .success(let user):
                print(user)
            case .failure(let error):
                print("wimes's App Error")
                print(error.localizedDescription)
            }
        }
    }
    
    func getArticles(){
        APIClient.getArticles { result in
            switch result{
            case .success(let articles):
                print(articles)
            case .failure(let error):
                print("wimes's App Error")
                print(error.localizedDescription)
            }
        }
    }
}
```



그리고 반복적인 코드를 피하기 위해 `APIClient` 를 리팩토링 해주겠습니다.

**APIClient.swift**

```swift
import Foundation
import Alamofire

class APIClient {
    @discardableResult
    private static func performRequest<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest{
        return AF.request(route)
            .responseDecodable(decoder: decoder){ (response: DataResponse<T, AFError>) in
                completion(response.result)
        }
    }
    
    static func login(email: String, password: String, completion:@escaping (Result<User, AFError>)->Void) {
        AF.request(APIRouter.login(email: email, password: password))
                 .responseDecodable { (response: DataResponse<User, AFError>) in
                    completion(response.result)
        }
    }
    
    static func getArticles(completion: @escaping (Result<[Article], AFError>) -> Void){
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.articleDateFormatter)
        
        AF.request(APIRouter.articles)
            .responseDecodable(decoder: jsonDecoder){ (response: DataResponse<[Article], AFError>) in
                completion(response.result)
        }
    }
}
```

APIRouter 및 completion 파라미터를 전달할 때 request를 수행하는 `performRequest` 라는  메소드를 작성했습니다. 



## Reference

* https://medium.com/@AladinWay/write-a-networking-layer-in-swift-4-using-alamofire-and-codable-part-1-api-router-349699a47569


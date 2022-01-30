import Foundation

struct Newspaper {}

struct Book {}

struct Library {
    init(books: [Book], newspapers: [Newspaper]) {}
}

enum LibraryError: Error {
    case failedToLoadBooks(reason: Error)
    case failedToLoadNewspapers(reason: Error)
    case someOtherError
    // etc
}

class LibraryLoader {
    
    private let apiService: APIService
    
    init(apiSevice: APIService) {
        self.apiService = apiSevice
    }
    
    func loadLibrary(completion: @escaping (Result<Library, LibraryError>) -> Void) {
        // check preconditions for loading library, if fails, complete with someOtherError
        
        self.apiService.getBooks { booksResult in
            switch booksResult {
            case let .success(books):
                self.apiService.getNewspapers { newspapersResult in
                    switch newspapersResult {
                    case let .success(newspapers):
                        completion(.success(Library(books: books, newspapers: newspapers)))
                    case let .failure(error):
                        completion(.failure(.failedToLoadNewspapers(reason: error)))
                    }
                }
            case let .failure(error):
                completion(.failure(.failedToLoadBooks(reason: error)))
            }
        }
    }
}

enum APIError: Error {
    case networkError(error: Error)
    case noConnection
    case invalidResponse
    // etc
}

class APIService {
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getBooks(completion: @escaping (Result<[Book], APIError>) -> Void) {
        httpClient.get(url: URL(string: "https://backend.com/books")!) { result in
            //handle result, return the appropriate error or Book list
        }
    }
    
    func getNewspapers(completion: @escaping (Result<[Newspaper], APIError>) -> Void) {
        httpClient.get(url: URL(string: "https://backend.com/newspapers")!) { result in
            //handle result, return the appropriate error or Newspaper list
        }
    }
}


class HTTPClient {
    func get(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        // execute the network request, returns the result: response data or error
    }
}

let httpClient = HTTPClient()
let apiService = APIService(httpClient: httpClient)
let libraryLoader = LibraryLoader(apiSevice: apiService)

libraryLoader.loadLibrary { result in
    switch result {
    case let .success(library):
        // display library content
        break
    case let .failure(error):
        // display an appripriate error message
        switch error {
        case let .failedToLoadBooks(reason: error):
            if let apiError = error as? APIError {
                switch apiError {
                case let .networkError(error: networkError):
                    // message to display: "Failed to load books for library because of network error" (maybe get mor info about networkError)
                    break
                case .noConnection:
                    // message to display: "Cannot connect to the internet: failed to load books for library"
                    break
                case .invalidResponse:
                    // message to display: "Failed to load books for library."
                    break
                }
            }
        case let .failedToLoadNewspapers(reason: error):
            if let apiError = error as? APIError {
                switch apiError {
                case let .networkError(error: networkError):
                    // message to display: "Failed to load newspapers for library because of network error (maybe get mor info about networkError)"
                    break
                case .noConnection:
                    // message to display: "Cannot connect to the internet: failed to load newspapers for library"
                    break
                case .invalidResponse:
                    // message to display: "Failed to load newspapers for library."
                    break
                }
            }
        case .someOtherError:
            // Display error message that explains "nomeOtherError"
            break
        default:
            // Display general error message
            break
        }
    }
}



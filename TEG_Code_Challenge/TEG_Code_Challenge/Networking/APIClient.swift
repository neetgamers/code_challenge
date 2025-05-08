//
//  APIClient.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

protocol APIClient {
    func send<T: Decodable>(_ endpoint: Endpoint, responseModel: T.Type) async throws -> T
}

final class SecureAPIClient:NSObject, APIClient, URLSessionTaskDelegate {
    
    func send<T>(_ endpoint: any Endpoint, responseModel: T.Type) async throws -> T where T : Decodable {
        do {
            let (data, response) = try await URLSession.shared.data(for: endpoint.urlRequest, delegate: self)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidRequest
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            //print("Result: \(String(data: data, encoding: .utf8) ?? "")")
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown
            }
        } catch is DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.unknown
        }
    }
}

// MARK: - Certificate Pinning
extension SecureAPIClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        
        // Evaluate the certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
        guard let pathToCertificate = Bundle.main.path(forResource: "dev.ticketek.net", ofType: "cer"),
              let localCertificateData: NSData = NSData.init(contentsOfFile: pathToCertificate) else  {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Check if `remoteCertificateData` and `localCertificateData` has the same file size
        if isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
        
    }
}

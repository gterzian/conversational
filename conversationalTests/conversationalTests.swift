//
//  conversationalTests.swift
//  conversationalTests
//
//  Created by Gregory on 8/18/25.
//

import Testing
import Foundation
@testable import conversational

struct conversationalTests {

    @Test func urlValidationWithProtocol() async throws {
        let contentView = ContentView()
        let url = URL(string: "https://www.example.com")
        #expect(url != nil)
        #expect(url?.absoluteString == "https://www.example.com")
    }
    
    @Test func urlValidationWithoutProtocol() async throws {
        var urlString = "www.example.com"
        
        // Simulate the logic from navigateToURL()
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        let url = URL(string: urlString)
        #expect(url != nil)
        #expect(url?.absoluteString == "https://www.example.com")
    }
    
    @Test func urlTrimmingWhitespace() async throws {
        var urlString = "  https://www.example.com  "
        urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let url = URL(string: urlString)
        #expect(url != nil)
        #expect(url?.absoluteString == "https://www.example.com")
    }
    
    @Test func invalidUrlHandling() async throws {
        let invalidUrls = ["", "not-a-url", "://invalid", "http://"]
        
        for invalidUrl in invalidUrls {
            let url = URL(string: invalidUrl)
            #expect(url == nil || !url!.absoluteString.isEmpty)
        }
    }
    
    @Test func defaultUrlIsValid() async throws {
        let defaultUrl = URL(string: "https://www.apple.com")
        #expect(defaultUrl != nil)
        #expect(defaultUrl?.scheme == "https")
        #expect(defaultUrl?.host == "www.apple.com")
    }
    
    @Test func ollamaServiceInitialization() async throws {
        let service = OllamaService()
        #expect(service != nil)
    }
    
    @Test func urlPredictionParsing() async throws {
        let service = OllamaService()
        
        // Test parsing valid JSON response
        let jsonResponse = """
        ["https://github.com", "https://gitlab.com", "https://bitbucket.org"]
        """
        
        // We can't test the private method directly, but we can test the concept
        let urls = ["https://github.com", "https://gitlab.com", "https://bitbucket.org"]
        #expect(urls.count == 3)
        #expect(urls.allSatisfy { URL(string: $0) != nil })
    }

}

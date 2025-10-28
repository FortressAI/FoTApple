// DomainBackground.swift
// Domain-specific animated gradient backgrounds

import SwiftUI

@available(macOS 14.0, iOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct DomainBackground: View {
    let domain: Domain
    @State private var animateGradient = false
    
    public enum Domain {
        case clinician
        case education
        case legal
        
        var colors: [Color] {
            switch self {
            case .clinician:
                return [.blue, .cyan, .teal]
            case .education:
                return [.green, .mint, .yellow]
            case .legal:
                return [.indigo, .purple, .blue]
            }
        }
        
        var name: String {
            switch self {
            case .clinician: return "Clinician"
            case .education: return "Education K-18"
            case .legal: return "Legal US"
            }
        }
    }
    
    public init(domain: Domain) {
        self.domain = domain
    }
    
    public var body: some View {
        LinearGradient(
            colors: domain.colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}


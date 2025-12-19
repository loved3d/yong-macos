//
//  YongInputController.swift
//  yong-macos
//
//  Input controller for Yong input method using IMK framework
//

import Cocoa
import InputMethodKit

class YongInputController: IMKInputController {
    private var composingBuffer: String = ""
    private var candidates: [String] = []
    private var candidatesWindow: IMKCandidates?
    private static var engineInitialized = false
    
    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        super.init(server: server, delegate: delegate, client: inputClient)
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
        
        // Initialize yong engine on first controller creation
        if !YongInputController.engineInitialized {
            yong_engine_init()
            YongInputController.engineInitialized = true
        }
    }
    
    deinit {
        // Note: Don't cleanup engine here as it's shared across all controllers
    }
    
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event else { return false }
        
        // Only handle key down events
        guard event.type == .keyDown else { return false }
        
        let keyCode = event.keyCode
        let modifierFlags = event.modifierFlags
        let characters = event.characters ?? ""
        
        // Handle special keys
        if modifierFlags.contains(.command) || modifierFlags.contains(.control) {
            return false
        }
        
        // Handle backspace
        if keyCode == 51 { // Backspace key
            if !composingBuffer.isEmpty {
                composingBuffer.removeLast()
                updateComposition()
                return true
            }
            return false
        }
        
        // Handle escape
        if keyCode == 53 { // Escape key
            cancelComposition()
            return true
        }
        
        // Handle return/enter
        if keyCode == 36 || keyCode == 76 { // Return or Enter
            commitComposition()
            return true
        }
        
        // Handle space
        if keyCode == 49 { // Space key
            if !composingBuffer.isEmpty {
                selectCandidate(at: 0)
                return true
            }
            return false
        }
        
        // Handle number keys for candidate selection
        if characters.count == 1, let digit = Int(characters), digit >= 1 && digit <= 9 {
            if !candidates.isEmpty && digit <= candidates.count {
                selectCandidate(at: digit - 1)
                return true
            }
        }
        
        // Handle regular character input
        if characters.count == 1 {
            let char = characters.first!
            if char.isLetter || char.isNumber {
                composingBuffer.append(char)
                updateComposition()
                return true
            }
        }
        
        return false
    }
    
    private func updateComposition() {
        guard let client = client() as? IMKTextInput else { return }
        
        if composingBuffer.isEmpty {
            candidates = []
            candidatesWindow?.hide()
            client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            return
        }
        
        // Get candidates from yong engine
        candidates = getCandidates(for: composingBuffer)
        
        // Update marked text
        let markedText = composingBuffer
        client.setMarkedText(markedText, selectionRange: NSRange(location: markedText.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        
        // Show candidates window
        if !candidates.isEmpty {
            candidatesWindow?.update()
            candidatesWindow?.show(kIMKLocateCandidatesAboveHint)
        } else {
            candidatesWindow?.hide()
        }
    }
    
    private func selectCandidate(at index: Int) {
        guard index < candidates.count else { return }
        guard let client = client() as? IMKTextInput else { return }
        
        let selectedText = candidates[index]
        client.insertText(selectedText, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        
        composingBuffer = ""
        candidates = []
        candidatesWindow?.hide()
    }
    
    private func commitComposition() {
        guard let client = client() as? IMKTextInput else { return }
        
        if !composingBuffer.isEmpty {
            client.insertText(composingBuffer, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        }
        
        composingBuffer = ""
        candidates = []
        candidatesWindow?.hide()
    }
    
    private func cancelComposition() {
        guard let client = client() as? IMKTextInput else { return }
        
        client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        composingBuffer = ""
        candidates = []
        candidatesWindow?.hide()
    }
    
    override func candidates(_ sender: Any!) -> [Any]! {
        return candidates as [Any]
    }
    
    // MARK: - Yong Engine Integration
    
    private func getCandidates(for input: String) -> [String] {
        // Call yong engine to get candidates
        var candidatePointers = [UnsafeMutablePointer<CChar>?](repeating: nil, count: Int(MAX_CANDIDATES))
        
        let count = input.withCString { inputPtr in
            candidatePointers.withUnsafeMutableBufferPointer { buffer in
                yong_engine_get_candidates(inputPtr, buffer.baseAddress, Int32(MAX_CANDIDATES))
            }
        }
        
        var results: [String] = []
        for i in 0..<Int(count) {
            if let ptr = candidatePointers[i] {
                results.append(String(cString: ptr))
            }
        }
        
        // Free the candidates memory
        candidatePointers.withUnsafeMutableBufferPointer { buffer in
            yong_engine_free_candidates(buffer.baseAddress, count)
        }
        
        return results
    }
}

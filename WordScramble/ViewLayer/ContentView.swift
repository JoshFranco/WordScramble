//
//  ContentView.swift
//  WordScramble
//
//  Created by Josh Franco on 5/11/20.
//  Copyright © 2020 Josh Franco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var currentScore = 0
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showingError = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your Word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) { word in
                    Image(systemName: "\(word.count).circle")
                    Text(word.capitalized)
                }
                
                Text("Your score is: \(currentScore)")
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing:
                Button(action: startGame, label: {
                    Text("Restart")
                })
            )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle),
                      message: Text(errorMsg),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Private Methods
private extension ContentView {
    func startGame() {
        guard
            let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsURL) else {
                fatalError("Could not load start.txt from bundle")
        }
        
        let allWords = startWords.components(separatedBy: "\n")
        self.rootWord = allWords.randomElement()?.capitalized ?? "Mug"
        self.usedWords.removeAll()
        self.currentScore = 0
        self.newWord = ""
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(using: "Word used already", msg: "Be more original...")
            decrimentScore()
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(using: "Word not recognized", msg: "You can't just make them up, ya know!")
            decrimentScore()
            return
        }
        
        guard isReal(word: answer) else {
            wordError(using: "Word not possible", msg: "That isn't a real word?!")
            decrimentScore()
            return
        }
        
        guard answer.count >= 3 else {
            wordError(using: "Word is only \(answer.count) \(answer.count == 1 ? "letter" : "letters") long", msg: "Word needs to be longer than 2 letters, no cheating")
            return
        }
        
        guard answer.lowercased() != rootWord.lowercased() else {
            wordError(using: "Can't use the root word", msg: "Try words within the root word \(rootWord.capitalized)")
            return
        }
        
        usedWords.insert(answer, at: 0)
        currentScore += 1
        newWord = ""
    }
    
    func decrimentScore() {
        if currentScore > 0 {
            currentScore -= 1
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let letterIndex = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: letterIndex)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word,
                                                            range: range,
                                                            startingAt: 0,
                                                            wrap: false,
                                                            language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(using title: String?, msg: String?) {
        errorTitle = title ?? ""
        errorMsg = msg ?? ""
        showingError = true
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

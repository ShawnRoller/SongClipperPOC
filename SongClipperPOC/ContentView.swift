//
//  ContentView.swift
//  SongClipperPOC
//
//  Created by Shawn Roller on 8/30/23.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State var musicAccessEnabled = false
    @State var song: Song? = nil
    let musicPlayer = ApplicationMusicPlayer.shared
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! Permission? \(musicAccessEnabled ? "yes" : "no")")
            Button {
                Task {
                    await requestMediaAccess()
                }
            } label: {
                Text("Request access")
            }
            Spacer()
            Button {
                Task {
                    await executeSearch()
                }
            } label: {
                Text("Search")
            }
            .disabled(!musicAccessEnabled)
            Spacer()
            Button {
                Task {
                    await playSong()
                }
            } label: {
                Text("Play")
            }
            .disabled(song == nil)
            Spacer()
            Button {
                Task {
                    await skip()
                }
            } label: {
                Text("Skip to solo")
            }
            .disabled(song == nil)
            Spacer()
            Button {
                playClip()
            } label: {
                Text("Play solo clip")
            }
            .disabled(song == nil)
            Spacer()
            Button {
                changeSpeed()
            } label: {
                Text("Change speed")
            }
            .disabled(song == nil)
        }
        .padding()
    }
    
    func requestMediaAccess() async -> Void {
        let result = await MusicAuthorization.request()
        print(result)
        if result == .authorized {
            musicAccessEnabled = true
        }
    }
    
    func executeSearch() async -> Void {
        do {
            var request = MusicCatalogSearchRequest(term: "Children of Bodom Follow the Reaper", types: [Song.self])
            request.limit = 1
            let response = try await request.response()
            print(response)
            song = response.songs.first
        } catch {
            print("error searching: \(error.localizedDescription)")
        }
    }
    
    func playSong() async -> Void {
        guard let song = song else { return }
        do {
            ApplicationMusicPlayer.shared.queue = ApplicationMusicPlayer.Queue(for: [song], startingAt: nil)
            try await musicPlayer.play()
        } catch {
            print("error playing: \(error.localizedDescription)")
        }
    }
    
    func skip() async -> Void {
        let time: TimeInterval = 167.5
        musicPlayer.playbackTime = time
    }
    
    func playClip() -> Void {
        // Set the start of the clip
        let time: TimeInterval = 188
        musicPlayer.playbackTime = time
        
        // Start a timer to mark the end of the clip
//        let duration = 15 / musicPlayer.state.playbackRate
//        print("!@#$!@#$ duration: \(duration)")
//        let interval: TimeInterval = TimeInterval(duration)
        let interval: TimeInterval = 15
        print("!@#$!@#$! interval: \(interval)")
        // TODO: when the speed is changed, we have to adjust the schedule
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { t in
            self.playClip()
        }
        timer.fire()
    }
    
    func changeSpeed() -> Void {
        musicPlayer.state.playbackRate = musicPlayer.state.playbackRate == 0.8 ? 1.0 : 0.8
    }
}

#Preview {
    ContentView()
}

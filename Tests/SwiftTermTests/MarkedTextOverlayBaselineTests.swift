//
//  MarkedTextOverlayBaselineTests.swift
//
//  The IME / dictation marked-text overlay keeps the terminal's baseline, so
//  the text stays put while composing instead of moving whenever the fonts on
//  the line change — kana alone come from a fallback font with a taller
//  ascent, and a trailing romaji letter brings the terminal font back.
//
#if os(macOS)
import AppKit
import Testing
@testable import SwiftTerm

@MainActor
final class MarkedTextOverlayBaselineTests {

    private func makeView() -> TerminalView {
        let view = TerminalView(frame: CGRect(x: 0, y: 0, width: 320, height: 160))
        view.font = NSFont(name: "Menlo-Regular", size: 16) ?? .monospacedSystemFont(ofSize: 16, weight: .regular)
        return view
    }

    private func mark(_ view: TerminalView, _ text: String) {
        view.setMarkedText(text,
                           selectedRange: NSRange(location: (text as NSString).length, length: 0),
                           replacementRange: NSRange(location: NSNotFound, length: 0))
    }

    /// Distance from the top of the overlay's first line to its baseline.
    private func baseline(in view: TerminalView) throws -> CGFloat {
        let overlay = try #require(view.subviews.lazy.compactMap { $0 as? DictationOverlayTextView }.first)
        let layoutManager = try #require(overlay.layoutManager)
        return layoutManager.location(forGlyphAt: 0).y
    }

    @Test func testBaselineStaysPutAsTheFontsOnTheLineChange() throws {
        let view = makeView()
        mark(view, "にほんg")
        let mixed = try baseline(in: view)
        mark(view, "にほんご")
        let kanaOnly = try baseline(in: view)
        #expect(mixed == kanaOnly)
    }

    @Test func testBaselineMatchesTheTerminalRows() throws {
        let view = makeView()
        mark(view, "にほんご")
        #expect(try baseline(in: view) == view.cellDimension.height - view.baselineOffset)
    }
}
#endif

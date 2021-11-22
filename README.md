# ocrimg

This is a crude hack of a command-line program to make images searchable in Spotlight by OCRing them. The idea is that I can feed it all the random cartoons and memes I've downloaded from the Internet, and then later I'll have some chance of finding the one I want.

It seemed like a simple problem, however:

 - Automator and AppleScript don't have support for the text extraction API.
 - Shortcuts has the text extraction functionality, but can't set comments on files.
 - You can get Shortcuts to call a piece of AppleScript, but doing the necessary string processing in AppleScript didn't appeal.
 - You can also get Shortcuts to call JXA, but then I was faced with trying to work out how to script the Finder to set comments using JXA, when all the examples are in AppleScript.
 
So I decided to give in and write some Swift, even though I'd never written any before. This ugly piece of Swift code is the result.

It uses the macOS 12+ image recognition APIs to find text in images, then calls the Finder via AppleScript to set the Spotlight comments for the files.

Obviously if you use Spotlight comments for anything else, you don't want to run this program, as it will obliterate any existing comments.

Someone should definitely make a handy drag-drop utility to do this.

To compile it, `swift build` (ha ha no it isn't) and then copy `.build/debug/ocrimg` to `/usr/local/bin`.

Dual-licensed under the Unlicense / WTFPL.

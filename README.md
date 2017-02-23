# QuickLookASE

Mac QuickLook for ASE files (Adobe Swatch Exchange)

ASE are color palettes that can be exported from Adobe Photoshop, Adobe Illustrator, [Adobe Color CC](https://color.adobe.com/), [Spectrum](http://www.eigenlogik.com/spectrum/mac), [COLOURlovers](http://www.colourlovers.com/), [Prisma](http://www.codeadventure.com/), among many others.

Based on Apple's [QuickLookSketch](https://developer.apple.com/library/prerelease/content/samplecode/QuickLookSketch/Introduction/Intro.html).

ASE format Reference: <http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase>

# Installation

If you want to skip compilation and just install it, [download Release 1.0](https://github.com/rsodre/QuickLookASE/releases), unzip and copy `QuickLookASE.qlgenerator` to `~/Library/QuickLook/`. To reach that folder in Finder, go to your Home, click on the Go menu on the top bar, hold the Option key and `Library` will magically appear.

Or copy it from a terminal:

<pre>
cp -R QuickLookASE.qlgenerator ~/Library/QuickLook/
</pre>

Alternatively, if you use [Homebrew-Cask](https://github.com/caskroom/homebrew-cask), install with:

<pre>
brew cask install quicklookase
</pre>

# Notes

How to find the UTI of a file:

<pre>
mdls -name kMDItemContentType MySwatch.ase
</pre>


# How It Looks:

![](https://raw.githubusercontent.com/rsodre/QuickLookASE/master/example1.png)

![](https://raw.githubusercontent.com/rsodre/QuickLookASE/master/example2.png)


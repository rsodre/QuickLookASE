# QuickLookASE

Mac QuickLook for ASE files (Adobe Swatch Exchange)

Based on Apple's [QuickLookSketch](https://developer.apple.com/library/prerelease/content/samplecode/QuickLookSketch/Introduction/Intro.html).

ASE format Reference: <http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase>

# Installation

If you want to skip compilation and go use it, [download Release 1.0](https://github.com/rsodre/QuickLookASE/releases), unzip and copy `QuickLookASE.qlgenerator` to `~/Library/QuickLook/`.

To reach that folder on Finder, go to your Home, click on the Go menu, hold option and `Library` will magically appear.

Or copy it from a terminal:

<pre>
cp -R QuickLookASE.qlgenerator ~/Library/QuickLook/
</pre>


# Notes

How to find the UTI of a file:

<pre>
mdls -name kMDItemContentType MySwatch.ase
</pre>




# Praat automated vowel measurement tutorial

These files relate to a live-coding demonstration given at the UW Phonetics
Lab in November of 2018. The script `measure-formants-automated.praat` was
the focus of the demonstration.

Note that the mismatch between number of `.wav` files and number of `.TextGrid`
files is intentional; this is to reinforce the point that depending on how your
script is written, you may or may not readily notice when there are files with
missing annotations. In this case, the script loops over `.TextGrid` files and
assumes the existence of corresponding `.wav` files, and will only error if an
expected `.wav` file is missing; cases where a `.wav` file exists but has no
corresponding `.TextGrid` will not be noticed by the script. This may or may
not be what you want.

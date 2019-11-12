# ================================ #
# measure-formants-automated.praat #
# ================================ #

# author: drmccloy@uw.edu
# license: BSD 3-clause
# created: Thu Nov 29 11:09:14 PST 2018

form Measure formants automated
    comment This script assumes that the filenames of your textgrids match the
    comment filenames of the audio files that they annotate. Audio files with
    comment no corresponding textgrids will be skipped.
    sentence textgrid_directory textgrids
    sentence sound_directory wavs
    sentence output_file formant-measurements-automated.csv
    comment Which TextGrid tier contains your segment labels?
    integer label_tier 1
endform

# first, we write a little function to make sure the folder names provided by
# the user have a trailing slash...
procedure clean .path$
    if not right$(.path$, 1) = "/"
        .path$ = '.path$' + "/"
    endif
endproc
# ...then we apply that function to the two folder names
call clean textgrid_directory$
textgrid_directory$ = clean.path$
call clean sound_directory$
sound_directory$ = clean.path$

# make a list of all the textgrids
tglist = Create Strings as file list: "tglist",
    ...textgrid_directory$ + "*.TextGrid"
selectObject: tglist
file_count = Get number of strings

# initialize output file. the column headings here are determined by the
# arguments used later in the "Down to Table" command (line 93), and the
# additional columns added to the table (lines 105-118).
sep$ = ","
writeFileLine: output_file$,
    ..."file",         sep$,
    ..."vowel_number", sep$,
    ..."vowel_ipa",    sep$,
    ..."start",        sep$,
    ..."end",          sep$,
    ..."duration",     sep$,
    ..."frame_number", sep$,
    ..."frame_time",   sep$,
    ..."F1",           sep$,
    ..."F2",           sep$,
    ..."F3",           sep$,
    ..."F4",           sep$,
    ..."F5"


# "step" is the time (in seconds) between adjacent frames of formant analysis.
# Some users may prefer to include this variable in the form rather than
# hard-coding it here, so that it could be easily changed each time the script
# is run.
step = 0.025

# this is the main loop over each wav+TextGrid file pair
for this_file_number from 1 to file_count
    # get the next textgrid filename
    selectObject: tglist
    this_tgfile$ = Get string: this_file_number
    # load the textgrid
    this_tg = Read from file: textgrid_directory$ + this_tgfile$
    n_intervals = Get number of intervals: label_tier
    this_name$ = selected$("TextGrid", 1)
    # load the wav file
    this_wavpath$ = sound_directory$ + this_name$ + ".wav"
    this_wav = Open long sound file: this_wavpath$
    selectObject: this_wav

    # loop through intervals
    vowel_counter = 0
    for this_interval to n_intervals
        selectObject: this_tg
        this_label$ = Get label of interval: label_tier, this_interval
        if this_label$ <> ""
            vowel_counter += 1
            start = Get start time of interval: label_tier, this_interval
            end = Get end time of interval: label_tier, this_interval
            this_duration$ = fixed$(end - start, 3)
            # extract vowel
            selectObject: this_wav
            this_vow = Extract part: start - step, end + step, "yes"
            this_fmt = To Formant (burg): 0, 5, 5500, step, 50
            this_tab = Down to Table: "no", "yes", 3, "no", 3, "no", 3, "no"
            # loop through measurement frames
            n_frames = Get number of rows
            n_columns = Get number of columns
            for this_frame to n_frames
                this_t = Get value: this_frame, "time(s)"
                if this_t >= start and this_t <= end
                    this_f1 = Get value: this_frame, "F1(Hz)"
                    this_f2 = Get value: this_frame, "F2(Hz)"
                    this_f3 = Get value: this_frame, "F3(Hz)"
                    this_f4 = Get value: this_frame, "F4(Hz)"
                    this_f5 = Get value: this_frame, "F5(Hz)"
                    appendFileLine: output_file$,
                        ...this_name$,       sep$,
                        ...vowel_counter,    sep$,
                        ...this_label$,      sep$,
                        ...fixed$(start, 3), sep$,
                        ...fixed$(end, 3),   sep$,
                        ...this_duration$,   sep$,
                        ...this_frame,       sep$,
                        ...this_t,           sep$,
                        ...this_f1,          sep$,
                        ...this_f2,          sep$,
                        ...this_f3,          sep$,
                        ...this_f4,          sep$,
                        ...this_f5
                endif
            endfor
            selectObject: this_vow
            plusObject: this_fmt
            plusObject: this_tab
            Remove
        endif
    endfor
    selectObject: this_tg
    plusObject: this_wav
    Remove
endfor
selectObject: tglist
Remove
